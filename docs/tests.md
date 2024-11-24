---
title: Testing
---

# Testing

``` {.julia file=test/runtests.jl}
using Test
using Printf

include("ParsingSpec.jl")
@testset "Puzzles" begin
@testset "Day $i" for i = 1:25
    day_digits = @sprintf("%02u", i)
    include("Day$(day_digits)Spec.jl")
end
end
```
