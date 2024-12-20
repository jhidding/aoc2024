---
title: Day 17
---

# Day 17

``` {.julia file=test/Day17Spec.jl}
# add tests
```

``` {.julia file=src/Day17.jl}
module Day17

using ..Monads
using ..Parsing

struct Input
    a::Int
    b::Int
    c::Int
    program::Vector{Int}
end

function compile(program::Vector{Int})
    function combo(n::Int)
        n <= 3 && return n
        n == 4 && return :a
        n == 5 && return :b
        n == 6 && return :c
        throw("illegal operand")
    end

    adv(x::Int) = :(a >>= $(combo(x)))
    bxl(x::Int) = :(b ⊻= $(x))
    bst(x::Int) = :(b = $(combo(x)) % 8)
    jnz(x::Int) = :(a != 0 && @goto $(Symbol("pos", x)))
    bxc(x::Int) = :(b ⊻= c)
    out(x::Int) = :(push!(out, $(combo(x)) % 8))
    bdv(x::Int) = :(b = a >> $(combo(x)))
    cdv(x::Int) = :(c = a >> $(combo(x)))

    instruction(opcode, operand) =
        [adv, bxl, bst, jnz, bxc, out, bdv, cdv][opcode+1](operand)

    instr = reshape(program, (2, :))
    gotos = instr[2,instr[1,:] .== 3]
    code = []
    for (i, (opcode, operand)) in enumerate(eachcol(instr))
        if i - 1 ∈ gotos
            push!(code, :(@label $(Symbol("pos", i - 1))))
        end
        push!(code, instruction(opcode, operand))
    end

    :(function (a, b, c)
        out = Int[]
        $(code...)
        return out
    end)
end

function find_input(rev_prog::Vector{Int}, a)
    isempty(rev_prog) && return a

    for q in 0:7
        a_next = a << 3 + q
        b = q ⊻ 1
        c = (a_next >> b) % 8
        if b ⊻ c ⊻ 6 == rev_prog[1]
            solution = find_input(rev_prog[2:end], a_next)
            solution !== nothing && return solution
        end
    end

    return nothing
end

function read_input(io::IO)
    register(a) = token(match_p("Register $a:")) >>> integer
    program = token(match_p("Program:")) >>> sep_by_p(integer, match_p(","))
    input = fmap(splat(Input), sequence(
        register("A"), register("B"), register("C"), program))
    read(io, String) |> parse(input) |> result
end

function main(io::IO)
    return nothing
end

end
```

## Part 2

My input is

```
Register A: 25358015
Register B: 0
Register C: 0

Program: 2,4,1,1,7,5,0,3,4,7,1,6,5,5,3,0
```

Disassembled that would be:

```
bst 4
bxl 1
cdv 5
adv 3
bxc 7
bxl 6
out 5
jnz 0
```

This is a single loop!

```julia
while a != 0
    b = a % 8
    b ⊻= 1
    c = a >> b
    a = a >> 3
    b ⊻= c
    b ⊻= 6
    print(b % 8)
end
```

We may reshuffle, and then the core loop is

```julia
while a != 0
    # do stuff
    a >>= 3
end
```

In that "do stuff" is:

1. flip the 1st bit from `a`, so: `b = a % 8 + 1` or `a % 8 - 1`
   this determines which bits from `a` we're reading into `c`
2. `c = a >> b`
3. print `b%8 ⊻ c%8 ⊻ 6`

The first number we should write is 2, or `0b010`. Then `b%8 ⊻ c%8 = 0b100`. We could make a table for admissible values of `b` and `c`.

```julia
using CairoMakie

function plot_tables()
    fig = Figure()
    for r = 1:2
        for c = 1:4
            n = (r-1) * 4 + c - 1
            ax = Axis(fig[r, c], title="$n")
            table = xor.(xor.((0:7)[:,na], (0:7)[na,:]), n) .== 0
            heatmap!(ax, table)
        end
    end
    save("day16-table.svg", fig)
end
```

We know that the value of `b` is one-to-one with the first three bits in `a`. And, these tables give a one-to-one mapping of `b` to `c`. So choosing `b` fixes the values for some other bits in `a`, which in turn fix values later on, drastically shrinking our state space.

Furthermore, if `xor(b, 1) < 3` then the bits of `c` and `b` overlap.
