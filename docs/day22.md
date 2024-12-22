---
title: Day 22
---

# Day 22

``` {.julia file=test/Day22Spec.jl}
# add tests
```

``` {.julia file=src/Day22.jl}
module Day22

using .Iterators: drop, peel, take

jumble(n) = x -> (x ⊻ (x << n)) % 16777216
next_secret(x) = x |> jumble(6) |> jumble(-5) |> jumble(11)

struct Seed
    x::UInt64
end

tee(x::T) where {T} = (x, x)

Base.iterate(s::Seed) = tee(s.x)
Base.iterate(::Seed, s::UInt64) = tee(next_secret(s))
Base.IteratorSize(::Seed) = Base.IsInfinite()
Base.IteratorEltype(::Type{Seed}) = Base.HasEltype()
Base.eltype(::Type{Seed}) = UInt64

get_2000th(n::UInt64) = drop(Seed(n), 2000) |> peel |> first |> Int
last_digit(n::UInt64) = Int(n % 10)

sliding_window(vec::AbstractVector, n) =
    ((@view vec[i:i+n-1]) for i in 1:length(vec)-n+1)

function count_bananas_fstyle(input::Vector{UInt64})
    bananas = zeros(Int, 19^4)
    vs = falses(19^4)
    ns = Vector{Int}(undef, 2000)
    d = Vector{Int}(undef, 1999)
    for s in input
        vs .= false
        ns[1] = s % 10
        for i in 1:1999
            s = next_secret(s)
            ns[i+1] = s % 10
            d[i] = ns[i+1] - ns[i] .+ 9
        end
        for i = 5:2000
            idx = ((d[i-4]*19 + d[i-3])*19 + d[i-2]) * 19 + d[i-1] + 1
            if !vs[idx]
                vs[idx] = true
                bananas[idx] += ns[i]
            end
        end
    end
    return bananas
end

function count_bananas(input::Vector{UInt64})
    bananas = zeros(Int, 19, 19, 19, 19)
    vs = falses(19, 19, 19, 19)
    for seed in input
        vs .= false
        ns = take(Seed(seed), 2000) .|> last_digit
        ds = ns[2:end] .- ns[1:end-1] .+ 10
        for (seq, n) in zip(sliding_window(ds, 4), ns[5:end])
            idx = CartesianIndex(seq[1], seq[2], seq[3], seq[4])
            if !vs[idx]
                vs[idx] = true
                bananas[idx] += n
            end
        end
    end
    n, seq = findmax(bananas)
    seq = Tuple(seq) .- 10
    return seq, n
end

function read_input(io::IO)
    readlines(io) .|> s -> parse(UInt64, s)
end

function main(io::IO)
    return nothing
end

end
```
