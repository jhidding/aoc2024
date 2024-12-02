# ~/~ begin <<docs/parsing.md#test/ParsingSpec.jl>>[init]
@testset "Parsing" begin
    using AOC2024.Parsing

    # ~/~ begin <<docs/parsing.md#parsing-spec>>[init]
    @test parse(pure_p(3), "abc") == (3, "abc")
    @test parse(pure_p(nothing), "abc") == (nothing, "abc")
    # ~/~ end
    # ~/~ begin <<docs/parsing.md#parsing-spec>>[1]
    @test parse(pure_p(1) >> (x -> pure_p(x + 1)), "abc") == (2, "abc")
    # ~/~ end
    # ~/~ begin <<docs/parsing.md#parsing-spec>>[2]
    @test parse(many(token(integer_p | match_p("abc"))), "123 abc 4 5 abc def") ==
        ([123, "abc", 4, 5, "abc"], "def")
    # ~/~ end
    # ~/~ begin <<docs/parsing.md#parsing-spec>>[3]
    @test parse(match_p("hello"), "hellogoodbye") == ("hello", "goodbye")

    p = match_p("a") >>> match_p("b")
    @test parse(p, "abc") == ("b", "c")

    p = sequence(match_p("a"), match_p("b"))
    @test parse(p, "abc") == (("a", "b"), "c")

    #p = sequence(n=match_p("a"), m=match_p("b"))
    #@test parse(p, "abc") == (Dict(:n => "a", :m => "b"), "c")
    @test parse(integer_p, "123abc") == (123, "abc")

    p = many(integer)
    @test parse(p, "1  2 3  4 56    7 abc") == ([1, 2, 3, 4, 56, 7], "abc")
    # ~/~ end
end
# ~/~ end