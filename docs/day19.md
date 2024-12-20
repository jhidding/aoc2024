---
title: Day 19
---

# Day 19

``` {.julia file=test/Day19Spec.jl}
# add tests
```

``` {.julia file=src/Day19.jl}
module Day19

function read_input(io::IO)
    lines = readlines(io) |> collect
    patterns = split(lines[1], ", ")
    designs = lines[3:end]
    return patterns, designs
end

mutable struct Tree{T}
    isleaf::Bool
    branches::Dict{T, Tree{T}}
end

Tree{T}() where {T} = Tree{T}(false, Dict{T, Tree{T}}())

add_path!(t::Tree{T}, it::I) where {T, I} =
    _add_path_helper!(t, it, iterate(it))

add_path!(t::Tree{T}, it::I, state::S) where {T, I, S} =
    _add_path_helper!(t, it, iterate(it, state))

function _add_path_helper!(t::Tree{T}, it::I, item::Nothing) where {T, I}
    t.isleaf = true
    return t
end

function _add_path_helper!(t::Tree{T}, it::I, item::Tuple{T, S}) where {T, I, S}
    value, state = item

    if value ∉ keys(t.branches)
        t.branches[value] = Tree(false, Dict{T, Tree{T}}())
    end

    add_path!(t.branches[value], it, state)
end

function pattern_tree(pat::Vector{S}) where {S<:AbstractString}
    t = Tree{Char}()
    for p in pat
        add_path!(t, p)
    end
    return t
end

Base.match(p::Tree{Char}) = s -> match(p, s, Dict{String, Int}())

function Base.match(p::Tree{Char}, s::T, cache::Dict{String,Int}) where {T <: AbstractString}
    s ∈ keys(cache) && return cache[s]

    function compute()
        isempty(s) && return 1
        s[1] ∉ keys(p.branches) && return 0

        remainders = T[]
        partial_match(p.branches[s[1]], s[2:end], remainders)
        sum(r->match(p, r, cache), remainders; init=0)
    end

    return cache[s] = compute()
end

function partial_match(p::Tree{Char}, s::T, out::Vector{T}) where {T <: AbstractString}
    if p.isleaf
        push!(out, s)
    end
    if isempty(s) || s[1] ∉ keys(p.branches)
        return
    end
    partial_match(p.branches[s[1]], s[2:end], out)
end

function main(io::IO)
    patterns, designs = read_input(io)
    ptree = pattern_tree(patterns)
    counts = map(match(ptree), designs)
    part1 = sum(counts .> 0)
    part2 = sum(counts)
    part1, part2
end

end
```
