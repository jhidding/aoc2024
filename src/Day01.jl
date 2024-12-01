# ~/~ begin <<docs/day01.md#src/Day01.jl>>[init]
module Day01

using ..Monads
using ..Parsing

# ~/~ begin <<docs/day01.md#day01-parsing>>[init]
tuples_to_matrix(v::Vector{NTuple{N, T}}) where {N, T} = reshape(reinterpret(T, v), (N, :))

read_input(io::IO) = let p = many(sequence(integer, integer)) >> fmap(Parser, tuples_to_matrix)
    read(io, String) |> parse(p) |> result
end
# ~/~ end
# ~/~ begin <<docs/day01.md#day01-part1>>[init]
total_distance(a, b) = sum(abs.(a .- b))
# ~/~ end
# ~/~ begin <<docs/day01.md#count-sorted>>[init]
struct CountSorted{V}
    v::V
end

Base.IteratorSize(::CountSorted) = Base.SizeUnknown()

# ~/~ begin <<docs/day01.md#count-sorted-doc>>[init]
"""
    count_sorted(lst)

Takes a sorted collection `lst` of item type `T` and counts consecutive repetitions
of items. Returns an iterator of `Tuple{T, Int}`.
"""
function count_sorted end
# ~/~ end
count_sorted(v::V) where {V} = CountSorted(v)

struct CountSortedState{T, S}
    value::T
    state::S
end

function Base.iterate(cs::CountSorted{V}, st::Nothing) where {V}
    return nothing
end

function Base.iterate(cs::CountSorted{V}) where {V}
    n = iterate(cs.v)
    n === nothing && return nothing
    iterate(cs, CountSortedState(n...))
end

function Base.iterate(cs::CountSorted{V}, st::CountSortedState{T, S}) where {V, T, S}
    item = st.value
    state = st.state
    count = 0

    while item == st.value
        count += 1
        n = iterate(cs.v, state)
        n === nothing && return ((st.value, count), nothing)
        (item, state) = n
    end
    return ((st.value, count), CountSortedState(item, state))
end
# ~/~ end
# ~/~ begin <<docs/day01.md#peekable>>[init]
struct Peekable{V}
    iter::V
end

Base.IteratorSize(p::Peekable{V}) where V = IteratorSize(p.iter)

struct PeekableState{T,S}
    head::T
    state::S
end

function Base.iterate(p::Peekable{V}) where {V}
    n = iterate(p.iter)
    n === nothing && return nothing
    (head, state) = n
    (head, PeekableState(head, state))
end

function Base.iterate(p::Peekable{V}, s::PeekableState{T,S}) where {T, V, S}
    n = iterate(p.iter, s.state)
    n === nothing && return nothing
    (head, state) = n
    (head, PeekableState(head, state))
end
# ~/~ end
# ~/~ begin <<docs/day01.md#zip-sorted>>[init]
struct ZipSorted{It1,It2,K,M,T}
    it1::Peekable{It1}
    it2::Peekable{It2}
    key::K
    map::M
    default::T
end

Base.IteratorSize(::ZipSorted) = Base.SizeUnknown()

# ~/~ begin <<docs/day01.md#zip-sorted-doc>>[init]
"""
    zip_sorted(a, b; key=identity, map=identity, default=nothing)

Takes two collections `a` and `b` of item type `T`, that should be sorted by `key`.
Here, `key` is a function `T -> K`, `map` a function `T -> U`. Returns a sorted iterator of
`Tuple{K, U, U}`, replacing missing values with `default`.
"""
function zip_sorted end
# ~/~ end
zip_sorted(it1::It1, it2::It2; key::K = identity, map::M = identity, default::T = nothing) where {It1,It2,K,M,T} =
    ZipSorted(Peekable(it1), Peekable(it2), key, map, default)

struct ZipSortedState{A,B}
    st1::A
    st2::B
end

function zip_sorted_helper(zs::ZipSorted{It1,It2,K,M}, st::ZipSortedState{A,B}) where {It1,It2,K,M,A,B}
    st1 = st.st1
    st2 = st.st2
    zs.key(st1.head) == zs.key(st2.head) &&
        return ((zs.key(st1.head), zs.map(st1.head), zs.map(st2.head)), st)
    zs.key(st1.head) < zs.key(st2.head) &&
        return ((zs.key(st1.head), zs.map(st1.head), zs.default), st)
    return ((zs.key(st2.head), zs.default, zs.map(st2.head)), st)
end

function Base.iterate(zs::ZipSorted{It1,It2,K,M}) where {It1,It2,K,M}
    n = iterate(zs.it1)
    m = iterate(zs.it2)
    n === nothing && m === nothing && return nothing
    n === nothing && return ((zs.key(m[1]), zs.default, zs.map(m[1])), ZipSortedState(nothing, m[2]))
    m === nothing && return ((zs.key(n[1]), zs.map(n[1]), zs.default), ZipSortedState(n[2], nothing))
    zip_sorted_helper(zs, ZipSortedState(n[2], m[2]))
end

function Base.iterate(zs::ZipSorted{It1,It2,K,M}, st::ZipSortedState{Nothing,B}) where {It1,It2,K,M,B}
    n = iterate(zs.it2, st.st2)
    n == nothing && return nothing
    (v, s) = n
    return ((zs.key(v), zs.default, zs.map(v)), ZipSortedState(nothing, s))
end

function Base.iterate(zs::ZipSorted{It1,It2,K,M}, st::ZipSortedState{A,Nothing}) where {It1,It2,K,M,A}
    n = iterate(zs.it1, st.st1)
    n == nothing && return nothing
    (v, s) = n
    return ((zs.key(v), zs.map(v), zs.default), ZipSortedState(s, nothing))
end

function Base.iterate(zs::ZipSorted{It1,It2,K,M}, st::ZipSortedState{A,B}) where {It1,It2,K,M,A,B}
    st1 = st.st1
    st2 = st.st2
    if zs.key(st1.head) == zs.key(st2.head)
        n = iterate(zs.it1, st1)
        m = iterate(zs.it2, st2)
        n === nothing && m === nothing && return nothing
        n === nothing && return ((zs.key(m[1]), zs.default, zs.map(m[1])), ZipSortedState(nothing, m[2]))
        m === nothing && return ((zs.key(n[1]), zs.map(n[1]), zs.default), ZipSortedState(n[2], nothing))
        st1 = n[2]
        st2 = m[2]
    elseif zs.key(st.st1.head) < zs.key(st.st2.head)
        n = iterate(zs.it1, st.st1)
        n === nothing && return ((zs.key(st2.head), zs.default, zs.map(st2.head)), ZipSortedState(nothing, st2))
        st1 = n[2]
    else
        n = iterate(zs.it2, st.st2)
        n === nothing && return ((zs.key(st1.head), zs.map(st1.head), zs.default), ZipSortedState(st1, nothing))
        st2 = n[2]
    end
    zip_sorted_helper(zs, ZipSortedState(st1, st2))
end
# ~/~ end
# ~/~ begin <<docs/day01.md#day01-part2>>[init]
function similarity_score(a, b)
    sum(map(
        splat(*),
        zip_sorted(count_sorted(a), count_sorted(b);
                   key=x->x[1], map=x->x[2], default=0)
    ))
end
# ~/~ end

function main(io::IO)
    input = read_input(io)
    a = sort(input[1,:])
    b = sort(input[2,:])
    return (total_distance(a, b),
            similarity_score(a, b))
end

end
# ~/~ end
