@testset "AcbMatrix" begin
    M = Arblib.AcbMatrix(4, 4, prec = 128)
    @test size(M) == (4, 4)
    @test precision(M) == 128

    x = Acb(1.5)
    M[2, 2] = x
    @test M[2, 2] == x
    @test M[2, 2] isa Acb
    @test precision(M[2, 2]) == 128

    Arblib.add!(M, M, M)
    M2 = Arblib.AcbMatrix(4, 4, prec = 128)
    M2[2, 2] = Acb(3)
    @test M == M2

    A = AcbMatrix([Acb(i + j) for i = 1:4, j = 1:4])
    @test A[4, 4] == Acb(8)
end
