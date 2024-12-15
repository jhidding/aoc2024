### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ f5de8e94-b9df-11ef-22f1-57ff2024dc40
using Pkg; Pkg.activate("..")

# ╔═╡ 4bc32102-faaf-4107-a7da-2c2f50127f54
using GLMakie

# ╔═╡ be416a8d-d053-4cfc-9774-4acf8f25a07d
using PlutoUI

# ╔═╡ ab731e82-3b68-496d-8aa0-4fbe705db7dc
using AOC2024.Day14: read_input, Robot, move, position, Box

# ╔═╡ e325b5a6-9943-4734-b5f3-faeb27ae7e1d
md"""
# Day 14, Part 2
"""

# ╔═╡ 047712b9-41c6-4a9d-afa8-d691b9681754
robots = read_input(open("../data/day14.txt"))

# ╔═╡ 0ae25158-2f65-4dde-bade-46175cc459aa
b = Box()

# ╔═╡ 39e74b7c-cca4-4195-a756-5cf413d18429
md"""
From Part 1 we could infer that we don't need to look beyond `t=100` to get an answer. I made a slider using `PlutoUI` to find the christmas tree.
"""

# ╔═╡ c287f597-f4d3-44f3-8f96-2429365951e0
@bind t1 PlutoUI.Slider(1:100)

# ╔═╡ 8e79e3ef-f44d-4180-a4a2-7f1eaeae2930
let
	fig = Figure()
	ax = Axis(fig[1,1], title="t=$t1", yreversed=true, aspect=1)
	p = move.(b, t1, robots) .|> position |> stack
	scatter!(ax, eachrow(p)...)
	fig
end

# ╔═╡ fbd5fe61-5526-45a3-9144-fdbf7e69c343
@bind t2 PlutoUI.Slider(1:100)

# ╔═╡ 4ef4aa2d-9186-454c-b094-0c17acf5193e
let
	fig = Figure()
	ax = Axis(fig[1,1], title="t=$t2", yreversed=true, aspect=1)
	p = move.(b, t2, robots) .|> position |> stack
	scatter!(ax, eachrow(p)...)
	fig
end

# ╔═╡ 740b93e4-397a-4e88-8758-3d86a066ef8e
md"""
Now, we know that we have a periodicity of 101 in one direction and 103 in the other. So we're looking for a time where these vertical and horizontal patterns coincide.

$$53 + 103n = 98 + 101m$$
$$103n - 101m = 45$$

This is one of those pesky Diophantine equations.
"""

# ╔═╡ 4eb6729c-ef29-42bb-9746-662ab11b3f7a
function extended_euler_gcd(a::I, b::I) where {I <: Integer}
    b == 0 && return (gcd=a, x=1, y=0)
    g = extended_euler_gcd(b, a % b)
    return (gcd=g.gcd, x=g.y, y=g.x - g.y * div(a, b))
end

# ╔═╡ fb193919-b30c-43af-bf8b-d85a50d79c04
function solve_diophantine(a::I, b::I, c::I) where {I <: Integer}
    g = extended_euler_gcd(a, b)
    c % g.gcd == 0 || return nothing
    f = div(c, g.gcd)
    return (x=g.x * f, y=g.y * f, dx=div(b, g.gcd), dy=-div(a, g.gcd))
end

# ╔═╡ c8b8ad91-2001-4793-8e27-97139eeeee5c
solve_diophantine(103, -101, 45)

# ╔═╡ 171c805d-6c01-4b54-9724-9840242253fa
md"""
Now find the first value of $n$ for which we get a positive $t$,

$$t = 53 + (101n - 2250) \times 103$$

I just tried a few values.
"""

# ╔═╡ 780b6aa4-b35e-49f8-9647-88dec90e7cdc
t3 = 53 + (101*23 - 2250)*103

# ╔═╡ d36f0cbb-0d87-45e4-9534-4a32efa96c8a
let
	fig = Figure()
	ax = Axis(fig[1,1], title="t=$t3", yreversed=true, aspect=1)
	p = move.(b, t3, robots) .|> position |> stack
	scatter!(ax, eachrow(p)...)
	fig
	# save("/home/johannes/Downloads/christmas-tree.png", fig)
end

# ╔═╡ Cell order:
# ╟─e325b5a6-9943-4734-b5f3-faeb27ae7e1d
# ╠═f5de8e94-b9df-11ef-22f1-57ff2024dc40
# ╠═4bc32102-faaf-4107-a7da-2c2f50127f54
# ╠═be416a8d-d053-4cfc-9774-4acf8f25a07d
# ╠═ab731e82-3b68-496d-8aa0-4fbe705db7dc
# ╠═047712b9-41c6-4a9d-afa8-d691b9681754
# ╠═0ae25158-2f65-4dde-bade-46175cc459aa
# ╟─39e74b7c-cca4-4195-a756-5cf413d18429
# ╠═c287f597-f4d3-44f3-8f96-2429365951e0
# ╟─8e79e3ef-f44d-4180-a4a2-7f1eaeae2930
# ╠═fbd5fe61-5526-45a3-9144-fdbf7e69c343
# ╟─4ef4aa2d-9186-454c-b094-0c17acf5193e
# ╟─740b93e4-397a-4e88-8758-3d86a066ef8e
# ╠═4eb6729c-ef29-42bb-9746-662ab11b3f7a
# ╠═fb193919-b30c-43af-bf8b-d85a50d79c04
# ╠═c8b8ad91-2001-4793-8e27-97139eeeee5c
# ╟─171c805d-6c01-4b54-9724-9840242253fa
# ╠═780b6aa4-b35e-49f8-9647-88dec90e7cdc
# ╠═d36f0cbb-0d87-45e4-9534-4a32efa96c8a
