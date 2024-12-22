# ~/~ begin <<docs/day22.md#src/Day22.jl>>[init]
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
    bananas = zeros(Int, 19, 19, 19, 19)
    vs = falses(19, 19, 19, 19)
    ns = Vector{Int}(undef, 2000)
    d = Vector{Int}(undef, 1999)
    for s in input
        vs .= false
        ns[1] = s % 10
        for i in 1:1999
            s = next_secret(s)
            ns[i+1] = s % 10
            d[i] = ns[i+1] - ns[i] .+ 10
        end
        for i = 5:2000
            idx = CartesianIndex{4}(d[i-4], d[i-3], d[i-2], d[i-1])
            if !vs[idx]
                vs[idx] = true
                bananas[idx] += ns[i]
            end
        end
    end
    return maximum(bananas)
end

function count_bananas_arrays(input::Vector{UInt64})
    bananas = zeros(Int, 19, 19, 19, 19)
    vs = falses(19, 19, 19, 19)
    for seed in input
        vs .= false
        ns = take(Seed(seed), 2000) .|> last_digit
        for seq in sliding_window(ns, 5)
            idx = CartesianIndex{4}(
                   seq[2] - seq[1] + 10,
                   seq[3] - seq[2] + 10,
                   seq[4] - seq[3] + 10,
                   seq[5] - seq[4] + 10)
            if !vs[idx]
                vs[idx] = true
                bananas[idx] += seq[5]
            end
        end
    end
    return maximum(bananas)
end

function read_input(io::IO)
    readlines(io) .|> s -> parse(UInt64, s)
end

function main(io::IO)
    return nothing
end

end
# ~/~ end
