# ~/~ begin <<docs/day12.md#src/Day12.jl>>[init]
module Day12

using ..Day01: count_sorted

read_input(io::IO) = io |> readlines .|> collect |> stack

# ~/~ begin <<docs/day12.md#day12>>[init]
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
# ~/~ end
# ~/~ begin <<docs/day12.md#day12>>[1]
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
# ~/~ end
# ~/~ begin <<docs/day12.md#day12>>[2]
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
# ~/~ end
# ~/~ begin <<docs/day12.md#day12>>[3]
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
# ~/~ end

function main(io::IO)
    input = read_input(io)
    cost1(input), cost2(input)
end

end
# ~/~ end
