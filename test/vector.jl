@testset "Vector: $TRef" for (TVec, T, TRef) in [
    (ArbVector, Arb, Arb),
    (AcbVector, Acb, Acb),
    (ArbRefVector, Arb, ArbRef),
    (AcbRefVector, Acb, AcbRef),
]
    V = TVec(4, prec = 128)
    @test size(V) == (4,)
    @test precision(V) == 128

    x = T(1.5)
    V[3] = x
    @test V[3] == x
    @test V[3] isa TRef
    @test !isempty(sprint(show, V[3]))
    @test precision(V[3]) == 128

    Arblib.add!(V, V, V)
    V2 = TVec(4, prec = 128)
    V2[3] = T(3)
    @test V == V2

    A = TVec([T(i + 1) for i = 2:5])
    @test A[end] == T(6)

    A = TVec([i + j for i = 1:4 for j = 1:4]; prec = 96)
    @test A[16] == T(8)
    @test precision(A) == 96
    @test precision(A[14]) == 96

    @test ref(A, 16) isa Union{ArbRef,AcbRef}

    # arithmetic
    AInt = [1, 2, 3, 4]
    BInt = [5, 6, 7, 8]
    A = TVec(AInt; prec = 96)
    B = TVec(BInt; prec = 96)
    @test A - B == AInt - BInt
    @test precision(A - B) == 96
    @test (A - B) isa TVec
    @test -B == -BInt
    @test -B isa TVec
    @test -B + A == A - B
    @test precision(-B + A) == 96

    C = TVec(length(A); prec = 96)
    Arblib.add!(C, A, B)
    @test C == AInt + BInt
    # test original signature
    D = TVec(length(A); prec = 96)
    Arblib.add!(D, A, B, length(AInt), 96)
    @test D == AInt + BInt

    @testset "similar" begin
        A = TVec(5; prec = 96)

        a = similar(A)
        @test a isa TVec
        @test precision(a) == precision(A)

        a = similar(A, TRef, 3)
        @test a isa TVec
        @test precision(a) == precision(A)

        for (ElT, VT, MT) in (
            (Arb, ArbVector, ArbMatrix),
            # (Acb, AcbVector, AcbMatrix),
            # (ArbRef, ArbRefVector, ArbRefMatrix),
            (AcbRef, AcbRefVector, AcbRefMatrix),
        )
            a = similar(A, ElT, 3)
            @test a isa VT
            @test precision(a) == precision(A)

            a = similar(A, ElT, (3,2))
            @test a isa MT
            @test precision(a) == precision(A)
        end
    end
end

@testset "VectorRef: $T" for (T, TRef) in
                             [(ArbVector, ArbRefVector), (AcbVector, AcbRefVector)]
    A = T(5; prec = 96)
    A[4] = 3

    B = TRef(A)
    @test B isa TRef
    @test precision(B) == 96
    B[4] = 4
    @test A[4] == 4
    @test B[4] == 4
    C = T(B)
    @test C == A
    @test C[4] == 4
end

