# ~/~ begin <<docs/index.md#src/AOC2024.jl>>[init]
module AOC2024

include("Monads.jl")
include("Parsing.jl")

function include_all_days()
    for f in readdir(@__DIR__)
        if !isnothing(match(r"Day\d{2}\.jl", f))
            include(f)
        end
    end
end

include_all_days()

function run_all()
end

end
# ~/~ end
