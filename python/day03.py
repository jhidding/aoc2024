# ~/~ begin <<docs/day03.md#python/day03.py>>[init]
from __future__ import annotations
from dataclasses import dataclass
from collections.abc import Callable

# ~/~ begin <<docs/day03.md#day03-python>>[init]
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
# ~/~ end
# ~/~ end
