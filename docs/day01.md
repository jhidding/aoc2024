---
title: Day 1
---

# Day 1: Historian Hysteria

In part 1, we need find the 1-norm of the distance between two (sorted) vectors. In the second part, we need to find all numbers that appear both in the first and second vector, then multiply those with their count in each vector. We get the following test data:

``` {.julia #day01-spec}
let test_input = [
        3   4;
        4   3;
        2   5;
        1   3;
        3   9;
        3   3]
    a = sort(test_input[:,1])
    b = sort(test_input[:,2])
    @test total_distance(a, b) == 11
    @test similarity_score(a, b) == 31
end
```

## Parsing
We're parsing two columns of integers.

``` {.julia #day01-parsing}
tuples_to_matrix(v::Vector{NTuple{N, T}}) where {N, T} = reshape(reinterpret(T, v), (N, :))

read_input(io::IO) = let p = many(sequence(integer, integer)) >> fmap(Parser, tuples_to_matrix)
    read(io, String) |> parse(p) |> result
end
```

## Part 1
This becomes rather easy to solve if we first sort both input vectors.

``` {.julia #day01-part1}
total_distance(a, b) = sum(abs.(a .- b))
```

## Part 2
Now we need to count how many times each number is in both collections, and then find which numbers appear in both collections. We could do this by keeping a `Dict` of the counts, but if our input collections are sorted, we don't need to store any data, we can just iterate through both sorted collections to compute the result. Then it is interesting to see how we can express this succinctly.

The following implementation uses two non-standard iterator functions.

``` {.julia #count-sorted-doc}
"""
    count_sorted(lst)

Takes a sorted collection `lst` of item type `T` and counts consecutive repetitions
of items. Returns an iterator of `Tuple{T, Int}`.
"""
function count_sorted end
```

``` {.julia #count-sorted-spec}
@test count_sorted([1, 1, 2, 2, 2, 3]) |> collect ==
    [(1, 2), (2, 3), (3, 1)]
```

``` {.julia #zip-sorted-doc}
"""
    zip_sorted(a, b; key=identity, map=identity, default=nothing)

Takes two collections `a` and `b` of item type `T`, that should be sorted by `key`.
Here, `key` is a function `T -> K`, `map` a function `T -> U`. Returns a sorted iterator of
`Tuple{K, U, U}`, replacing missing values with `default`.
"""
function zip_sorted end
```

``` {.julia #zip-sorted-spec}
@test zip_sorted([1, 2, 4, 6], [3, 4, 5, 6]; default=0) |> collect ==
    [(1, 1, 0), (2, 2, 0), (3, 0, 3), (4, 4, 4), (5, 0, 5), (6, 6, 6)]
```

Now, `zip_sorted` is a bit of a special combinator, but it allows us to write down the answer to part two in a compact form. Also, `zip_sorted` is a kind of reduced elemental form of the kind of concurrent iteration that we need.

``` {.julia #day01-part2}
function similarity_score(a, b)
    sum(map(
        splat(*),
        zip_sorted(count_sorted(a), count_sorted(b);
                   key=x->x[1], map=x->x[2], default=0)
    ))
end
```

## `count_sorted`
Now comes the painful bit. Implementing iterators in Julia is rather arduous.

``` {.julia #count-sorted}
struct CountSorted{V}
    v::V
end

Base.IteratorSize(::CountSorted) = Base.SizeUnknown()

<<count-sorted-doc>>
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
```

## `peekable`
To implement `zip_sorted` we need an iterator that remembers the last obtained item.

``` {.julia #peekable}
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
```

## `zip_sorted`
When we combine two iterators, we need to do bookkeeping logic for both iterators.

``` {.julia #zip-sorted}
struct ZipSorted{It1,It2,K,M,T}
    it1::Peekable{It1}
    it2::Peekable{It2}
    key::K
    map::M
    default::T
end

Base.IteratorSize(::ZipSorted) = Base.SizeUnknown()

<<zip-sorted-doc>>
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
```

## Main

``` {.julia file=src/Day01.jl}
module Day01

using ..Monads
using ..Parsing

<<day01-parsing>>
<<day01-part1>>
<<count-sorted>>
<<peekable>>
<<zip-sorted>>
<<day01-part2>>

function main(io::IO)
    input = read_input(io)
    a = sort(input[1,:])
    b = sort(input[2,:])
    return (total_distance(a, b),
            similarity_score(a, b))
end

end
```

``` {.julia file=test/Day01Spec.jl}
using AOC2024.Day01: total_distance, similarity_score, count_sorted, zip_sorted

<<day01-spec>>
<<count-sorted-spec>>
<<zip-sorted-spec>>
```

## Extra: Rust

``` {.rust file=rust/src/bin/day01.rs}
use std::io;

#[derive(Debug)]
enum Error {
    IO(io::Error),
    ParseInt(ParseIntError)
}

fn read_integer_pair(line: &str) -> Result<(u32, u32), Error> {
    line.split(' ').map(|x| x.parse::<u32>()).collect().map_err(Error::ParseInt)
}

fn main() -> Result<(), io::Error> {
    let input: Vec<_> = io::stdin().lines().map(read_integer_pair).collect::<Result<Vec<_>, _>>()?;
    println!("{:?}", input);
    Ok(())
}
```
