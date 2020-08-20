@testset "AcbVector" begin
    V = Arblib.AcbVector(4, prec = 128)
    @test size(V) == (4,)
    @test precision(V) == 128

    x = Acb(1.5)
    V[3] = x
    @test V[3] == x
    @test V[3] isa AcbRef
    @test precision(V[3]) == 128
    @test !isempty(sprint(show, V[3]))

    Arblib.add!(V, V, V, length(V))
    V2 = Arblib.AcbVector(4, prec = 128)
    V2[3] = Acb(3)
    @test V == V2

    A = AcbVector([Acb(i + 1) for i = 2:5])
    @test A[end] == Acb(6)

    A = AcbVector([i + j for i = 1:4 for j = 1:4])
    @test A[16] == Acb(8)
end
