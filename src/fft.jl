"""
    AcbFFTPlan(len::Integer; prec::Integer = _current_precision())

Precomputed FFT plan for use with [`fft`](@ref) and [`fft!`](@ref), as
well as their inverse counterparts.

Precomputing a plan can speed up computations when multiple FFTs of
the same size are computed.

An optimal plan is automatically determined based on the given
arguments.
"""
struct AcbFFTPlan
    plan::acb_dft_pre_struct

    function AcbFFTPlan(len::Integer; prec::Integer = _current_precision())
        return new(acb_dft_pre_struct(len; prec))
    end
end

fft_plan_size(plan::AcbFFTPlan) = plan.plan.n

_precision_with_base_2(plan::AcbFFTPlan) = plan.plan.prec
Base.precision(plan::AcbFFTPlan; base::Integer = 2) = _precision_in_base(plan, base)

function Base.show(io::IO, plan::AcbFFTPlan)
    print(io, "AcbFFTPlan($(fft_plan_size(plan)); prec = $(precision(plan)))")
end

"""
    fft!(w::AcbVectorOrRef, v::AcbVectorOrRef[, plan::AcbFFTPlan])

Compute the FFT of `v`, storing the result inplace in `w`. It
optionally takes a precomputed [`AcbFFTPlan`](@ref).

The input and output are allowed to alias.

See also [`fft`](@ref) and [`ifft!`](@ref)
"""
function fft!(w::AcbVectorOrRef, v::AcbVectorOrRef)
    @boundscheck (
        length(v) == length(w) ||
        throw(DimensionMismatch("v has size $(length(v)), w has size $(length(w))"))
    )
    return dft!(w, v)
end

function fft!(w::AcbVectorOrRef, v::AcbVectorOrRef, plan::AcbFFTPlan)
    @boundscheck (
        length(v) == length(w) ||
        throw(DimensionMismatch("v has size $(length(v)), w has size $(length(w))"))
    )
    @boundscheck length(v) == fft_plan_size(plan) || throw(
        DimensionMismatch("v has size $(length(v)), plan has size $(fft_plan_size(plan))"),
    )
    return dft_precomp!(w, v, plan.plan)
end

"""
    fft(v::AcbVectorOrRef[, plan::AcbFFTPlan])

Compute the FFT of `v`. It optionally takes a precomputed
[`AcbFFTPlan`](@ref).

See also [`fft!`](@ref) and [`ifft`](@ref)
"""
fft(v::AcbVectorOrRef) = fft!(similar(v), v)
fft(v::AcbVectorOrRef, plan::AcbFFTPlan) = fft!(similar(v), v, plan)

"""
    ifft!(w::AcbVectorOrRef, v::AcbVectorOrRef[, plan::AcbFFTPlan])

Compute the inverse FFT of `v`, storing the result inplace in `w`. It
optionally takes a precomputed [`AcbFFTPlan`](@ref).

The input and output are allowed to alias.

See also [`ifft`](@ref) and [`fft!`](@ref)
"""
function ifft!(w::AcbVectorOrRef, v::AcbVectorOrRef)
    @boundscheck (
        length(v) == length(w) ||
        throw(DimensionMismatch("v has size $(length(v)), w has size $(length(w))"))
    )
    return dft_inverse!(w, v)
end

function ifft!(w::AcbVectorOrRef, v::AcbVectorOrRef, plan::AcbFFTPlan)
    @boundscheck (
        length(v) == length(w) ||
        throw(DimensionMismatch("v has size $(length(v)), w has size $(length(w))"))
    )
    @boundscheck length(v) == fft_plan_size(plan) || throw(
        DimensionMismatch("v has size $(length(v)), plan has size $(fft_plan_size(plan))"),
    )
    return dft_inverse_precomp!(w, v, plan.plan)
end

"""
    ifft(v::AcbVectorOrRef[, plan::AcbFFTPlan])

Compute the inverse FFT of `v`. It optionally takes a precomputed
[`AcbFFTPlan`](@ref)

See also [`ifft!`](@ref) and [`fft`](@ref)
"""
ifft(v::AcbVectorOrRef) = ifft!(similar(v), v)
ifft(v::AcbVectorOrRef, plan::AcbFFTPlan) = ifft!(similar(v), v, plan)
