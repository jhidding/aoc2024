# ~/~ begin <<docs/day17.md#src/Day17.jl>>[init]
module Day17

using ..Monads
using ..Parsing

struct Input
    a::Int
    b::Int
    c::Int
    program::Vector{Int}
end

mutable struct Computer
    ip::Int
    a::Int
    b::Int
    c::Int
    program::Vector{Int}
    out::Vector{Int}
end

initial_state(input::Input) =
    Computer(0, input.a, input.b, input.c, input.program, Int[])

function combo(c::Computer, n::Int)
    n <= 3 && return n
    n == 4 && return c.a
    n == 5 && return c.b
    n == 6 && return c.c
    n >= 7 && throw("illegal operand")
end

adv(c::Computer, x::Int) = c.a >>= combo(c, x)
bxl(c::Computer, x::Int) = c.b ⊻= x
bst(c::Computer, x::Int) = c.b = mod(combo(c, x), 8)
jnz(c::Computer, x::Int) = c.a == 0 ? nothing : c.ip = x - 2
bxc(c::Computer, x::Int) = c.b ⊻= c.c
out(c::Computer, x::Int) = push!(c.out, mod(combo(c, x), 8))
bdv(c::Computer, x::Int) = c.b = c.a >> combo(c, x)
cdv(c::Computer, x::Int) = c.c = c.a >> combo(c, x)

function Base.iterate(c::Computer, s::Nothing)
    c.ip >= length(c.program) && return nothing
    opcode = [adv, bxl, bst, jnz, bxc, out, bdv, cdv]
    instr, x = c.program[c.ip+1:c.ip+2]
    opcode[instr+1](c, x)
    c.ip += 2
    return c, nothing
end

Base.iterate(c::Computer) = iterate(c, nothing)
Base.IteratorSize(::Computer) = Base.SizeUnknown()

function run(c::Computer)
    for state in c end
    return c.out
end

function find_input(rev_prog::Vector{Int}, a, out::Channel{Int})
    isempty(rev_prog) && return a

    for b in 0:7
        a_next = a << 3 + (b ⊻ 1)
        c = (a_next >> b) % 8
        if b ⊻ c ⊻ 6 == rev_prog[1]
            solution = find_input(rev_prog[2:end], a_next, out)
            solution !== nothing && put!(out, solution)
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
# ~/~ end
