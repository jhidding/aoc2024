---
title: Day 4
---

# Day 4: Ceres Search
In Part 1, we're scanning a matrix of characters for the word "XMAS". I implemented a `sliding_window` iterator for a vector, and ran it over the rows, columns, diagonals and anti-diagonals of the matrix.

``` {.julia #day04-part1}
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
```

In Part 2, we need to find a two-dimensional pattern: diagonally crossing "MAS". Made a `sliding_window` that slides in two dimensions.

``` {.julia #day04-part2}
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
```

## Main and tests

``` {.julia file=test/Day04Spec.jl}
using AOC2024.Day04: sliding_window, count_xmas, count_x_mas
let raw_input = """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """
    input = raw_input |> split .|> strip .|> collect |> stack
    @test join(input[:,1]) == "MMMSXXMASM"
    @test count_xmas(input[:,1]) == 1
    @test count_xmas(input[:,5]) == 2
    @test count_xmas(input) == 18
    @test count_x_mas(input) == 9
end
```

``` {.julia file=src/Day04.jl}
module Day04

using LinearAlgebra: diag

<<day04-part1>>
<<day04-part2>>

function main(io::IO)
    input = read_input(io)
    return count_xmas(input), count_x_mas(input)
end

end
```
