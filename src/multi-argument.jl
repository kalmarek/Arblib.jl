# Contains implementation of multi-argument versions of +, *, min and
# max. They are more efficient because the don't need to allocate as
# much. This is similar to the specialised methods for + and * for
# BigFloat.

for (jf, af) in [(:+, :add!), (:*, :mul!), (:min, :min!), (:max, :max!)]
    @eval function Base.$jf(a::MagOrRef, b::MagOrRef, c::MagOrRef)
        res = Mag()
        $af(res, a, b)
        $af(res, res, c)
        return res
    end

    @eval function Base.$jf(a::MagOrRef, b::MagOrRef, c::MagOrRef, d::MagOrRef)
        res = Mag()
        $af(res, a, b)
        $af(res, res, c)
        $af(res, res, d)
        return res
    end

    @eval function Base.$jf(a::MagOrRef, b::MagOrRef, c::MagOrRef, d::MagOrRef, e::MagOrRef)
        res = Mag()
        $af(res, a, b)
        $af(res, res, c)
        $af(res, res, d)
        $af(res, res, e)
        return res
    end
end

for T in (ArfOrRef, ArbOrRef, AcbOrRef)
    @eval @inline _precision(x::$T, y::$T, z::$T, rest::Vararg{S}) where {S<:$T} =
        max(precision(x), _precision(y, z, rest...))

    for (jf, af) in [(:+, :add!), (:*, :mul!), (:min, :min!), (:max, :max!)]
        T == AcbOrRef && jf == :min && continue
        T == AcbOrRef && jf == :max && continue

        @eval function Base.$jf(a::$T, b::$T, c::$T)
            res = $(_nonreftype(T))(prec = _precision(a, b, c))
            $af(res, a, b)
            $af(res, res, c)
            return res
        end

        @eval function Base.$jf(a::$T, b::$T, c::$T, d::$T)
            res = $(_nonreftype(T))(prec = _precision(a, b, c, d))
            $af(res, a, b)
            $af(res, res, c)
            $af(res, res, d)
            return res
        end

        @eval function Base.$jf(a::$T, b::$T, c::$T, d::$T, e::$T)
            res = $(_nonreftype(T))(prec = _precision(a, b, c, d, e))
            $af(res, a, b)
            $af(res, res, c)
            $af(res, res, d)
            $af(res, res, e)
            return res
        end
    end
end
