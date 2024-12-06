# ~/~ begin <<docs/day06.md#test/Day06Spec.jl>>[init]
using AOC2024.Day06: read_input, possible_loop_points
let testmap = """
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."""
    walk = read_input(IOBuffer(testmap))
    @test walk |> possible_loop_points |> length == 6
end
# ~/~ end
