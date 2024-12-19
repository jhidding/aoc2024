---
title: Day 18
---

# Day 18

``` {.julia file=test/Day18Spec.jl}
# add tests
```

``` {.julia file=src/Day18.jl}
module Day18

using DataStructures

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

const Pos = CartesianIndex{2}

function trace_back(prev, start, target)
  route = [target]
  current = target
  while current != start
    current = prev[current]
    push!(route, current)
  end
  reverse(route)
end

function main(io::IO)
    input = readlines(open("data/day18.txt")) .|>
        (x->CartesianIndex((parse.(Int, split(x,',')) .+ 1)...))

    m = zeros(Int, 71, 71)
    m[input[1:1024]] .= 1

    is_target(p::Pos) = p == Pos(71, 71)
    neighbours(p::Pos) =
        filter(q->get(m, q, 1) == 0,
            [p + Pos(1, 0), p + Pos(0, 1),
             p + Pos(-1,0), p + Pos(0,-1)])
    dist_func(a::Pos, b::Pos) = sum(abs.(Tuple(a - b)))

    g = grid_dijkstra(Int, (71, 71), [Pos(1, 1)], is_target, neighbours, dist_func)

    part1 = g.distance[g.target]

    part2 = nothing
    tb = trace_back(g.route, Pos(1, 1), Pos(71, 71))
    tg = falses(71, 71)
    tg[tb] .= true
    for p in input[1025:end]
        m[p] = 1
        tg[p] || continue
        g = grid_dijkstra(Int, (71, 71), [Pos(1, 1)], is_target, neighbours, dist_func)
        if g === nothing
            part2 = p
            break
        end
        tg .= false
        tb = trace_back(g.route, Pos(1, 1), Pos(71, 71))
        tg[tb] .= true

    end

    return part1, (part2[1]-1, part2[2]-1)
end

end
```
