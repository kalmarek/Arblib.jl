Base.eps(T::Type{<:Union{ArfOrRef,ArbOrRef,AcbOrRef}}) = eps(one(T))
Base.eps(x::ArfOrRef) = Arf(set_ulp!(Mag(), x, prec = precision(x)), prec = precision(x))
Base.eps(x::ArbOrRef) =
    Arb(set_ulp!(Mag(), midref(x), prec = precision(x)), prec = precision(x))
Base.eps(x::AcbOrRef) =
    Acb(set_ulp!(Mag(), midref(realref(x)), prec = precision(x)), prec = precision(x))
