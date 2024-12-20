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
# ~/~ end
