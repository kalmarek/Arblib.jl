### Internal ###
# Prioritise left
Base.promote_rule(::Type{<:MagOrRef}, ::Type{<:Union{MagOrRef}}) = Mag
Base.promote_rule(::Type{<:ArfOrRef}, ::Type{<:Union{MagOrRef,ArfOrRef}}) = Arf
Base.promote_rule(::Type{<:ArbOrRef}, ::Type{<:Union{MagOrRef,ArfOrRef,ArbOrRef}}) = Arb
Base.promote_rule(
    ::Type{<:AcbOrRef},
    ::Type{<:Union{MagOrRef,ArfOrRef,ArbOrRef,AcbOrRef}},
) = Acb
Base.promote_rule(::Type{ArbSeries}, ::Type{<:Union{MagOrRef,ArfOrRef,ArbOrRef}}) =
    ArbSeries
Base.promote_rule(
    ::Type{AcbSeries},
    ::Type{<:Union{MagOrRef,ArfOrRef,ArbOrRef,AcbOrRef,ArbSeries}},
) = AcbSeries

# Prioritise right
Base.promote_rule(
    ::Type{<:MagOrRef},
    ::Type{T},
) where {T<:Union{ArfOrRef,ArbOrRef,AcbOrRef,ArbSeries,AcbSeries}} = _nonreftype(T)
Base.promote_rule(
    ::Type{<:ArfOrRef},
    ::Type{T},
) where {T<:Union{ArbOrRef,AcbOrRef,ArbSeries,AcbSeries}} = _nonreftype(T)
Base.promote_rule(::Type{<:ArbOrRef}, ::Type{T}) where {T<:Union{AcbOrRef,AcbSeries}} =
    _nonreftype(T)
Base.promote_rule(::Type{<:AcbOrRef}, ::Type{T}) where {T<:Union{AcbSeries}} =
    _nonreftype(T)
Base.promote_rule(::Type{<:ArbSeries}, ::Type{T}) where {T<:Union{AcbSeries}} =
    _nonreftype(T)

# Make complex
Base.promote_rule(::Type{ArbSeries}, ::Type{<:AcbOrRef}) = AcbSeries

### External ###
# TODO: How should we handle promotions for Mag? The type is very
# limited so it's likely not a good idea to promote everything to it.

# Always prioritise Arb types
Base.promote_rule(::Type{<:MagOrRef}, ::Type{<:Base.GMP.CdoubleMax}) = Mag
Base.promote_rule(::Type{<:ArfOrRef}, ::Type{<:Real}) = Arf
Base.promote_rule(::Type{<:ArbOrRef}, ::Type{<:Real}) = Arb
Base.promote_rule(::Type{<:AcbOrRef}, ::Type{<:Number}) = Acb
Base.promote_rule(::Type{ArbSeries}, ::Type{<:Real}) = ArbSeries
Base.promote_rule(::Type{AcbSeries}, ::Type{<:Number}) = AcbSeries

# Handle BigFloat separately since it also defines a catch all case
Base.promote_rule(
    ::Type{BigFloat},
    ::Type{T},
) where {T<:Union{ArfOrRef,ArbOrRef,AcbOrRef,ArbSeries,AcbSeries}} = _nonreftype(T)

# Arb and ArbSeries should be promoted to Acb and AcbSeries
# respectively together with complex values. Note that Arf is promoted
# to Complex{Arf}.
Base.promote_rule(::Type{<:ArbOrRef}, ::Type{<:Complex}) = Acb
Base.promote_rule(::Type{ArbSeries}, ::Type{<:Complex}) = AcbSeries
