# ~/~ begin <<docs/day07.md#src/Day07.jl>>[init]
module Day07

read_input(io::IO) =
    [(parse(Int, a), parse.(Int, split(b)))
     for (a, b) in split.(readlines(io), ':')]

function good_equation_1(x::Int, n::AbstractVector{Int})
    length(n) == 1 && return x == n[1]

    x % n[end] == 0 &&
        good_equation_1(x ÷ n[end], n[1:end-1]) && return true

    return good_equation_1(x - n[end], n[1:end-1])
end

function good_equation_2(x::Int, n::AbstractVector{Int})
    length(n) == 1 && return x == n[1]

    x % n[end] == 0 &&
        good_equation_2(x ÷ n[end], @view n[1:end-1]) && return true

    d = 10^ndigits(n[end])
    (x - n[end]) % d == 0 &&
        good_equation_2((x - n[end]) ÷ d, @view n[1:end-1]) && return true

    return good_equation_2(x - n[end], @view n[1:end-1])
end

function main(io::IO)
    input = read_input(io)
    part1 = sum(r for (r, n) in input if good_equation_1(r, n))
    part2 = sum(r for (r, n) in input if good_equation_2(r, n))
    return part1, part2
end

end
# ~/~ end
