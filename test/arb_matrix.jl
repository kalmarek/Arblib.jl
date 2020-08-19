@testset "ArbMatrix" begin
    M = Arblib.ArbMatrix(4, 4, prec = 128)
    @test size(M) == (4, 4)
    @test precision(M) == 128

    x = Arb(1.5)
    M[2, 2] = x
    @test M[2, 2] == x
    @test M[2, 2] isa ArbRef
    @test precision(M[2, 2]) == 128
    @test !isempty(sprint(show, M[2, 2]))

    Arblib.add!(M, M, M)
    M2 = Arblib.ArbMatrix(4, 4, prec = 128)
    M2[2, 2] = Arb(3)
    @test M == M2

    A = ArbMatrix([Arb(i + j) for i = 1:4, j = 1:4])
    @test A[4, 4] == Arb(8)
end
