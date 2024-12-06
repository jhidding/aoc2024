---
title: Day 6
---

# Day 6
We need to walk a map. I'll define a `State` struct so that we can use Julia's `Iterator` protocol to walk the walk.

``` {.julia #day06}
struct State
    pos::CartesianIndex{2}
    dir::Int
end

const DIRECTIONS = [
    CartesianIndex(0, -1), CartesianIndex(1, 0),
    CartesianIndex(0, 1), CartesianIndex(-1, 0)]

position(s::State) = s.pos
direction(s::State) = DIRECTIONS[s.dir]
turn_right(d::Int) = mod1(d+1, 4)
turn_right(s::State) = State(s.pos, turn_right(s.dir))
forward(s::State) = State(s.pos + direction(s), s.dir)

struct Walk
    field::Matrix{Char}
    start::State
    extra::Union{CartesianIndex,Nothing}
end

function read_input(io::IO)
    field = read(io, String) |> split .|> collect |> stack
    start = findfirst((==)('^'), field)
    field[start] = '.'
    return Walk(field, State(start, 1), nothing)
end
```

In this case (unlike [Day 01](day01.md)), Julia's Iterator interface gives us a very compact way to write down our solution.

``` {.julia #day06}
Base.iterate(walk::Walk) = iterate(walk, walk.start)

function Base.iterate(walk::Walk, s::State)
    next = forward(s)
    !checkbounds(Bool, walk.field, position(next)) && return nothing

    if walk.field[position(next)] == '#' ||
       position(next) == walk.extra
        next = turn_right(s)
    end

    (next, next)
end

Base.IteratorSize(::Walk) = Base.SizeUnknown()
```

## Part 1

Part 1 is now a one-liner:

``` {.julia #day06-part1}
walk = read_input(io)
part1 = Iterators.map(position, walk) |> unique |> length
```

## Part 2
In Part 2 we need to find all places to place a box, such that we create a loop. I tried to be smart about this, but kept failing at that. The `detect_walk` function walks the walk until a state is repeated.

``` {.julia #day06}
function detect_loop(walk::Walk, state_set::BitArray{3})
    state_set .= 0
    for s in walk
        p = Tuple(position(s))
        state_set[p..., s.dir] && return true
        state_set[p..., s.dir] = true
    end
    return false
end
```

Then we try every position along the original path and put a box in front of it. We need to take care that the box doesn't end up outside the field, on the starting position or on top of another box.

``` {.julia #day06}
function possible_loop_points(walk::Walk)
    obstructions = Set{CartesianIndex{2}}()
    state_set = BitArray(undef, size(walk.field)..., 4)
    for s in walk
        t = position(forward(s))
        (!checkbounds(Bool, walk.field, t) ||
         t == position(walk.start) ||
         walk.field[t] == '#') && continue

        detect_loop(Walk(walk.field, walk.start, t), state_set) &&
            push!(obstructions, t)
    end
    return obstructions
end
```

This is not very fast,

``` {.julia #day06-part2}
part2 = walk |> possible_loop_points |> length
```

## Main and test

``` {.julia file=src/Day06.jl}
module Day06

<<day06>>

function main(io::IO)
    <<day06-part1>>
    <<day06-part2>>
    return part1, part2
end

end
```

``` {.julia file=test/Day06Spec.jl}
using AOC2024.Day06: read_input, possible_loop_points
let testmap = """
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."""
    walk = read_input(IOBuffer(testmap))
    @test walk |> possible_loop_points |> length == 6
end
```
