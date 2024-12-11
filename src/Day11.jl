# ~/~ begin <<docs/day11.md#src/Day11.jl>>[init]
module Day11

using Memoize: @memoize
using DataStructures: DefaultDict

@memoize function count_stones(x::Int, n::Int)
    if n == 0
        1
    elseif x == 0
        count_stones(1, n - 1)
    elseif ndigits(x) % 2 == 0
        f = 10^(ndigits(x) ÷ 2)
        count_stones(x ÷ f, n - 1) + count_stones(x % f, n - 1)
    else
        count_stones(x * 2024, n - 1)
    end
end

function blink(stones::DefaultDict{Int, Int,Int})
    result = DefaultDict{Int,Int,Int}(0)
    for (k, v) in pairs(stones)
        if k == 0
            result[1] += v
        elseif ndigits(k) & 1 == 0
            f = 10^(ndigits(k) >> 1)
            result[k ÷ f] += v
            result[k % f] += v
        else
            result[k * 2024] += v
        end
    end
    return result
end

function count_stones_2(input::Vector{Int}, n::Int)
    counts = DefaultDict{Int,Int,Int}(0)
    for i in input
        counts[i] += 1
    end
    for i = 1:n
        counts = blink(counts)
    end
    return sum(values(counts))
end

function main(io::IO)
    input = read(io, String) |> split .|> (x->parse(Int, x))
    part1 = sum(count_stones(x, 25) for x in input)
    part2 = sum(count_stones(x, 75) for x in input)
    return part1, part2
end

end
# ~/~ end
