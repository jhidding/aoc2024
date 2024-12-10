# ~/~ begin <<docs/day10.md#src/Day10.jl>>[init]
module Day10

const nb = CartesianIndex.([(-1, 0), (0, -1), (1, 0), (0, 1)])

function neighbours(input::Matrix{Int}, a::CartesianIndex{2})
    inbounds(b) = checkbounds(Bool, input, b)
    legal(b) = inbounds(b) && input[b] - input[a] == 1
    filter(legal, a .+ nb)
end

function trail_head_score(input::Matrix{Int}, a::CartesianIndex{2})
    s = CartesianIndex{2}[a]
    v = zeros(Bool, size(input)...)
    score = 0
    while !isempty(s)
        x = pop!(s)

        if input[x] == 9
            score += 1
            continue
        end
        for n in neighbours(input, x)
            v[n] && continue
            pushfirst!(s, n)
            v[n] = true
        end
    end
    return score
end

function scores(input::Matrix{Int})
    result = zeros(Int, size(input)...)
    result[input.==9] .= 1
    for x = 8:-1:0
        for p in keys(result)
            input[p] == x || continue
            for n in neighbours(input, p)
                result[p] += result[n]
            end
        end
    end
    return result
end

read_input(io::IO) = readlines(io) .|> collect .|> (l->l.-'0') |> stack

function main(io::IO)
    input = read_input(io)
    part1 = sum(trail_head_score(input, x) for x in keys(input)
                if input[x] == 0)
    part2 = sum(scores(input)[input .== 0])
    return part1, part2
end

end
# ~/~ end
