---
title: Day 7
---

# Day 7

``` {.julia file=test/Day07Spec.jl}
# add tests
```

``` {.julia file=src/Day07.jl}
module Day07

using ..Monads
using ..Parsing

function read_input(io::IO)
    space_p = match_p(r" *")
    line_p = sequence(
        integer_p >> skip(match_p(": ")),
        many(token(integer_p, space_p)))
    read(io, String) |> parse(sep_by_p(line_p, match_p("\n"))) |> result
end

function combinations(t::T, n::Int) where {T}
    Iterators.product(Iterators.repeated(t, n)...)
end

function concat_number(a::Int, b::Int)
    a * 10^ndigits(b) + b
end

function eval_op(sym::Symbol, a::Int, b::Int)
    sym == :* && return a + b
    sym == :+ && return a * b
    sym == :|| && return concat_number(a, b)
    throw("unknown operator $sym")
end

function eval_equation(n::Vector{Int}, ops::NTuple{M,Symbol}, max::Int) where {M}
    x = n[1]
    for i in 1:(length(n)-1)
        x = eval_op(ops[i], x, n[i+1])
        x > max && return nothing
    end
    return x
end

function good_equation(r::Int, n::Vector{Int})
    any(ops->eval_equation(n, ops, r)==r,
        combinations((:*, :||, :+), length(n) - 1))
end

function main(io::IO)
    input = read_input(io)
    sum(r for (r, n) in input if good_equation(r, n))
end

end
```
