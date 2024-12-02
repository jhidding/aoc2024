# ~/~ begin <<docs/day01.md#test/Day01Spec.jl>>[init]
using AOC2024.Day01: total_distance, similarity_score, count_sorted, zip_sorted

# ~/~ begin <<docs/day01.md#day01-spec>>[init]
let test_input = [
        3   4;
        4   3;
        2   5;
        1   3;
        3   9;
        3   3]
    a = sort(test_input[:,1])
    b = sort(test_input[:,2])
    @test total_distance(a, b) == 11
    @test similarity_score(a, b) == 31
end
# ~/~ end
# ~/~ begin <<docs/day01.md#count-sorted-spec>>[init]
@test count_sorted([1, 1, 2, 2, 2, 3]) |> collect ==
    [(1, 2), (2, 3), (3, 1)]
# ~/~ end
# ~/~ begin <<docs/day01.md#zip-sorted-spec>>[init]
@test zip_sorted([1, 2, 4, 6], [3, 4, 5, 6]; default=0) |> collect ==
    [(1, 1, 0), (2, 2, 0), (3, 0, 3), (4, 4, 4), (5, 0, 5), (6, 6, 6)]
# ~/~ end
# ~/~ end