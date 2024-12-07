---
title: Day 3
---

# Day 3: Mull It Over
Today we're parsing. I'll solve this by writing a stateful parser. This will need a new parser `repeated` that is like `many` but not keeping any results.

``` {.julia #parsing}
export repeated

function repeated(p::P) where {P <: Parser}
    function (s::S) where {S <: AbstractString}
        while true
            try
                (x, s) = parse(p, s)
            catch
                return (nothing, s)
            end
        end
    end |> FnParser
end
```

## Part 1
In Part 1, we create a closure `multiply` for multiplying numbers and adding them to the total, as well as a `result` closure that obtains the total.

``` {.julia #day03}
function part1_parser()
    total = 0

    multiply(a, b) = begin
        total += a * b
        pure_p(nothing)
    end

    result(_) = begin
        pure_p(total)
    end

    mul_p = sequence(
        match_p("mul(") >>> integer_p,
        match_p(",") >>> integer_p >> skip(match_p(")"))
    ) >> splat(multiply)
    noise_p = item_p >>> pure_p(nothing)

    repeated(mul_p | noise_p) >> result
end
```

## Part 2
Now we need to add a second bit of state to the closure, telling us whether the multiplication machine is enabled or not.

``` {.julia #day03}
function part2_parser()
    enabled = true
    total = 0

    enable(_) = begin enabled = true; pure_p(nothing) end
    disable(_) = begin enabled = false; pure_p(nothing) end
    multiply(a, b) = begin
        total += (enabled ? a * b : 0)
        pure_p(nothing)
    end

    result(_) = begin pure_p(total) end

    do_p = match_p("do()") >> enable
    dont_p = match_p("don't()") >> disable
    mul_p = sequence(
        match_p("mul(") >>> integer_p,
        match_p(",") >>> integer_p >> skip(match_p(")"))
    ) >> splat(multiply)
    noise_p = item_p >>> pure_p(nothing)

    repeated(mul_p | do_p | dont_p | noise_p) >> result
end
```

That wraps it up for today.

``` {.julia file=src/Day03.jl}
module Day03

using ..Monads
using ..Parsing

<<day03>>

function main(io::IO)
    text = read(io, String)
    part1 = text |> parse(part1_parser()) |> result
    part2 = text |> parse(part2_parser()) |> result
    return (part1, part2)
end

end
```

``` {.julia file=test/Day03Spec.jl}
# add tests
```

## Python
I like functional programming. People often ask me then "what does that mean?". Well, truly, no one really knows.

- Have a distrust for mutable state
- Prefer pure functions over classes
- Use composition to build out complexity

When it comes to Advent of Code, I tend to prefer building my own parsers over using Regexes. Let's solve Day 3, Part 2 in Python. I will break all these preferences, but everything will still **feel functional** somehow.

``` {.python file=python/day03.py}
from __future__ import annotations
from dataclasses import dataclass
from collections.abc import Callable

<<day03-python>>
```

``` {.python #day03-python}
@dataclass
class Parser[T]:
    f: Callable[[str], tuple[T, str]]

    def __rshift__(self, f: Callable[[T], Parser[U]]) -> Parser[U]:
        return bind(self, f)

def parse[T](p: Parser[T], s: str) -> T:
    return p.f(s)[0]

def parser[T](f: Callable[[str], tuple[T, str]]) -> Parser[T]:
    return Parser(f)

def bind[T, U](a: Parser[T], f: Callable[[T], Parser[U]]) -> Parser[U]:
    @parser
    def bound(s: str) -> tuple[U, str]:
        (x, s) = a.f(s)
        return f(x)(s)

    return bound

class Failure(Exception):
    pass

class EndOfInput(Failure):
    def __str__(self):
        return "End of input"

@parser
def item(s: str) -> tuple[str, str]:
    if len(s) == 0:
        raise EndOfInput()
    return (s[0], s[1:])

def many[T](p: Parser[T]) -> Parser[list[T]]:
    @parser
    def many_p(s: str) -> tuple[list[T], str]:
        result = []
        while True:
            try:
                (x, s) = p.f(s)
            except Failure:
                return (result, s)
            result.append(x)
    return many_p

def test_many_items():
    assert parse(many(item), "abc") == ["a", "b", "c"]

def sequence(*ps: Parser[Any]) -> Parser[Any]:
    def sequenced(s: str) -> tuple[Any, str]:
        for
```
