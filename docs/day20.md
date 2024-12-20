---
title: Day 20
---

# Day 20

``` {.julia file=test/Day20Spec.jl}
using AOC2024.Day20: read_input, Pos, walk_maze, find_cheats, trace_back, part2

let test_txt = """
    ###############
    #...#...#.....#
    #.#.#.#.#.###.#
    #S#...#.#.#...#
    #######.#.#.###
    #######.#.#...#
    #######.#.###.#
    ###..E#...#...#
    ###.#######.###
    #...###...#...#
    #.#####.#.###.#
    #.#...#.#.#...#
    #.#.#.#.#.#.###
    #...#...#...###
    ###############"""

    maze = read_input(IOBuffer(test_txt))
    @test maze.start_tile == Pos(2, 4)
    hist = part2(maze)
    hist_arr = sort(filter(((k, v),) -> k >= 50, hist)) |> stack
    target = [50  52  54  56  58  60  62  64  66  68  70  72  74  76;
              32  31  29  39  25  23  20  19  12  14  12  22   4   3]
    @test hist_arr == target
end
```

``` {.julia file=src/Day20.jl}
module Day20

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
        istarget(current) && return (distance=distance, route=prev, target=current)
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
    return nothing
end

const PosDist = Tuple{Pos,Int}

function find_cheats(m::Maze, start::Pos)
    visited = falses(size(m.map))
    queue = Queue{PosDist}()
    enqueue!(queue, (start, 0))
    result = PosDist[]

    while !isempty(queue)
        p, d = dequeue!(queue)
        d += 1
        d > 20 && return result

        for nb in NB
            q = p + nb
            checkbounds(Bool, m.map, q) || continue
            visited[q] && continue
            visited[q] = true
            if m.map[q] == '.'
                push!(result, (q, d))
            end
            # q == m.end_tile && continue
            enqueue!(queue, (q, d))
        end
    end
    return result
end

function trace_back(prev, start, target)
  route = [target]
  current = target
  while current != start
    current = prev[current]
    push!(route, current)
  end
  reverse(route)
end

const NB = [Pos(1, 0), Pos(0, 1), Pos(-1, 0), Pos(0, -1)]

function walk_maze(m::Maze)
    start = [m.start_tile]
    is_target(p::Pos) = p == m.end_tile
    neighbours(p::Pos) = filter(q->m.map[q] != '#', p .+ NB)
    dist_func(p::Pos, q::Pos) = 1
    grid_dijkstra(Int, size(m.map), start, is_target, neighbours, dist_func)
end

function part2(maze::Maze)
    g = walk_maze(maze)
    route = trace_back(g.route, maze.start_tile, g.target)
    hist = Dict{Int, Int}()

    for pos in route
        cheats = find_cheats(maze, pos)
        for (q, d) in cheats
            saved = g.distance[q] - g.distance[pos] - d
            hist[saved] = get(hist, saved, 0) + 1
        end
    end
    return hist
end

function main(io::IO)
    maze = read_input(io)
    g = walk_maze(maze)
    route = trace_back(g.route, maze.start_tile, g.target)
    part1 = 0
    for pos in route
        for nb in NB
            checkbounds(Bool, maze.map, pos+2nb) || continue
            maze.map[pos+nb] == '#' || continue
            maze.map[pos+2nb] == '.' || continue
            g.distance[pos+2nb] - g.distance[pos] >= 102 || continue
            part1 += 1
        end
    end
    part2 = 0
    for pos in route
        cheats = find_cheats(maze, pos)
        for (q, d) in cheats
            g.distance[q] - g.distance[pos] - d >= 100 || continue
            part2 += 1
        end
    end

    return part1, part2
end

end
```
