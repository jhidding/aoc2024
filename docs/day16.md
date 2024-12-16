---
title: Day 16
---

# Day 16

``` {.julia file=test/Day16Spec.jl}
# add tests
```

``` {.julia file=src/Day16.jl}
module Day16

using DataStructures

const Pos = CartesianIndex{2}
const PosDir = CartesianIndex{3}

pos(pd::PosDir) = Pos(pd[1], pd[2])
dir(pd::PosDir) = pd[3]
posdir(p::Pos, d::Int) = CartesianIndex(p[1], p[2], d)

struct Maze
    map::Matrix{Char}
    start_tile::Pos
    end_tile::Pos
end

function read_input(io::IO)
    map = io |> readlines |> stack
    start_tile = findfirst(isequal('S'), map)
    end_tile = findfirst(isequal('E'), map)
    map[start_tile] = '.'
    map[end_tile] = '.'
    return Maze(map, start_tile, end_tile)
end

function grid_dijkstra(
    ::Type{T}, size::NTuple{Dim,Int},
    start::Vector{CartesianIndex{Dim}}, istarget::F1,
    neighbours::F2, dist_func::F3) where {T,Dim,F1,F2,F3}

    visited = falses(size...)
    distance = fill(typemax(T), size)
    queue = PriorityQueue{CartesianIndex{Dim},T}()
    prev = Array{CartesianIndex{Dim},Dim}(undef, size)

    for s in start
        distance[s] = zero(T)
        enqueue!(queue, s, zero(T))
    end
    current = nothing
    while !isempty(queue)
        current = dequeue!(queue)
        istarget(current) && break
        visited[current] && continue
        for loc in neighbours(current)
            visited[loc] && continue
            d = distance[current] + dist_func(current, loc)
            if d < distance[loc]
                distance[loc] = d
                prev[loc] = current
                queue[loc] = d
            end
        end
        visited[current] = true
    end
    (distance=distance, route=prev, target=current)
end

function trace_back_all(gd, start, neighbours, dist_func)
    visited = falses(size(gd.distance)...)
    stack = [gd.target]
    while !isempty(stack)
        pt = pop!(stack)
        visited[pt] && continue
        visited[pt] = true
        pt == start && continue
        optimal = gd.route[pt]
        for nb in neighbours(pt)
            if gd.distance[pt] == gd.distance[nb] + dist_func(nb, pt)
                push!(stack, nb)
            end
        end
    end
    return visited
end

const NB = [Pos(1, 0), Pos(0, 1), Pos(-1, 0), Pos(0, -1)]
const EAST = 1

function main(io::IO)
    maze = read_input(io)
    is_target(a::PosDir) = pos(a) == maze.end_tile
    path_tile(a::PosDir) = maze.map[pos(a)] == '.'
    neighbours(a::PosDir) = filter(path_tile,
        [posdir(pos(a) + NB[dir(a)], dir(a)),
         posdir(pos(a), mod1(dir(a) + 1, 4)),
         posdir(pos(a), mod1(dir(a) - 1, 4))])
    dist_func(a::PosDir, b::PosDir) = abs(a[1]-b[1]) + abs(a[2]-b[2]) +
        min(mod(a[3] - b[3], 4), mod(b[3] - a[3], 4)) * 1000

    gd = grid_dijkstra(Int, (size(maze.map)..., 4),
        [posdir(maze.start_tile, EAST)],
        is_target, neighbours, dist_func)

    part1 = gd.distance[gd.target]

    rev_neighbours(a::PosDir) = filter(path_tile,
        [posdir(pos(a) - NB[dir(a)], dir(a)),
         posdir(pos(a), mod1(dir(a) + 1, 4)),
         posdir(pos(a), mod1(dir(a) - 1, 4))])

    trace = trace_back_all(gd, posdir(maze.start_tile, EAST),
        rev_neighbours, dist_func)

    part2 = reduce(|, trace, dims=3) |> sum

    return part1, part2
end

end
```
