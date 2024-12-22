---
title: Day 21
---

# Day 21

``` {.julia file=test/Day21Spec.jl}
using AOC2024.Day21: robot, NUMPAD, CONTROLLER

let buf = Char[],
    out(x) = push!(buf, x),
    r1 = out |> robot(NUMPAD),
    r2 = out |> robot(NUMPAD) |> robot(CONTROLLER),
    r3 = out |> robot(NUMPAD) |> robot(CONTROLLER) |> robot(CONTROLLER)

    r1("<A^A>^^AvvvA")
    @test join(buf) == "029A"
    empty!(buf)
    r2("v<<A>>^A<A>AvA<^AA>A<vAAA>^A")
    @test join(buf) == "029A"
    empty!(buf)
    r3("<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A")
    @test join(buf) == "029A"
end
```

``` {.julia file=src/Day21.jl}
module Day21

using DataStructures

const Pos = CartesianIndex{2}
const Key = Union{Char, Missing}
const Keypad = Matrix{Key}

const NIL = missing

const NUMPAD::Keypad = [
    '7' '8' '9';
    '4' '5' '6';
    '1' '2' '3';
    NIL '0' 'A' ]

const CONTROLLER::Keypad = [
    NIL '^' 'A';
    '<' 'v' '>' ]

const DIRECTION = IdDict{Char,Pos}(
    '^' => Pos(-1, 0),
    '<' => Pos(0, -1),
    'v' => Pos( 1, 0),
    '>' => Pos(0,  1))

struct Cmd{T} end

robot(keypad::Keypad) = Base.Fix1(robot, keypad)

function robot(keypad::Keypad, output::F) where {F}
    pos = findfirst(isequal('A'), keypad)

    function f(k::Key)
        @assert k ∈ "A^<v>"
        if k == 'A'
            output(keypad[pos])
        else
            pos += DIRECTION[k]
            if get(keypad, pos, NIL) === NIL
                throw("Panic!")
            end
        end
    end

    function f(seq::AbstractString)
        seq |> collect .|> f
        return nothing
    end

    f(::Type{Cmd{:set!}}, k::Key) = pos = findfirst(isequal(k), keypad)
    f(::Type{Cmd{:get}}) = keypad[pos]
    f(::Type{Cmd{:reset!}}) = f(Cmd{:set!}, 'A')

    return f
end

function gen_cmd(robots::Vector{Keypad}, seq::AbstractString)
    isempty(robots) && return seq
    join(gen_cmd(robots, a, b) for (a, b) in zip('A' * seq[1:end-1], seq[1:end]))
end

function gen_cmd(robots::Vector{Keypad}, a::Key, b::Key)
    r = robots[1]
    pos1 = findfirst(isequal(a), r)
    pos2 = findfirst(isequal(b), r)
    delta = pos2 - pos1
    if delta == Pos(0, 0)
        return "A"
    end
    seq1 = repeat((delta[1] > 0 ? 'v' : '^'), abs(delta[1]))
    seq2 = repeat((delta[2] > 0 ? '>' : '<'), abs(delta[2]))
    delta[1] == 0 && return gen_cmd(robots[2:end], seq2 * 'A')
    delta[2] == 0 && return gen_cmd(robots[2:end], seq1 * 'A')

    if r[pos1 + Pos(delta[1], 0)] === missing
        return gen_cmd(robots[2:end], seq2 * seq1 * 'A')
    end
    if r[pos1 + Pos(0, delta[2])] === missing
        return gen_cmd(robots[2:end], seq1 * seq2 * 'A')
    end

    # it shouldn't matter which direction to move first
    p = gen_cmd(robots[2:end], seq1 * seq2 * 'A')
    q = gen_cmd(robots[2:end], seq2 * seq1 * 'A')
    length(p) < length(q) ? p : q
end


function complexity(robots::Vector{Keypad}, robotid::Int, seq::AbstractString)
    complexity(robots, robotid, seq, Dict{Tuple{Int,Char,Char},Int}())
end

function complexity(robots::Vector{Keypad}, robotid::Int, seq::AbstractString, cache)
    robotid == 0 && return length(seq)
    sum(complexity(robots, robotid, a, b, cache) for (a, b) in zip('A' * seq[1:end-1], seq[1:end]))
end

macro cached_return(x)
    esc(:(cache[(id, a, b)] = $x; return $x))
end

function complexity(robots::Vector{Keypad}, id::Int, a::Key, b::Key, cache)
    if (id, a, b) ∈ keys(cache)
        return cache[(id, a, b)]
    end

    r = robots[id]
    pos1 = findfirst(isequal(a), r)
    pos2 = findfirst(isequal(b), r)
    delta = pos2 - pos1
    if delta == Pos(0, 0)
        return cache[(id, a, b)] = 1
    end
    seq1 = repeat((delta[1] > 0 ? 'v' : '^'), abs(delta[1]))
    seq2 = repeat((delta[2] > 0 ? '>' : '<'), abs(delta[2]))
    delta[1] == 0 && return cache[(id, a, b)] = complexity(robots, id-1, seq2 * 'A', cache)
    delta[2] == 0 && return cache[(id, a, b)] = complexity(robots, id-1, seq1 * 'A', cache)

    if r[pos1 + Pos(delta[1], 0)] === missing
        return cache[(id, a, b)] = complexity(robots, id-1, seq2 * seq1 * 'A', cache)
    end
    if r[pos1 + Pos(0, delta[2])] === missing
        return cache[(id, a, b)] = complexity(robots, id-1, seq1 * seq2 * 'A', cache)
    end

    p = complexity(robots, id-1, seq1 * seq2 * 'A', cache)
    q = complexity(robots, id-1, seq2 * seq1 * 'A', cache)
    return cache[(id, a, b)] = min(p, q)
end

function main(io::IO)
    return nothing
end

end
```
