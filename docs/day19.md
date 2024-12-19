---
title: Day 19
---

# Day 19

``` {.julia file=test/Day19Spec.jl}
# add tests
```

``` {.julia file=src/Day19.jl}
module Day19

using ..Monads
using ..Parsing

function read_input(io::IO)
    lines = readlines(io) |> collect
    patterns = split(lines[1], ", ")
    designs = lines[3:end]
    return patterns, designs
end

struct Patterns{S} <: Parser
    pat::Vector{S}
end

function Parsing.parse(p::Patterns{S}, s::T) where {S <: AbstractString, T <: AbstractString}
    pats = filter(p->startswith(s, p), p.pat)
    for q in pats
        (r, _) = parse(p, s[length(q)+1:end])
        r || continue
        return true, ""
    end
    false, s
end

function main(io::IO)
    patterns, designs = read_input(io)
    p = parse(Patterns(patterns))
    results = map(p, designs)
    part1 = length(filter(first, results))
    println("Part 1: $part1")
    return results
end

end
```
