# ~/~ begin <<docs/day15.md#src/Day15.jl>>[init]
module Day15

function read_input(io::IO)
    text = read(io, String)
    map_text, movements_text = split(text, "\n\n")

    warehouse_map = map_text |> split |> stack
    movements = movements_text |> split |> join

    return (map=warehouse_map, movements=movements)
end

const Pos = CartesianIndex{2}
const DIRECTION = Dict{Char,Pos}(
    '^' => Pos(0, -1),
    'v' => Pos(0,  1),
    '<' => Pos(-1, 0),
    '>' => Pos( 1, 0))

struct State
    warehouse::Matrix{Char}
    location::Pos
end

@inline function swap!(f::AbstractArray{T,N}, a::CartesianIndex{N}, b::CartesianIndex{N}) where {T, N}
    temp = f[a]
    f[a] = f[b]
    f[b] = temp
end

function attempt_move1!(w::Matrix{Char}, box::Pos, dir::Pos)
    tgt = box + dir
    if (w[tgt] == '.') || (w[tgt] == 'O' && attempt_move1!(w, tgt, dir))
        swap!(w, box, tgt)
        return true
    end
    return false
end

function attempt_move1!(state::State, dir::Char)
    if attempt_move1!(state.warehouse, state.location, DIRECTION[dir])
        return State(state.warehouse, state.location + DIRECTION[dir])
    else
        return state
    end
end

function part1(input)
    start = findfirst(isequal('@'), input.map)
    s = State(copy(input.map), start)
    s = foldl(attempt_move1!, input.movements; init=s)
    (Tuple.(findall(isequal('O'), s.warehouse) .- CartesianIndex(1, 1)) |>
        stack)' * [1; 100] |> sum
end

const REPLACEMENT = Dict(
    '#' => "##", 'O' => "[]", '.' => "..", '@' => "@."
)

function expand_map(m::Matrix{Char})
    expandcol(c) = getindex.((REPLACEMENT,), c) |> Iterators.flatten |> collect
    eachcol(m) .|> expandcol |> stack
end

function attempt_move2!(w::Matrix{Char}, box::Pos, dir::Char)
    tgt = box + DIRECTION[dir]
    if dir == '<' || dir == '>' || w[box] == '@'
        if w[tgt] == '.' || (w[tgt] ∈ "[]" && attempt_move2!(w, tgt, dir))
            swap!(w, box, tgt)
            return true
        end
        return false
    else
        @assert w[box] ∈ "[]"
        other_half = w[box] == '[' ? box + Pos(1, 0) : box - Pos(1, 0)
        u = copy(w)
        attempt_move2!(u, other_half, dir) || return false
        if u[tgt] == '.' || (u[tgt] ∈ "[]" && attempt_move2!(u, tgt, dir))
            swap!(u, box, tgt)
            w[:, :] = u
            return true
        end
        return false
    end
end

function attempt_move2!(state::State, dir::Char)
    if attempt_move2!(state.warehouse, state.location, dir)
        println(join(state.warehouse |> eachcol .|> join, "\n"))
        return State(state.warehouse, state.location + DIRECTION[dir])
    else
        return state
    end
end

function part2(input)
    emap = expand_map(input.map)
    start = findfirst(isequal('@'), emap)
    s = State(emap, start)
    s = foldl(attempt_move2!, input.movements; init=s)
    (Tuple.(findall(isequal('['), s.warehouse) .- CartesianIndex(1, 1)) |>
        stack)' * [1; 100] |> sum
end

function main(io::IO)

end

end
# ~/~ end
