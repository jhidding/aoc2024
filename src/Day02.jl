# ~/~ begin <<docs/day02.md#src/Day02.jl>>[init]
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
# ~/~ end
