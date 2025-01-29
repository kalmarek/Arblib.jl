ArfRef(; prec::Integer = DEFAULT_PRECISION[]) = Arf(; prec)
AcfRef(; prec::Integer = DEFAULT_PRECISION[]) = Acf(; prec)
ArbRef(; prec::Integer = DEFAULT_PRECISION[]) = Arb(; prec)
AcbRef(; prec::Integer = DEFAULT_PRECISION[]) = Acb(; prec)
MagRef() = Mag()

function ArfRef(
    ptr::Ptr{arf_struct},
    parent::Union{acf_struct,arb_struct,AcfRef,ArbRef};
    prec::Integer = DEFAULT_PRECISION[],
)
    ArfRef(ptr, prec, parent)
end
function AcfRef(
    ptr::Ptr{acf_struct},
    parent::Union{Nothing};
    prec::Integer = DEFAULT_PRECISION[],
)
    AcfRef(ptr, prec, parent)
end
function ArbRef(
    ptr::Ptr{arb_struct},
    parent::Union{acb_struct,AcbRef,arb_vec_struct,arb_mat_struct};
    prec::Integer = DEFAULT_PRECISION[],
)
    ArbRef(ptr, prec, parent)
end
function AcbRef(
    ptr::Ptr{acb_struct},
    parent::Union{Nothing,acb_vec_struct,acb_mat_struct};
    prec::Integer = DEFAULT_PRECISION[],
)
    AcbRef(ptr, prec, parent)
end

Mag(x::MagRef) = set!(Mag(), x)
Arf(x::ArfRef; prec::Integer = precision(x)) = set!(Arf(; prec), x)
Acf(x::AcfRef; prec::Integer = precision(x)) = set!(Acf(; prec), x)
Arb(x::ArbRef; prec::Integer = precision(x)) = set!(Arb(; prec), x)
Acb(x::AcbRef; prec::Integer = precision(x)) = set!(Acb(; prec), x)

Base.zero(::Union{Type{MagRef},MagRef}) = zero(Mag)
Base.one(::Union{Type{MagRef},MagRef}) = one(Mag)
for (TRef, T) in [(ArfRef, Arf), (AcfRef, Acf), (ArbRef, Arb), (AcbRef, Acb)]
    @eval begin
        Base.zero(x::$TRef) = $T(0, prec = precision(x))
        Base.zero(::Type{$TRef}) = zero($T)
        Base.one(x::$TRef) = $T(1, prec = precision(x))
        Base.one(::Type{$TRef}) = one($T)
    end
end

Base.getindex(x::MagRef) = Mag(x)
Base.getindex(x::ArfRef) = Arf(x)
Base.getindex(x::AcfRef) = Acf(x)
Base.getindex(x::ArbRef) = Arb(x)
Base.getindex(x::AcbRef) = Acb(x)

"""
    realref(z::AcfLike, prec = precision(z))

Return an `ArfRef` referencing the real part of `z`.
"""
function realref(z::AcfLike; prec = precision(z))
    real_ptr = ccall(@libflint(acf_real_ptr), Ptr{arf_struct}, (Ref{acf_struct},), z)
    ArfRef(real_ptr, prec, parentstruct(z))
end

"""
    imagref(z::AcfLike, prec = precision(z))

Return an `ArfRef` referencing the imaginary part of `z`.
"""
function imagref(z::AcfLike; prec = precision(z))
    real_ptr = ccall(@libflint(acf_imag_ptr), Ptr{arf_struct}, (Ref{acf_struct},), z)
    ArfRef(real_ptr, prec, parentstruct(z))
end

"""
    midref(x::ArbLike, prec = precision(x))

Return an `ArfRef` referencing the midpoint of `x`.
"""
function midref(x::ArbLike, prec = precision(x))
    mid_ptr = ccall(@libflint(arb_mid_ptr), Ptr{arf_struct}, (Ref{arb_struct},), x)
    ArfRef(mid_ptr, prec, parentstruct(x))
end

"""
    radref(x::ArbLike, prec = precision(x))

Return a `MagRef` referencing the radius of `x`.
"""
function radref(x::ArbLike)
    rad_ptr = ccall(@libflint(arb_rad_ptr), Ptr{mag_struct}, (Ref{arb_struct},), x)
    MagRef(rad_ptr, parentstruct(x))
end

"""
    realref(z::AcbLike, prec = precision(z))

Return an `ArbRef` referencing the real part of `z`.
"""
function realref(z::AcbLike; prec = precision(z))
    real_ptr = ccall(@libflint(acb_real_ptr), Ptr{arb_struct}, (Ref{acb_struct},), z)
    ArbRef(real_ptr, prec, parentstruct(z))
end

"""
    imagref(z::AcbLike, prec = precision(z))

Return an `ArbRef` referencing the imaginary part of `z`.
"""
function imagref(z::AcbLike; prec = precision(z))
    real_ptr = ccall(@libflint(acb_imag_ptr), Ptr{arb_struct}, (Ref{acb_struct},), z)
    ArbRef(real_ptr, prec, parentstruct(z))
end
