# ~/~ begin <<docs/day13.md#src/Day13.jl>>[init]
module Day13

using ..Monads
using ..Parsing

struct PrizeMachine
    a::Tuple{Int,Int}
    b::Tuple{Int,Int}
    p::Tuple{Int,Int}
end

function solve(pm::PrizeMachine)
    d = pm.a[1] * pm.b[2] - pm.a[2] * pm.b[1]
    x = pm.b[2] * pm.p[1] - pm.b[1] * pm.p[2]
    y = pm.a[1] * pm.p[2] - pm.a[2] * pm.p[1]
    ((x % d == 0) && (y % d == 0)) || return nothing
    (div(x, d), div(y, d))
end

function part1(input::Vector{PrizeMachine})
    p = input .|> solve |> filter(!isnothing) |> stack
    p' * [3; 1] |> sum
end

function modify(pm::PrizeMachine)
    PrizeMachine(pm.a, pm.b, pm.p .+ 10000000000000)
end

function part2(input::Vector{PrizeMachine})
    input .|> modify |> part1
end

button_p(label::String) = sequence(
    match_p("Button $label: X+") >>> integer_p,
    match_p(", Y+") >>> integer_p)

prize_p() = sequence(
    match_p("Prize: X=") >>> integer_p,
    match_p(", Y=") >>> integer_p)

prize_machine_p() = fmap(splat(PrizeMachine), sequence(
    button_p("A"),
    match_p("\n") >>> button_p("B"),
    match_p("\n") >>> prize_p()))

read_input(io::IO) =
    read(io, String) |>
        parse(sep_by_p(prize_machine_p(), match_p("\n\n"))) |>
        result

function main(io::IO)
    input = read_input(io)
    part1(input), part2(input)
end

end
# ~/~ end
