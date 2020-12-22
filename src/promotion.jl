### Internal ###
Base.promote_rule(::Type{<:MagOrRef}, ::Type{T}) where {T<:Union{MagOrRef}} = Mag
Base.promote_rule(::Type{<:ArfOrRef}, ::Type{T}) where {T<:Union{MagOrRef,ArfOrRef}} = Arf
Base.promote_rule(
    ::Type{<:ArbOrRef},
    ::Type{T},
) where {T<:Union{MagOrRef,ArfOrRef,ArbOrRef}} = Arb
Base.promote_rule(
    ::Type{<:AcbOrRef},
    ::Type{T},
) where {T<:Union{MagOrRef,ArfOrRef,ArbOrRef,AcbOrRef}} = Acb

Base.promote_rule(
    ::Type{<:MagOrRef},
    ::Type{T},
) where {T<:Union{ArfOrRef,ArbOrRef,AcbOrRef}} = _nonreftype(T)
Base.promote_rule(::Type{<:ArfOrRef}, ::Type{T}) where {T<:Union{ArbOrRef,AcbOrRef}} =
    _nonreftype(T)
Base.promote_rule(::Type{<:ArbOrRef}, ::Type{T}) where {T<:Union{AcbOrRef}} = _nonreftype(T)

### External ###
# TODO: How should we handle promotions for Mag? The type is very
# limited so it's likely not a good idea to promote everything to it.

# Always prioritise Arb types
Base.promote_rule(::Type{<:MagOrRef}, ::Type{<:Base.GMP.CdoubleMax}) = Mag
Base.promote_rule(::Type{<:ArfOrRef}, ::Type{<:Real}) = Arf
Base.promote_rule(::Type{<:ArbOrRef}, ::Type{<:Real}) = Arb
Base.promote_rule(::Type{<:AcbOrRef}, ::Type{<:Number}) = Acb

# Handle BigFloat separately since it also defines a catch all case
Base.promote_rule(
    ::Type{BigFloat},
    ::Type{T},
) where {T<:Union{ArfOrRef,ArbOrRef,AcbOrRef}} = _nonreftype(T)

# Arb should be promoted to Acb together with complex values. Note
# that Arf is promoted to Complex{Arf}.
Base.promote_rule(::Type{<:ArbOrRef}, ::Type{<:Complex}) = Acb
