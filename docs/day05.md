---
title: Day 5
---

# Day 5: Print Queue
Graphs! We obtain a list of edges and a list of node lists. We need to check that these nodes are sorted in **topological order**. The fun thing is though: the full graph is cyclic.

## Part 1
Here I took the combination off all pages in each list and checked that none of those were forbidden by any of the listed rules. In other words all of the inverted pairs are not in the set of rules.

``` {.julia #day05}
function check_sorted(rule_list::Vector{Tuple{Int,Int}})
    rules = Set(rule_list)
    function (p::Vector{Int})
        all((p[j], p[i]) ∉ rules
            for i = 1:length(p) for j = i+1:length(p))
    end
end

middle(v) = v[(length(v) + 1) ÷ 2]
```

## Part 2
At first I wanted to sort all the pages following the given rules, but then found out the graph was cyclic. Then I decided to do a [**topological sort**](https://en.wikipedia.org/wiki/Topological_sorting) on the sub-graph of each page list. The Wikipedia gives Kahn's algorithm as a way to perform the sorting.

``` {.julia #day05}
const Graph{T} = AbstractDict{T,Set{T}}

function invert_graph(g::Graph{T}) where {T}
    result = Dict{T,Set{T}}()
    for (n, ms) in pairs(g)
        for m in ms
            if m ∉ keys(result)
                result[m] = Set{T}()
            end
            push!(result[m], n)
        end
    end
    return result
end

function toposort_kahn(g::Graph{T}) where {T}
    l = T[]
    outgoing = Set(keys(g))
    inv = invert_graph(g)
    incoming = Set(keys(inv))
    s = setdiff(outgoing, incoming)

    while !isempty(s)
        n = pop!(s)
        push!(l, n)
        for m in g[n]
            if isempty(delete!(inv[m], n))
                push!(s, m)
            end
        end
    end

    if !all(isempty, values(inv))
        throw("Graph contains cycle")
    end

    return l
end

function make_graph(rules::Vector{Tuple{Int,Int}})
    edges = Dict{Int,Set{Int}}()
    for r in rules
        edges[r[1]] = union(get(edges, r[1], Set{Int}()), Set(r[2]))
    end
    return edges
end

function subgraph(g::Graph{T}, nodes::AbstractSet{T}) where {T}
    Dict{T,Set{T}}(a=>(g[a] ∩ nodes) for a in nodes)
end
```

## Main

``` {.julia file=src/Day05.jl}
module Day05

using ..Monads
using ..Parsing
using GraphvizDotLang: digraph, edge, attr

<<day05>>

function read_input(io::IO)
    text = read(io, String)
    rules_text, pages_text = split(text, "\n\n")
    rule_p = sequence(integer_p, match_p("|") >>> integer_p)
    page_p = sep_by_p(integer_p, match_p(","))
    rules = rules_text |> parse(many(token(rule_p))) |> result
    pages = pages_text |> parse(many(token(page_p))) |> result
    (rules, pages)
end

function main(io::IO)
    rules, pages = read_input(io)
    check = check_sorted(rules)
    part1 = sum(middle(p) for p in pages if check(p))

    graph = make_graph(rules)
    part2 = sum(subgraph(graph, Set(p)) |> toposort_kahn |> middle
                for p in pages if !check(p))
    return part1, part2
end

function draw_graph(io::IO)
    colors = [
        "#332288", "#88ccee", "#44aa99", "#117733", "#999933",
        "#ddcc77", "#cc6677", "#882255", "#aa4499"]
    rules, pages = read_input(io)
    graph = make_graph(rules)
    gv = digraph(engine="neato", maxiter="1000") |>
        attr(:edge; len="2") |> attr(:node; shape="point")

    for (i, p) in enumerate(pages)
        line = subgraph(graph, Set(p)) |> toposort_kahn
        for (a, b) in zip(line[1:end-1], line[2:end])
            gv |> edge("$a", "$b"; color=colors[mod1(i, 9)])
        end
    end
    gv
end

end
```

``` {.julia file=test/Day05Spec.jl}
# add tests
```
