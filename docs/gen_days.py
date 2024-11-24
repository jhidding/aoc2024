template = """---
title: Day {n}
---

# Day {n}

``` {{.julia file=test/Day{n:02}Spec.jl}}
# add tests
```

``` {{.julia file=src/Day{n:02}.jl}}
module Day{n:02}

function main(io::IO)
    return nothing
end

end
```
"""

for n in range(1, 26):
    with open(f"day{n:02}.md", "w") as out:
        out.write(template.format(n=n))
