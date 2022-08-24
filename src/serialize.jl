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

function Serialization.serialize(
    s::Serialization.AbstractSerializer,
    v::Union{arb_vec_struct,acb_vec_struct},
)
    Serialization.serialize_type(s, typeof(v))
    Serialization.serialize(s, size(v)[1])
    for i = 1:size(v)[1]
        Serialization.serialize(s, unsafe_load(v[i]))
    end
end

function Serialization.serialize(
    s::Serialization.AbstractSerializer,
    v::Union{arb_mat_struct,acb_mat_struct},
)
    Serialization.serialize_type(s, typeof(v))
    Serialization.serialize(s, size(v))
    for i = 1:size(v)[1]
        for j = 1:size(v)[2]
            Serialization.serialize(s, unsafe_load(v[i, j]))
        end
    end
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

function Serialization.deserialize(
    s::Serialization.AbstractSerializer,
    T::Type{<:Union{arb_vec_struct,acb_vec_struct}},
)
    n = Serialization.deserialize(s)
    res = T(n)
    for i = 1:n
        res[i] = Serialization.deserialize(s)
    end
    return res
end

function Serialization.deserialize(
    s::Serialization.AbstractSerializer,
    T::Type{<:Union{arb_mat_struct,acb_mat_struct}},
)
    r, c = Serialization.deserialize(s)
    res = T(r, c)
    for i = 1:r
        for j = 1:c
            res[i, j] = Serialization.deserialize(s)
        end
    end
    return res
end
