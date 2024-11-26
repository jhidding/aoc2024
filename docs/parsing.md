---
title: Parsing
---

# Parser combinators

## Monads

``` {.julia file=src/Monads.jl}
module Monads
    export Monad, bind, pure, fmap, starmap, value_type

    abstract type Monad end
    function bind end
    function pure end
    function fmap end

    Base.:>>(m::M, f::F) where {M <: Monad, F} = bind(m, f)
    pure(::Type{M}) where {M <: Monad} = (x -> pure(M, x))
    fmap(::Type{M}, f::F) where {M <: Monad, F} = pure(M) ∘ f
    fmap(f::F, m::M) where {M <: Monad, F} = m >> fmap(M, f)
    starmap(::Type{M}, f::F) where {F, M <: Monad} = pure ∘ splat(f)
end
```

## Parsers

``` {.julia .hide file=test/ParsingSpec.jl}
@testset "Parsing" begin
    using AOC2024.Parsing

    <<parsing-spec>>
end
```

A `Parser` is a `Monad`. The `parse` function takes a `Parser` and a string, returning a tuple of a result and another string (the rest of the text that needs to be parsed). We have a generic `FnParser` that should cover all bases using closures. However, we'll have some specialized parsers that are both inspectable and should allow optimizations.

``` {.julia file=src/Parsing.jl}
module Parsing
    using ..Monads
    import ..Monads: bind, pure
    import Base: parse

    export pure, bind

    abstract type Parser <: Monad end
    # function parse end

    mutable struct FnParser{F} <: Parser
        fn::F
    end

    function parse(p::FnParser{F}, s::S) where {F, S <: AbstractString}
        return p.fn(s)
    end

    <<parsing>>
end
```

The `pure` parser, doesn't consume input, but returns a given value.

``` {.julia #parsing}
export pure_p

struct PureParser{T} <: Parser
    value::T
end

function parse(p::PureParser{T}, s::S) where {T, S <: AbstractString}
    return (p.value, s)
end

function pure(::Type{P}, value::T) where {P <: Parser, T}
    return PureParser{T}(value)
end

pure_p(value::T) where {T} = pure(Parser, value)

Base.convert(::Type{PureParser{Nothing}}, ::Nothing) = pure(nothing)
```

``` {.julia #parsing-spec}
@test parse(pure_p(3), "abc") == (3, "abc")
@test parse(pure_p(nothing), "abc") == (nothing, "abc")
```

### Parser Monad

A `Monad` should have `pure` and `bind` implemented.

``` {.julia #parsing}
function bind(p::P, f::F) where {P <: Parser, F}
    function (inp::S) where {S <: AbstractString}
        (x, next_inp) = parse(p, inp)
        parse(f(x), next_inp)
    end |> FnParser
end
```

``` {.julia #parsing-spec}
@test parse(pure_p(1) >> (x -> pure_p(x + 1)), "abc") == (2, "abc")
```

### Alternatives

``` {.julia #parsing}
abstract type Fail <: Exception end
struct FailMsg <: Fail
    msg::String
end

struct Expected <: Fail
    what::AbstractString
    got::AbstractString
end

struct ChoiceFail <: Fail
    fails::Vector{Fail}
    ChoiceFail(f1::ChoiceFail, f2::ChoiceFail) = new([f1.fails; f2.fails])
    ChoiceFail(f1::Fail, f2::ChoiceFail) = new([f1, f2.fails...])
    ChoiceFail(f1::ChoiceFail, f2::Fail) = new([f1.fails..., f2])
    ChoiceFail(f1::Fail, f2::Fail) = new([f1, f2])
end

struct Choice{A, B} <: Parser
    a::A
    b::B
end

function parse(p::Choice{A, B}, s::S) where {S <: AbstractString, A <: Parser, B <: Parser}
    try
        parse(p.a, s)
    catch e1
        try
            parse(p.b, s)
        catch e2
            throw(ChoiceFail(e1, e2))
        end
    end
end

Base.:|(p1::A, p2::B) where {A <: Parser, B <: Parser} =
    Choice{A, B}(p1, p2)

optional(p::P) where {P <: Parser} = p | nothing
Base.:~(p::P) where {P <: Parser} = optional(p)
```

``` {.julia #parsing-spec}
@test parse(many(token(integer_p | match_p("abc"))), "123 abc 4 5 abc def") ==
    ([123, "abc", 4, 5, "abc"], "def")
```

### Combinators

``` {.julia #parsing}
Base.:>>>(a::A, b::B) where {A <: Parser, B <: Parser} = a >> (_ -> b)
skip(p::P) where {P <: Parser} = v -> (p >>> pure_p(v))

struct SequenceParser{P} <: Parser
    ps::P
end

sequence(ps...) = SequenceParser(ps)

export sequence

@generated function parse(p::SequenceParser{P}, s::S) where {P, S <: AbstractString}
    n = length(P.types)
    :(begin
        $((:(($(Symbol("a$i")), s) = parse(p.ps[$i], s)) for i = 1:n)...)
        return (($((Symbol("a$i") for i = 1:n)...),), s)
    end)
end

function many(p::P) where {P <: Parser}
    function (s::S) where {S <: AbstractString}
        result = []
        while true
            try
                (x, s) = parse(p, s)
                push!(result, x)
            catch
                return (result, s)
            end
        end
    end |> FnParser
end

sep_by_p(p::A, sep::B) where {A <: Parser, B <: Parser} =
    sequence(p, many(sep >>> p)) >> starmap((h, t) -> pushfirst!(t, h))

export many, sep_by_p
```

### String literals and regexes

``` {.julia #parsing}
export match_p

struct RegexParser <: Parser
    re::Regex
end

match_p(re::Regex) = RegexParser(re)

Base.convert(::Type{RegexParser}, re::Regex) = RegexParser(re)

function parse(p::RegexParser, s::S) where {S <: AbstractString}
    if !startswith(s, p.re)
        throw(Expected("$(p.re)", s))
    end
    m = match(p.re, s)
    return (m, s[length(m.match)+1:end])
end

struct LiteralParser <: Parser
    lit::String
end

match_p(s::String) = LiteralParser(s)

function parse(p::LiteralParser, s::S) where {S <: AbstractString}
    if !startswith(s, p.lit)
        throw(Expected("$(p.lit)", s))
    end
    return (p.lit, s[length(p.lit)+1:end])
end
```

### Convenience parsers

``` {.julia #parsing}
token(p::A, space::B = RegexParser(r"\s*")) where {A <: Parser, B <: Parser} =
    p >> skip(space)

integer_p = fmap(x -> parse(Int, x.match), match_p(r"-?[1-9][0-9]*"))

integer = token(integer_p)

export token, integer_p, integer
```

``` {.julia #parsing-spec}
@test parse(match_p("hello"), "hellogoodbye") == ("hello", "goodbye")

p = match_p("a") >>> match_p("b")
@test parse(p, "abc") == ("b", "c")

p = sequence(match_p("a"), match_p("b"))
@test parse(p, "abc") == (("a", "b"), "c")

#p = sequence(n=match_p("a"), m=match_p("b"))
#@test parse(p, "abc") == (Dict(:n => "a", :m => "b"), "c")
@test parse(integer_p, "123abc") == (123, "abc")

p = many(integer)
@test parse(p, "1  2 3  4 56    7 abc") == ([1, 2, 3, 4, 56, 7], "abc")
```
