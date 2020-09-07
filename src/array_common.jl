for (ElT, n, T) in (
    (Acb, 2, :AcbMatrix),
    (AcbRef, 2, :AcbRefMatrix),
    (Arb, 2, :ArbMatrix),
    (ArbRef, 2, :ArbRefMatrix),
    (Acb, 1, :AcbVector),
    (AcbRef, 1, :AcbRefVector),
    (Arb, 1, :ArbVector),
    (ArbRef, 1, :ArbRefVector),
)
    @eval begin
        function Base.similar(A::Matrices, ::Type{<:$ElT}, dims::Dims{$n})
            return $T(dims..., prec = precision(A))
        end
        function Base.similar(A::Vectors, ::Type{<:$ElT}, dims::Dims{$n})
            return $T(dims..., prec = precision(A))
        end
    end
end
