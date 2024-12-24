# ~/~ begin <<docs/day24.md#src/Day24.jl>>[init]
module Day24

using ..Monads
using ..Parsing

function read_input(io::IO)
    wire_p = fmap(m->Symbol(m.match), match_p(r"[a-z0-9]{3}"))
    preset_p = sequence(wire_p, match_p(": ") >>> integer)
    gate_p = (match_p(r"XOR") >>> pure_p(:⊻)) |
             (match_p(r"AND") >>> pure_p(:&)) |
             (match_p(r"OR")  >>> pure_p(:|))
    instr_p = sequence(token(wire_p), token(gate_p), token(wire_p), token(match_p("->")) >>> token(wire_p))

    text = read(io, String)
    preset_text, instr_text = split(text, "\n\n")
    presets = preset_text |> parse(many(preset_p)) |> result
    instrs = instr_text |> parse(many(instr_p)) |> result
    return presets, instrs
end

function main(io::IO)
    return nothing
end

end
# ~/~ end
