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
            oldpos = pos
            pos += DIRECTION[k]
            if get(keypad, pos, NIL) === NIL
                pos = oldpos
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

function complexity(from::Key, to::Key)
    r1 = robot(NUMPAD, identity)
    r2 = robot(CONTROLLER, r1)
    r3 = robot(CONTROLLER, r2)

    r1(Cmd{:set!}, from)
    queue = Queue{NTuple{3,Key}}()


end

function main(io::IO)
    return nothing
end

end
```
