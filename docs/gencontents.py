from pathlib import Path
import json
import re
import io
from contextlib import contextmanager


def write_weave_html(files):
    data = {"call": [
        {   "template": "pandoc",
            "collect": "html",
            "args": { "basename": [p.stem for p in files] }
        }]}
    json.dump(data, open("docs/weave_html.json", "w"))


contents_header = """
<!-- automatically generated from docs/gencontents.py
     editing this file is futile -->
"""


@contextmanager
def write_if_changed(filename):
    out = io.StringIO()
    yield out
    content = out.getvalue()
    try:
        current = open(filename, "r").read()
    except FileNotFoundError:
        current = ""
    if content != current:
        open(filename, "w").write(content)


def write_contents(files):
    with write_if_changed("docs/contents.md") as out:
        print(contents_header, file=out)
        for i, fn in enumerate(files):
            with open(fn, "r") as f:
                for line in f:
                    if m := re.match(r"^title:(.*)$", line):
                        title = m.group(1).strip(" '\"")
                        print(f"{i+1}. [{title}]({fn.name})", file=out)
        print("", file=out)
        for j in range(5):
            for k in range(5):
                i = j*5 + k
                print(f"[[{(i+1):02}]](day{(i+1):02}.md)", file=out, end="")
            print("", file=out)


if __name__ == "__main__":
    files = [Path("docs/index.md"), Path("docs/tests.md"), Path("docs/parsing.md")]
    solutions = [Path(f"docs/day{n:02}.md") for n in range(1, 26)]
    write_weave_html(files + solutions)
    write_contents(files)
