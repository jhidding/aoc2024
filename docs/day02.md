---
title: Day 2
---

# Day 2
There should be a much much better way to solve part 2, but I'm too tired.

``` {.julia file=test/Day02Spec.jl}
using AOC2024.Day02: safe_report, tolerant_safe_report

let input = [
    7 6 4 2 1;
    1 2 7 8 9;
    9 7 6 2 1;
    1 3 2 4 5;
    8 6 4 4 1;
    1 3 6 7 9]

    @test safe_report.(eachrow(input)) |> sum == 2
    @test tolerant_safe_report.(eachrow(input)) |> sum == 4
end
```

``` {.julia file=src/Day02.jl}
module Day02

using ..Monads
using ..Parsing

function safe_report(v::AbstractVector{Int})
    check(d) = all((1 .<= d) .&& (d .<= 3))
    d = v[2:end] .- v[1:end-1]
    check(d) || check(.-d)
end

function tolerant_safe_report(v::AbstractVector{Int})
    safe_report(v) && return true
    for i in 1:length(v)
        w = deleteat!(copy(v), i)
        safe_report(w) && return true
    end
    return false
end

read_input(io::IO) =
    read(io, String) |> parse(many(
        token(many(token(integer_p, match_p(r" *"))), match_p("\n"))
    )) |> result

function main(io::IO)
    input = read_input(io)
    part1 = sum(safe_report.(input))
    part2 = sum(tolerant_safe_report.(input))
    return part1, part2
end

end
```
