# ~/~ begin <<docs/day02.md#test/Day02Spec.jl>>[init]
using AOC2024.Day02: safe_report, tolerant_safe_report

let input = [
    7 6 4 2 1;
    1 2 7 8 9;
    9 7 6 2 1;
    1 3 2 4 5;
    8 6 4 4 1;
    1 3 6 7 9]

    @test safe_report.(eachrow(input)) |> sum == 2
    @test tolerant_safe_report.(eachrow(input)) |> sum == 4
end
# ~/~ end
