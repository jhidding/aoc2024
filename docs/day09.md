---
title: Day 9
---

# Day 9

``` {.julia file=test/Day09Spec.jl}
# add tests
```

``` {.julia file=src/Day09.jl}
module Day09

using .Iterators: zip, flatten, countfrom, repeated

function checksum(input::Vector{I}) where {I <: Integer}
    block_id = 0
    tail_file_id = length(input) ÷ 2
    tail_file_size = input[end]
    total = 0

    function add(fid::Int64, fsize::I)
        total += (block_id * fsize + ((fsize - 1) * fsize) ÷ 2) * fid
        block_id += fsize
    end

    for i in 1:length(input)
        if (i % 2 == 1)
            # file
            file_id = i ÷ 2
            if file_id >= tail_file_id
                add(file_id, tail_file_size)
                return total
            end
            add(file_id, input[i])
        else
            # free space
            gap = input[i]

            while gap > tail_file_size
                add(tail_file_id, tail_file_size)
                gap -= tail_file_size
                tail_file_id -= 1
                if tail_file_id == i ÷ 2 - 1
                    return total
                end
                tail_file_size = input[tail_file_id*2 + 1]
            end

            add(tail_file_id, gap)
            tail_file_size -= gap
        end
    end
end

run_length(input::Vector{Int}) =
    zip(flatten(zip(countfrom(0), repeated(-1))), input) |> collect

function defrag!(rl::Vector{Tuple{Int, Int}})
    m = rl[end][1]
    p = length(rl)
    for i = m:-1:0
        p = findprev(x->x[1] == i, rl, p)
        p === nothing && throw("could not find $(i) in $(rl)")
        n = findfirst(x->x[1] == -1 && x[2] >= rl[p][2], rl[1:p-1])
        n === nothing && continue

        s = rl[n][2]
        rl[n] = rl[p]
        insert!(rl, n+1, (-1, rl[n][2] - rl[p][2]))
        rl[p] = (-1, rl[p][2])
    end
end

function checksum_2(rl::Vector{Tuple{Int, Int}})
    total = 0
    px = 0
    for (i, x) in rl
        if i > 0
            total += (px * x + ((x-1) * x) ÷ 2) * i
        end
        px += x
    end
    return total
end

function main(io::IO)
    input = collect(strip(read(io, String))) .- '0'
    part1 = checksum(input)
    rl = run_length(input)
    defrag!(rl)
    part2 = checksum_2(rl)
    return part1, part2
end

end
```
