# ~/~ begin <<docs/day11.md#src/Day11.jl>>[init]
module Day11

using Memoize: @memoize

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

function main(io::IO)
    input = read(io, String) |> split .|> (x->parse(Int, x))
    part1 = sum(count_stones(x, 25) for x in input)
    part2 = sum(count_stones(x, 75) for x in input)
    return part1, part2
end

end
# ~/~ end
