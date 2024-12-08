# ~/~ begin <<docs/day08.md#src/Day08.jl>>[init]
module Day08

using .Iterators: filter, flatten, map, takewhile, countfrom

function group(a::A; skip=()) where {A}
    g = Dict{valtype(A),Vector{keytype(A)}}()
    for (k, v) ∈ pairs(a)
        v ∈ skip && continue
        if v ∉ keys(g)
            g[v] = []
        end
        push!(g[v], k)
    end
    return g
end

all_pairs(x) = ((i, j) for i in x for j in x if (i != j))

function antinodes_1(inbounds)
    f(a::CartesianIndex{2}, b::CartesianIndex{2}) =
        (2a - b, 2b - a)

    f(x::Vector{CartesianIndex{2}}) =
        filter(inbounds, flatten(map(splat(f), all_pairs(x))))

    return f
end

function antinodes_2(inbounds)
    function f(a::CartesianIndex{2}, b::CartesianIndex{2})
        d = b - a
        one_way = (a - i*d for i in countfrom(0))
        other_way = (b + i*d for i in countfrom(0))
        return flatten((takewhile(inbounds, one_way),
                        takewhile(inbounds, other_way)))
    end

    f(x::Vector{CartesianIndex{2}}) =
        flatten(map(splat(f), all_pairs(x)))

    return f
end

function main(io::IO)
    input = io |> readlines |> stack
    g = group(input, skip=('.',))
    inbounds(i) = checkbounds(Bool, input, i)
    part1 = length(
        values(g) .|> antinodes_1(inbounds) |> flatten |> unique)
    part2 = length(
        values(g) .|> antinodes_2(inbounds) |> flatten |> unique)
    return part1, part2
end

end
# ~/~ end
