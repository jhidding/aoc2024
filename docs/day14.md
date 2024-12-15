---
title: Day 14
---

# Day 14

``` {.julia file=test/Day14Spec.jl}
# add tests
```

``` {.julia file=src/Day14.jl}
module Day14

using ..Monads
using ..Parsing

struct Robot
    p::NTuple{2,Int}
    v::NTuple{2,Int}
end

@kwdef struct Box
    size::NTuple{2,Int} = (101, 103)
end

position(r::Robot) = r.p

Broadcast.broadcastable(m::Box) = Ref(m)

function quadrant(b::Box, p::NTuple{2,Int})
    middle = b.size .÷ 2
    any(p .== middle) && return 0
    sum((p .< middle) .* (1, 2)) + 1
end

quadrant(b::Box) = Base.Fix1(quadrant, b)

move(b::Box, dt::Int, r::Robot) =
    Robot(mod.(r.p .+ dt .* r.v, b.size), r.v)

function safety_factor(b::Box, v::Vector{Robot})
    counts = zeros(Int, 5)
    positions = v .|> (r->r.p)
    @views counts[quadrant.(b, positions) .+ 1] .+= 1
    reduce(*, counts[2:end])
end

function part1(input::Vector{Robot})
    box = Box()
    safety_factor(box, move.(box, 100, input))
end

function read_input(io::IO)
    line_p = fmap(splat(Robot),sequence(
        token(sequence(
            match_p("p=") >>> integer_p,
            match_p(",") >>> integer_p)),
        token(sequence(
            match_p("v=") >>> integer_p,
            match_p(",") >>> integer_p))))
    readlines(io) .|> parse(line_p) .|> result
end

function main(io::IO)
    return nothing
end

end
```
