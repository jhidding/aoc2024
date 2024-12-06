# ~/~ begin <<docs/day06.md#src/Day06.jl>>[init]
module Day06

# ~/~ begin <<docs/day06.md#day06>>[init]
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
# ~/~ end
# ~/~ begin <<docs/day06.md#day06>>[1]
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
# ~/~ end
# ~/~ begin <<docs/day06.md#day06>>[2]
function detect_loop(walk::Walk, state_set::BitArray{3})
    state_set .= 0
    for s in walk
        p = Tuple(position(s))
        state_set[p..., s.dir] && return true
        state_set[p..., s.dir] = true
    end
    return false
end
# ~/~ end
# ~/~ begin <<docs/day06.md#day06>>[3]
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
# ~/~ end

function main(io::IO)
    # ~/~ begin <<docs/day06.md#day06-part1>>[init]
    walk = read_input(io)
    part1 = Iterators.map(position, walk) |> unique |> length
    # ~/~ end
    # ~/~ begin <<docs/day06.md#day06-part2>>[init]
    part2 = walk |> possible_loop_points |> length
    # ~/~ end
    return part1, part2
end

end
# ~/~ end
