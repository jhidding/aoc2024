# ~/~ begin <<docs/day13.md#src/Day13.jl>>[init]
module Day13

using ..Monads
using ..Parsing

struct PrizeMachine
    button_a::Tuple{Int,Int}
    button_b::Tuple{Int,Int}
    prize::Tuple{Int,Int}
end

function close_to_integer(f, eps=1e-6)
    abs(f - round(f)) < eps
end

function solve(pm::PrizeMachine)
    A = Int[pm.button_a[1] pm.button_b[1];
            pm.button_a[2] pm.button_b[2]]
    y = Int[pm.prize...]
    x = A \ y
    # all(close_to_integer.(x)) ?
    #     Tuple(Int.(round.(x))) : nothing
end

function part1(input::Vector{PrizeMachine})
    p = solve.(input) |> filter(!isnothing) |> stack
    p' * [3; 1] |> sum
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
    return nothing
end

end
# ~/~ end
