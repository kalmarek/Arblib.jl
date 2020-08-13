@testset "LinearAlgebra" begin
    Af = rand(ComplexF64, 3, 3)
    bf = rand(ComplexF64, 3)
    A = AcbMatrix(Acb.(Af))
    b = AcbMatrix(Acb.(bf))
    c = AcbMatrix(3, 1)

    # lu factorization
    ldiv!(c, A, b)
    c′ = A \ b
    @test Arblib.overlaps(c, c′) == 1
    ldiv!(c, lu(A), b)
    @test Arblib.overlaps(c, c′) == 1
    ldiv!(c, lu!(copy(A)), b)
    @test Arblib.overlaps(c, c′) == 1
    d = copy(b)
    ldiv!(lu(A), d)
    @test Arblib.overlaps(d, c′) == 1

    # inv
    id = copy(A)
    Arblib.one!(id)
    @test Bool(Arblib.contains(inv(A) * A, id))
end
