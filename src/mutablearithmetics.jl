import MutableArithmetics

const MA = MutableArithmetics

const SinAndCos = Union{typeof(Base.sin),typeof(Base.cos)}

MA.mutability(::Type{<:ArbLike},           ::SinAndCos,           ::Type{<:ArbLike}) = MA.IsMutable()
MA.mutability(::Type{<:NTuple{2,ArbLike}}, ::typeof(Base.sincos), ::Type{<:ArbLike}) = MA.IsMutable()

base_to_arblib_mutable(::typeof(Base.sin)) = sin!
base_to_arblib_mutable(::typeof(Base.cos)) = cos!

function MA.operate_to!(r::R, op::Op, x::ArbLike) where {R<:ArbLike, Op<:SinAndCos}
  base_to_arblib_mutable(op)(r, x)::R
end

function MA.operate_to!(r::R, ::typeof(Base.sincos), x::ArbLike) where {R<:NTuple{2,ArbLike}}
  sin_cos!(r..., x)
  r::R
end
