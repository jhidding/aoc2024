# ~/~ begin <<docs/day04.md#src/Day04.jl>>[init]
module Day04

using LinearAlgebra: diag

# ~/~ begin <<docs/day04.md#day04-part1>>[init]
read_input(io::IO) = read(io, String) |> split .|> collect |> stack

sliding_window(vec::AbstractVector, n) =
    ((@view vec[i:i+n-1]) for i in 1:length(vec)-n+1)

function diagonals(mat::AbstractMatrix)
    (n, m) = size(mat)
    (diag(mat, i) for i in -n+1:m-1)
end

count_xmas(vec::AbstractVector{Char}) =
    sum((join(w) == "XMAS" || join(w) == "SAMX"
         for w in sliding_window(vec, 4)), init=0)

count_xmas(mat::AbstractMatrix{Char}) =
    sum(count_xmas.(eachcol(mat))) +
    sum(count_xmas.(eachrow(mat))) +
    sum(count_xmas.(diagonals(mat))) +
    sum(count_xmas.(diagonals(mat[:,end:-1:1])))
# ~/~ end
# ~/~ begin <<docs/day04.md#day04-part2>>[init]
function sliding_window(mat::AbstractMatrix, w)
    (n, m) = size(mat)
    ((@view mat[i:i+w-1,j:j+w-1]) for i in 1:n-w+1, j in 1:m-w+1)
end

function check_x_mas(mat::AbstractMatrix)
    a = join(diag(mat))
    b = join(diag(mat[:,end:-1:1]))
    (a == "MAS" || a == "SAM") && (b == "MAS" || b == "SAM")
end

count_x_mas(mat::AbstractMatrix) =
    sliding_window(mat, 3) .|> check_x_mas |> sum
# ~/~ end

function main(io::IO)
    input = read_input(io)
    return count_xmas(input), count_x_mas(input)
end

end
# ~/~ end
