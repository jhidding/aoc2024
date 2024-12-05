# ~/~ begin <<docs/parsing.md#src/Monads.jl>>[init]
module Monads
    export Monad, bind, pure, fmap, starmap, value_type

    abstract type Monad end
    function bind end
    function pure end
    function fmap end

    Base.:>>(m::M, f::F) where {M <: Monad, F} = bind(m, f)
    pure(::Type{M}) where {M <: Monad} = (x -> pure(M, x))
    fmap(::Type{M}, f::F) where {M <: Monad, F} = pure(M) ∘ f
    fmap(f::F, m::M) where {M <: Monad, F} = m >> fmap(M, f)
    starmap(::Type{M}, f::F) where {F, M <: Monad} = pure(M) ∘ splat(f)
end
# ~/~ end
