# ~/~ begin <<docs/day09.md#src/Day09.jl>>[init]
module Day09

using .Iterators: zip, flatten, countfrom, repeated

# ~/~ begin <<docs/day09.md#day09-part1>>[init]
function checksum(input::Vector{I}) where {I <: Integer}
    # ~/~ begin <<docs/day09.md#day09-checksum>>[init]
    block_id = 0
    total = 0
    # ~/~ end
    # ~/~ begin <<docs/day09.md#day09-checksum>>[1]
    function add(fid::Int64, fsize::I)
        total += (block_id * fsize + ((fsize - 1) * fsize) ÷ 2) * fid
        block_id += fsize
    end
    # ~/~ end
    # ~/~ begin <<docs/day09.md#day09-checksum>>[2]
    tail_file_id = length(input) ÷ 2
    tail_file_size = input[end]

    for i in 1:length(input)
        if (i % 2 == 1)
            # ~/~ begin <<docs/day09.md#day09-file>>[init]
            file_id = i ÷ 2
            if file_id >= tail_file_id
                add(file_id, tail_file_size)
                return total
            end
            add(file_id, input[i])
            # ~/~ end
        else
            # ~/~ begin <<docs/day09.md#day09-free-space>>[init]
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
            # ~/~ end
        end
    end
    # ~/~ end
end
# ~/~ end
# ~/~ begin <<docs/day09.md#day09-part2>>[init]
run_length(input::Vector{Int}) =
    zip(flatten(zip(countfrom(0), repeated(-1))), input) |> collect

function defrag!(rl::Vector{Tuple{Int, Int}})
    max_file_id = rl[end][1]
    ptr = length(rl)
    for file_id = max_file_id:-1:0
        # update ptr and file_size to entry matching file_id
        ptr = findprev(((id, _),)->id == file_id, rl, ptr)
        ptr === nothing && throw("could not find $(file_id) in $(rl)")
        file_size = rl[ptr][2]

        # find a gap large enough
        free_block = findfirst(
            ((id, sz),)->id == -1 && sz >= file_size,
            @view rl[1:ptr-1])
        free_block === nothing && continue

        free_size = rl[free_block][2]
        rl[free_block] = rl[ptr]
        rl[ptr] = (-1, file_size)
        file_size == free_size && continue
        insert!(rl, free_block + 1, (-1, free_size - file_size))
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
# ~/~ end

function main(io::IO)
    input = collect(strip(read(io, String))) .- '0'
    part1 = checksum(input)
    rl = run_length(input)
    defrag!(rl)
    part2 = checksum_2(rl)
    return part1, part2
end

end
# ~/~ end
