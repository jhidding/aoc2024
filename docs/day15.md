---
title: Day 15
---

# Day 15

``` {.julia file=test/Day15Spec.jl}
# add tests
```

``` {.julia file=src/Day15.jl}
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

mutable struct State
    time::Matrix{Int}
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
        state.location += DIRECTION[dir]
    end
    return state
end

function part1(input)
    start = findfirst(isequal('@'), input.map)
    s = State(ones(Int, size(input.map)...), copy(input.map), start)
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

function attempt_move2!(w::Matrix{Char}, box::Pos, dir::Char, t::Matrix{Int})
    recur(w, box, tgt) = if w[tgt] == '.' || (w[tgt] ∈ "[]" && attempt_move2!(w, tgt, dir, t))
        swap!(w, box, tgt)
        t[box] = 0
        t[tgt] = 0
        true
    else
        false
    end

    tgt = box + DIRECTION[dir]
    if dir == '<' || dir == '>' || w[box] == '@'
        return recur(w, box, tgt)
    else
        @assert w[box] ∈ "[]"
        offset = w[box] == '[' ? Pos(1, 0) : Pos(-1, 0)
        u = copy(w)
        recur(u, box + offset, tgt + offset) || return false
        recur(u, box, tgt) || return false
        w[:, :] = u
        return true
    end
end

ansi_color(r, g, b) = "\033[38;2;$(r);$(g);$(b)m"

macro c_str(s)
    r = parse(Int, s[1:2], base=16)
    g = parse(Int, s[3:4], base=16)
    b = parse(Int, s[5:6], base=16)
    ansi_color(r, g, b)
end

const IridiscentColors = [
    c"FEFBE9", c"FCF7D5", c"F5F3C1", c"EAF0B5", c"DDECBF", c"D0E7CA", c"C2E3D2",
    c"B5DDD8", c"A8D8DC", c"9BD2E1", c"8DCBE4", c"81C4E7", c"7BBCE7", c"7EB2E4",
    c"88A5DD", c"9398D2", c"9B8AC4", c"9D7DB2", c"9A709E", c"906388", c"805770",
    c"684957", c"46353A" ]


function pretty_print(m::Matrix{Char}, t::Matrix{Int})
    PPMAP = Dict{Char,String}(
        '@' => "$(c"88FFCC")\033[1m@\033[m",
        '#' => "$(c"114488")█\033[m",  # █
        '.' => " ",
        '[' => "[",
        ']' => "]"
    )

    tr(c, t) = let s = get(PPMAP, c, "$c"),
                   f = IridiscentColors[min(t, length(IridiscentColors) - 4)]
        c ∈ "[]" ? "$(f)$(s)\033[m" : s
    end

    for i in keys(m)
        if t[i] % 8 == 0 && t[i] < 160
            print("\033[$(i[2]);$(i[1])H")
            print(tr(m[i], t[i] ÷ 8 + 1))
        end
    end
    # print("\033[1;1H")
    # println(join(zip(m, t .÷ 8 .+ 1) .|> splat(tr) |> eachcol .|> join, "\n"))
    flush(stdout)
    sleep(0.005)
end

function attempt_move2!(state::State, dir::Char)
    state.time .+= 1
    if attempt_move2!(state.warehouse, state.location, dir, state.time)
        state.location += DIRECTION[dir]
        pretty_print(state.warehouse, state.time)
    end
    return state
end

function part2(input)
    print("\033[2J\033[?25l")
    emap = expand_map(input.map)
    start = findfirst(isequal('@'), emap)
    s = State(ones(Int, size(emap)...).*151, emap, start)
    s = foldl(attempt_move2!, input.movements; init=s)
    print("\033[?25h")
    (Tuple.(findall(isequal('['), s.warehouse) .- CartesianIndex(1, 1)) |>
        stack)' * [1; 100] |> sum
end

function main(io::IO)
    input = read_input(io)
    part1(input), part2(input)
end

end
```
