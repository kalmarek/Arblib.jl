module ArblibForwardDiffExt

using Arblib: Arb
using ForwardDiff: Dual

function Base.promote_rule(::Type{Arb}, ::Type{Dual{T, V, N}}) where {T, V, N}
    return Dual{T, promote_type(Arb, V), N}
end

end # module
