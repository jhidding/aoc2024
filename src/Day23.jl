# ~/~ begin <<docs/day23.md#src/Day23.jl>>[init]
module Day23

using DataStructures

read_input(io::IO) = readlines(io) .|> Base.Fix2(split, '-') |> stack

const Graph = DefaultDict{String,Set{String}}

function make_graph(pairs::Matrix{S}) where {S <: AbstractString}
    edges = Graph(Set{String})
    for (a, b) in eachcol(pairs)
        push!(edges[a], b)
        push!(edges[b], a)
    end
    return edges
end

function find_n_cycles(g::Graph, n::Int, x::String)
    s = Vector{String}[String[x]]
    result = Vector{String}[]
    while !isempty(s)
        chain = pop!(s)
        y = last(chain)
        if length(chain) == n && x ∈ g[y]
            push!(result, chain)
        end
        if length(chain) >= n
            continue
        end
        for z in g[y]
            if z ∉ chain
                push!(s, push!(copy(chain), z))
            end
        end
    end
    return result
end

function find_triplets(g::Graph)
    cycles = Set{Vector{String}}()
    for n1 ∈ keys(g)
        for c in find_n_cycles(g, 3, n1)
            push!(cycles, sort(c))
        end
    end
    return cycles
end

part1(g::Graph) = g |>
    find_triplets |>
    filter(v->any(isequal('t')∘first, v)) |>
    length

bron_kerbosch(N::Graph) =
    bron_kerbosch(N, Set{String}(), Set{String}(keys(N)), Set{String}(), Set{String}[])

function bron_kerbosch(N::Graph, r::Set{String}, p::Set{String}, x::Set{String}, cliques::Vector{Set{String}})
    if isempty(p) && isempty(x)
        push!(cliques, r)
    end
    for v ∈ p
        bron_kerbosch(N, r ∪ (v,), p ∩ N[v], x ∩ N[v], cliques)
        p = setdiff(p, (v,))
        x = x ∪ (v,)
    end
    return cliques
end

function part2(g::Graph)
    cliques = bron_kerbosch(g)
    _, x = findmax(length, cliques)
    join(cliques[x] |> collect |> sort, ',')
end

function main(io::IO)
    g = io |> read_input |> make_graph
end

end
# ~/~ end
