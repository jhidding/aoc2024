# ~/~ begin <<docs/day21.md#test/Day21Spec.jl>>[init]
using AOC2024.Day21: robot, NUMPAD, CONTROLLER

let buf = Char[],
    out(x) = push!(buf, x),
    r1 = out |> robot(NUMPAD),
    r2 = out |> robot(NUMPAD) |> robot(CONTROLLER),
    r3 = out |> robot(NUMPAD) |> robot(CONTROLLER) |> robot(CONTROLLER)

    r1("<A^A>^^AvvvA")
    @test join(buf) == "029A"
    empty!(buf)
    r2("v<<A>>^A<A>AvA<^AA>A<vAAA>^A")
    @test join(buf) == "029A"
    empty!(buf)
    r3("<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A")
    @test join(buf) == "029A"
end
# ~/~ end
