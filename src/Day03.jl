# ~/~ begin <<docs/day03.md#src/Day03.jl>>[init]
module Day03

using ..Monads
using ..Parsing

# ~/~ begin <<docs/day03.md#day03>>[init]
function part1_parser()
    total = 0

    multiply(a, b) = begin
        total += a * b
        pure_p(nothing)
    end

    result(_) = begin
        pure_p(total)
    end

    mul_p = sequence(
        match_p("mul(") >>> integer_p,
        match_p(",") >>> integer_p >> skip(match_p(")"))
    ) >> splat(multiply)
    noise_p = item_p >>> pure_p(nothing)

    repeated(mul_p | noise_p) >> result
end
# ~/~ end
# ~/~ begin <<docs/day03.md#day03>>[1]
function part2_parser()
    enabled = true
    total = 0

    enable(_) = begin enabled = true; pure_p(nothing) end
    disable(_) = begin enabled = false; pure_p(nothing) end
    multiply(a, b) = begin
        total += (enabled ? a * b : 0)
        pure_p(nothing)
    end

    result(_) = begin pure_p(total) end

    do_p = match_p("do()") >> enable
    dont_p = match_p("don't()") >> disable
    mul_p = sequence(
        match_p("mul(") >>> integer_p,
        match_p(",") >>> integer_p >> skip(match_p(")"))
    ) >> splat(multiply)
    noise_p = item_p >>> pure_p(nothing)

    repeated(mul_p | do_p | dont_p | noise_p) >> result
end
# ~/~ end

function main(io::IO)
    text = read(io, String)
    part1 = text |> parse(part1_parser()) |> result
    part2 = text |> parse(part2_parser()) |> result
    return (part1, part2)
end

end
# ~/~ end
