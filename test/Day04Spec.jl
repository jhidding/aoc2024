# ~/~ begin <<docs/day04.md#test/Day04Spec.jl>>[init]
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
# ~/~ end
