# ~/~ begin <<docs/day01.md#python/day01.py>>[init]
from collections.abc import Iterable, Generator, Callable
from typing import Protocol

import sys

class Ord(Protocol):
    def __lt__(self, other, /) -> bool: ...


def count_sorted[T](lst: Iterable[T]) -> Generator[tuple[T, int]]:
    it = iter(lst)
    try:
        value = next(it)
    except StopIteration:
        return
    count = 1

    for x in it:
        if x != value:
            yield (value, count)
            value = x
            count = 1
        else:
            count += 1

    yield (value, count)


def test_count_sorted():
    assert list(count_sorted([1, 2, 2, 2, 3, 3])) == [(1, 1), (2, 3), (3, 2)]
    assert list(count_sorted([])) == []


def identity[T](x: T) -> T:
    return x


def merge_sorted[T, K: Ord, U](
        a: Iterable[T],
        b: Iterable[T],
        key: Callable[[T], K],
        map: Callable[[T], U] = identity,
        default: U = None) -> Generator[tuple[K, U, U]]:

    it1 = iter(a)
    it2 = iter(b)

    def advance_it1():
        # if `a` is empty, yield from `b`
        try:
            x = next(it1)
        except StopIteration:
            yield from ((key(y), default, map(y)) for y in it2)
            return
        else:
            return x

    def advance_it2(x=None):
        # if `b` is empty, yield from `a` (but we already took one!)
        try:
            y = next(it2)
        except StopIteration:
            if x is not None:
                yield (key(x), map(x), default)
            yield from ((key(x), map(x), default) for x in it1)
            return
        else:
            return y

    x = (yield from advance_it1())
    if x is None:
        return

    y = (yield from advance_it2(x))
    if y is None:
        return

    while True:
        if key(x) == key(y):
            yield (key(x), map(x), map(y))
            x = (yield from advance_it1())
            if x is None:
                return
            y = (yield from advance_it2(x))
            if y is None:
                return
        elif key(x) < key(y):
            yield (key(x), map(x), default)
            x = (yield from advance_it1())
            if x is None:
                return
        else:
            yield (key(y), default, map(y))
            y = (yield from advance_it2())
            if y is None:
                return


def test_merge_sorted():
    assert list(merge_sorted([1, 2, 4], [2, 3, 4, 5], key=identity, default=0)) \
        == [(1, 1, 0), (2, 2, 2), (3, 0, 3), (4, 4, 4), (5, 0, 5)]
    assert list(merge_sorted(["a", "aaa"], ["b", "bb", "bbb"], key=len)) \
        == [(1, "a", "b"), (2, None, "bb"), (3, "aaa", "bbb")]


def read_input(f):
    data = [tuple(map(int, l.split())) for l in f]
    a = sorted(x[0] for x in data)
    b = sorted(x[1] for x in data)
    return a, b


if __name__ == "__main__":
    a, b = read_input(sys.stdin)
    part1 = sum(abs(x - y) for (x, y) in zip(a, b))
    part2 = sum(k * x * y for (k, x, y) in
        merge_sorted(count_sorted(a), count_sorted(b),
            key=lambda p: p[0], map=lambda p: p[1], default=0))
    print(f"Part 1: {part1}")
    print(f"Part 2: {part2}")
# ~/~ end
