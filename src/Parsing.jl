# ~/~ begin <<docs/parsing.md#src/Parsing.jl>>[init]
module Parsing
    using ..Monads
    import ..Monads: bind, pure
    import Base: parse

    export Parser, pure, bind, result_type, result

    abstract type Parser <: Monad end
    # function parse end

    value_type(::Type{Tuple{V, S}}) where {S, V} = V
    value_type(::Type{Union{A, B}}) where {A, B} = Union{value_type(A), value_type(B)}
    value_type(::Type{Any}) = Any

    function result_type(::Type{P}) where {P <: Parser}
        t = Base.return_types(parse, [P, String])

        if length(t) == 1
            value_type(t[1])
        else
            Any
        end
    end

    result_type(::P) where {P <: Parser} = result_type(P)

    result(x::Tuple{T, U}) where {T, U} = x[1]

    mutable struct FnParser{F} <: Parser
        fn::F
    end

    function parse(p::FnParser{F}, s::S) where {F, S <: AbstractString}
        return p.fn(s)
    end

    const item_p = function(inp::S) where {S <: AbstractString}
        isempty(inp) && throw(Fail("End of input"))
        (inp[1], inp[2:end])
    end |> FnParser

    export item_p

    # ~/~ begin <<docs/day03.md#parsing>>[init]
    export repeated

    function repeated(p::P) where {P <: Parser}
        function (s::S) where {S <: AbstractString}
            while true
                try
                    (x, s) = parse(p, s)
                catch
                    return (nothing, s)
                end
            end
        end |> FnParser
    end
    # ~/~ end
    # ~/~ begin <<docs/parsing.md#parsing>>[0]
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
    # ~/~ end
    # ~/~ begin <<docs/parsing.md#parsing>>[1]
    function bind(p::P, f::F) where {P <: Parser, F}
        function (inp::S) where {S <: AbstractString}
            (x, next_inp) = parse(p, inp)
            parse(f(x), next_inp)
        end |> FnParser
    end
    # ~/~ end
    # ~/~ begin <<docs/parsing.md#parsing>>[2]
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

    struct ChoiceMany{P} <: Parser
        ps::Vector{P}
    end

    function parse(p::ChoiceMany{P}, s::S) where {P <: Parser, S <: AbstractString}
        for q in p.ps
            try
                (r, s) = parse(q, s)
                return (r, s)
            catch e
                continue
            end
        end
        throw(Fail())
    end


    optional(p::P) where {P <: Parser} = p | nothing
    Base.:~(p::P) where {P <: Parser} = optional(p)
    # ~/~ end
    # ~/~ begin <<docs/parsing.md#parsing>>[3]
    Base.:>>>(a::A, b::B) where {A <: Parser, B <: Parser} = a >> (_ -> b)
    Base.skip(p::P) where {P <: Parser} = v -> (p >>> pure_p(v))

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
        RT = result_type(P)
        function (s::S) where {S <: AbstractString}
            result = RT[]
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
        sequence(p, many(sep >>> p)) >> starmap(Parser, (h, t) -> pushfirst!(t, h))

    export many, sep_by_p
    # ~/~ end
    # ~/~ begin <<docs/parsing.md#parsing>>[4]
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

    match_p(s::AbstractString) = LiteralParser(s)

    function parse(p::LiteralParser, s::S) where {S <: AbstractString}
        if !startswith(s, p.lit)
            throw(Expected("$(p.lit)", s))
        end
        return (p.lit, s[length(p.lit)+1:end])
    end

    parse(p::Parser) = function(s::AbstractString)
        parse(p, s)
    end
    # ~/~ end
    # ~/~ begin <<docs/parsing.md#parsing>>[5]
    token(p::A, space::B = RegexParser(r"\s*")) where {A <: Parser, B <: Parser} =
        p >> skip(space)

    integer_p = fmap(x -> parse(Int, x.match), match_p(r"-?[1-9][0-9]*|0"))

    integer = token(integer_p)

    export token, integer_p, integer
    # ~/~ end
    # ~/~ begin <<docs/parsing.md#parsing>>[6]
    union_types(u) = (u,)
    union_types(u::Union) = (u.a, union_types(u.b)...)

    function many_somethings(p::P) where {P <: Parser}
        types = Set(union_types(result_type(P)))
        @assert Nothing ∈ types
        value_types = collect(setdiff(types, [Nothing]))
        @assert all(value_types .<: Some)
        if length(value_types) == 1
            RT = value_types[1].types[1]
        else
            ts = [t.types[1] for t in value_types]
            RT = Union{ts...}
        end

        function (s::S) where {S <: AbstractString}
            result = RT[]
            while true
                try
                    (x, s) = parse(p, s)
                    x === nothing && continue
                    push!(result, something(x))
                catch
                    return (result, s)
                end
            end
        end |> FnParser
    end
    # ~/~ end
end
# ~/~ end
