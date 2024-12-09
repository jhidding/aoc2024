---
title: Day 9
---

# Day 9: Disk Fragmenter

For Part 1, we can solve this without actually defragmenting. We loop through the input from two sides.

``` {.julia #day09-part1}
function checksum(input::Vector{I}) where {I <: Integer}
    <<day09-checksum>>
end
```

We keep track of the `block_id` and `total`,

``` {.julia #day09-checksum}
block_id = 0
total = 0
```

Then define a helper function to increase the checksum:

``` {.julia #day09-checksum}
function add(fid::Int64, fsize::I)
    total += (block_id * fsize + ((fsize - 1) * fsize) ÷ 2) * fid
    block_id += fsize
end
```

Now we loop ever the input, alternating between file blocks and free blocks.

``` {.julia #day09-checksum}
tail_file_id = length(input) ÷ 2
tail_file_size = input[end]

for i in 1:length(input)
    if (i % 2 == 1)
        <<day09-file>>
    else
        <<day09-free-space>>
    end
end
```

In case of a file, we need to check that we're not past the files that we already allocated to previous free space.

``` {.julia #day09-file}
file_id = i ÷ 2
if file_id >= tail_file_id
    add(file_id, tail_file_size)
    return total
end
add(file_id, input[i])
```

If we're in free space, we add from the tail.

``` {.julia #day09-free-space}
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
```

This entire algorithm is quite finicky and sensitive to off-by-one errors, but it seems to work.

# Part 2

For Part 2, I'm afraid we actually have to keep a data structure. I'm encoding the disk as a vector of `(id, len)` pairs, where an id of `-1` corresponds to free space. I'm looping down from high file id, each time using `findprev` to find the position and length of that file. Then `findfirst` to find the earliest gap that fits the file.

``` {.julia #day09-part2}
run_length(input::Vector{Int}) =
    zip(flatten(zip(countfrom(0), repeated(-1))), input) |> collect

function defrag!(rl::Vector{Tuple{Int, Int}})
    m = rl[end][1]
    p = length(rl)
    for i = m:-1:0
        p = findprev(x->x[1] == i, rl, p)
        p === nothing && throw("could not find $(i) in $(rl)")
        t = rl[p][2]
        n = findfirst(((x, y),)->x == -1 && y >= t, @view rl[1:p-1])
        n === nothing && continue

        s = rl[n][2]
        rl[n] = rl[p]
        rl[p] = (-1, t)
        s == t && continue
        insert!(rl, n+1, (-1, s - t))
    end
    return rl
end

function checksum_2(rl::Vector{Tuple{Int, Int}})
    total = 0
    px = 0
    for (i, x) in rl
        if i >= 0
            total += (px * x + ((x-1) * x) ÷ 2) * i
        end
        px += x
    end
    return total
end
```

# Main

``` {.julia file=src/Day09.jl}
module Day09

using .Iterators: zip, flatten, countfrom, repeated

<<day09-part1>>
<<day09-part2>>

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

``` {.julia file=test/Day09Spec.jl}
# add tests
```
