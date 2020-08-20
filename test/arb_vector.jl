@testset "ArbVector" begin
    V = Arblib.ArbVector(4, prec = 128)
    @test size(V) == (4,)
    @test precision(V) == 128

    x = Arb(1.5)
    V[3] = x
    @test V[3] == x
    @test V[3] isa ArbRef
    @test !isempty(sprint(show, V[3]))
    @test precision(V[3]) == 128

    Arblib.add!(V, V, V, length(V))
    V2 = Arblib.ArbVector(4, prec = 128)
    V2[3] = Arb(3)
    @test V == V2

    A = ArbVector([Arb(i + 1) for i = 2:5])
    @test A[end] == Arb(6)

    A = ArbVector([i + j for i = 1:4 for j = 1:4])
    @test A[16] == Arb(8)
end
