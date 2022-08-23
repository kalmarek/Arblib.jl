# Compare with BigInt in julia/stdlib/v1.7/Serialization/src/Serialization.jl
function Serialization.serialize(
    s::Serialization.AbstractSerializer,
    x::Union{mag_struct,arf_struct,arb_struct},
)
    Serialization.serialize_type(s, typeof(x))
    Serialization.serialize(s, dump_string(x))
end

function Serialization.serialize(s::Serialization.AbstractSerializer, x::acb_struct)
    Serialization.serialize_type(s, typeof(x))
    str = dump_string(Arblib.realref(x)) * " " * dump_string(Arblib.imagref(x))
    Serialization.serialize(s, str)
end

Serialization.deserialize(
    s::Serialization.AbstractSerializer,
    T::Type{<:Union{mag_struct,arf_struct,arb_struct}},
) = Arblib.load_string!(T(), Serialization.deserialize(s))

function Serialization.deserialize(s::Serialization.AbstractSerializer, T::Type{acb_struct})
    str = Serialization.deserialize(s)
    # Three spaces in the real part, so we are looking for
    spaces = findall(" ", str)
    @assert length(spaces) == 7

    real_str = str[1:spaces[4].start-1]
    imag_str = str[spaces[4].stop+1:end]

    res = acb_struct()
    Arblib.load_string!(Arblib.realref(res), real_str)
    Arblib.load_string!(Arblib.imagref(res), imag_str)
    return res
end
