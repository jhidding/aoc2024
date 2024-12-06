# ~/~ begin <<docs/day06.md#src/Day06.jl>>[init]
module Day06

# ~/~ begin <<docs/day06.md#day06>>[init]
struct State
    pos::CartesianIndex{2}
    dir::CartesianIndex{2}
end

position(s::State) = s.pos
direction(s::State) = s.dir
turn_right(d::CartesianIndex{2}) = CartesianIndex(-d[2], d[1])
turn_right(s::State) = State(s.pos, turn_right(s.dir))
forward(s::State) = State(s.pos + s.dir, s.dir)

struct Walk
    field::Matrix{Char}
    start::State
end

function read_input(io::IO)
    field = read(io, String) |> split .|> collect |> stack
    start = findfirst((==)('^'), field)
    field[start] = '.'
    return Walk(field, State(start, CartesianIndex(0, -1)))
end
# ~/~ end
# ~/~ begin <<docs/day06.md#day06>>[1]
Base.iterate(walk::Walk) = iterate(walk, walk.start)

function Base.iterate(walk::Walk, s::State)
    next = forward(s)
    !checkbounds(Bool, walk.field, position(next)) && return nothing

    if walk.field[position(next)] == '#'
        next = turn_right(s)
    end

    (next, next)
end

Base.IteratorSize(::Walk) = Base.SizeUnknown()
# ~/~ end
# ~/~ begin <<docs/day06.md#day06>>[2]
function detect_loop(walk::Walk)
    state_set = Set{State}()
    for s in walk
        s ∈ state_set && return true
        push!(state_set, s)
    end
    return false
end
# ~/~ end
# ~/~ begin <<docs/day06.md#day06>>[3]
function possible_loop_points(walk::Walk)
    obstructions = Set{CartesianIndex{2}}()
    for s in walk
        t = position(forward(s))
        (!checkbounds(Bool, walk.field, t) ||
         t == position(walk.start) ||
         walk.field[t] == '#') && continue

        f = copy(walk.field)
        f[t] = '#'
        detect_loop(Walk(f, walk.start)) &&
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
