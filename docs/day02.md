---
title: Day 2
---

# Day 2

``` {.julia file=test/Day02Spec.jl}
using AOC2024.Day02: safe_report

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

function stencil1d3(v::AbstractVector{Int}, kernel::F) where {F}
    result = zeros(Int, length(v))
    result[1] = kernel(v[1:2]...)
    for i = 2:(length(v)-1)
        result[i] = kernel(v[i-1:i+1]...)
    end
    result[end] = kernel(v[end-1:end]...)
    return result
end

function tolerant_safe_report(v::AbstractVector{Int})
    ok(d) = (1 <= d) && (d <= 3)
    kernel(a, b) = ok(b - a) ? 0 : 1
    kernel(a, b, c) = (ok(b - a) && ok(c - b)) ? 0 : (ok(c - a) ? 1 : 2)
    check(v) = sum(stencil1d3(v, kernel)) <= 1
    check(v) || check(.-v)
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
