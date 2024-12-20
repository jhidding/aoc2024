# ~/~ begin <<docs/day20.md#test/Day20Spec.jl>>[init]
using AOC2024.Day20: read_input, Pos, walk_maze, find_cheats, trace_back, part2

let test_txt = """
    ###############
    #...#...#.....#
    #.#.#.#.#.###.#
    #S#...#.#.#...#
    #######.#.#.###
    #######.#.#...#
    #######.#.###.#
    ###..E#...#...#
    ###.#######.###
    #...###...#...#
    #.#####.#.###.#
    #.#...#.#.#...#
    #.#.#.#.#.#.###
    #...#...#...###
    ###############"""

    maze = read_input(IOBuffer(test_txt))
    @test maze.start_tile == Pos(2, 4)
    hist = part2(maze)
    hist_arr = sort(filter(((k, v),) -> k >= 50, hist)) |> stack
    target = [50  52  54  56  58  60  62  64  66  68  70  72  74  76;
              32  31  29  39  25  23  20  19  12  14  12  22   4   3]
    @test hist_arr == target
end
# ~/~ end
