---
title: Day 12
---

# Day 12

We need to find borders of regions on a grid. First we need to find all connected regions.

``` {.julia #day12}
struct Dim{N} end

function grid_neighbours(::Type{Dim{N}}) where {N}
    Iterators.flatten(
      (CartesianIndex((k == d ? -1 : 0 for k in 1:N)...),
       CartesianIndex((k == d ?  1 : 0 for k in 1:N)...))
      for d in 1:N) |> collect
end

function mark_regions(a::AbstractArray{T,N}) where {T,N}
    nb = grid_neighbours(Dim{N})
    label = 1
    mark = zeros(Int, size(a)...)

    while (start = findfirst(mark .== 0)) !== nothing
        queue = CartesianIndex{N}[start]
        while !isempty(queue)
            x = pop!(queue)
            mark[x] = label
            for n in nb
                y = x + n
                checkbounds(Bool, a, y) || continue
                mark[y] == 0 || continue
                a[x] == a[y] || continue
                push!(queue, y)
            end
        end
        label += 1
    end

    return mark
end
```

Once all regions have a unique id, we can scan for fence locations. I scan columns and rows seperately.

``` {.julia #day12}
function add_border(a::AbstractArray{T,Dim}, e::T) where {T,Dim}
    bordered = Array{T}(undef, (size(a) .+ 2)...)
    for d = 1:Dim
        sel = Union{Int,Colon}[Colon() for _ in 1:Dim]
        sel[d] = 1
        bordered[sel...] .= e
        sel[d] = size(a)[d] + 2
        bordered[sel...] .= e
    end
    bordered[(2:s+1 for s in size(a))...] = a
    return bordered
end

function fence_regions(input::Matrix{T}) where {T}
    b = add_border(input, zero(T))
    edge(a, b) = a == b ? (zero(T)=>zero(T)) : (a => b)
    col_fences = edge.(b[1:end-1,2:end-1], b[2:end,2:end-1])
    row_fences = edge.(b[2:end-1,1:end-1], b[2:end-1,2:end])
    return row_fences, col_fences
end
```

## Part 1

We need to count the total number of fences.

``` {.julia #day12}
function cost1(input::Matrix{T}) where {T}
    regions = mark_regions(input)
    rf, cf = fence_regions(regions)

    nregions = length(unique(regions))
    nfences = zeros(Int, nregions+1)

    @views nfences[first.(rf).+1] .+= 1
    @views nfences[last.(rf).+1] .+= 1
    @views nfences[first.(cf).+1] .+= 1
    @views nfences[last.(cf).+1] .+= 1

    k(c::Int) = nfences[c+1] * sum(c .== regions)

    return sum(k(c) for c in unique(regions))
end
```

## Part 2

I reuse the nice `count_sorted` function from day 1.

``` {.julia #day12}
function cost2(input::Matrix{T}) where {T}
    regions = mark_regions(input)
    rf, cf = fence_regions(regions)

    nregions = length(unique(regions))
    nsides = zeros(Int, nregions + 1)

    tally_sides(x) = @views nsides[first.(count_sorted(x)).+1] .+= 1

    for r in eachrow(cf)
        tally_sides(first.(r))
        tally_sides(last.(r))
    end
    for c in eachcol(rf)
        tally_sides(first.(c))
        tally_sides(last.(c))
    end

    k(c::Int) = nsides[c+1] * sum(c .== regions)

    return sum(k(c) for c in 1:nregions)
end
```

## Main and test

``` {.julia file=src/Day12.jl}
module Day12

using ..Day01: count_sorted

read_input(io::IO) = io |> readlines .|> collect |> stack

<<day12>>

function main(io::IO)
    input = read_input(io)
    cost1(input), cost2(input)
end

end
```

``` {.julia file=test/Day12Spec.jl}
# add tests
```
