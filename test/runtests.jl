# ~/~ begin <<docs/tests.md#test/runtests.jl>>[init]
using Test
using Printf

function main()
    include("ParsingSpec.jl")
    @testset "Puzzles" begin
        @testset "Day $i" for i = 1:25
            day_digits = @sprintf("%02u", i)
            include("Day$(day_digits)Spec.jl")
        end
    end
end

main()
# ~/~ end
