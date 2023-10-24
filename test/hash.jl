@testset "Hash" begin
    @testset "decompose" begin

    end

    @testset "Mag, Arf, Arb, Acb" begin
        Ts1 = (Mag, Arf, Arb, Acb)

        @test all(isequal(hash(0)), hash.(zero.(Ts1)))
        @test all(isequal(hash(1)), hash.(one.(Ts1)))
        @test all(isequal(hash(2)), hash.(convert.(Ts1, 2)))
        @test all(isequal(hash(Mag(0.1))), hash.(convert.(Ts1, Mag(0.1))))
        @test all(
            isequal(hash(Mag(typemax(UInt), typemax(Int)))),
            hash.(convert.(Ts1, Mag(typemax(UInt), typemax(Int)))),
        )
        @test all(isequal(hash(Inf)), hash.(convert.(Ts1, Inf)))

        Ts2 = (Arf, Arb, Acb)
        @test all(isequal(hash(-1)), hash.(convert.(Ts2, -1)))
        @test all(isequal(hash(-Inf)), hash.(convert.(Ts2, -Inf)))
        @test all(isequal(hash(NaN)), hash.(convert.(Ts2, NaN)))

        @test hash(0 + im) == hash(Acb(0, 1))
        @test hash(1 + im) == hash(Acb(1, 1))
        @test hash(0 + Inf * im) == hash(Acb(0, Inf))
        @test hash(0 + NaN * im) == hash(Acb(0, NaN))

        @test hash(Arb(π)) == hash(Acb(π)) != hash(midpoint(Arb(π)))
        @test hash(Acb(π)) != hash(Acb(0, π))
    end

    @testset "Poly, Series" begin
        # Poly
        for T in (ArbPoly, AcbPoly)
            @test hash(T()) == hash(T()) == hash(T(prec = 80))
            @test hash(T(1)) == hash(T(1)) == hash(T(1, prec = 80))
            @test hash(T([1, 2, 3])) == hash(T([1, 2, 3])) == hash(T([1, 2, 3], prec = 80))

            @test hash(T([1, 2, 3])) != hash(T([1, 2, 4]))
            @test hash(T(0)) != hash(T(1))
        end

        # Series
        for T in (ArbSeries, AcbSeries)
            @test hash(T()) == hash(T()) == hash(T(prec = 80))
            @test hash(T(1)) == hash(T(1)) == hash(T(1, prec = 80))
            @test hash(T([1, 2, 3])) == hash(T([1, 2, 3])) == hash(T([1, 2, 3], prec = 80))

            @test hash(T([1, 2, 3])) != hash(T([1, 2, 4]))
            @test hash(T(0)) != hash(T(1))

            # Degree 0 series should have same hash as the only coefficient
            @test hash(T()) == hash(0)
            @test hash(T(1)) == hash(1)
            @test hash(T(π)) == hash(T(π))
        end
    end

    @testset "Vector, Matrix" begin
        # Vector
        for T in (ArbVector, AcbVector)
            @test hash(T([], prec = 256)) ==
                  hash(T([], prec = 256)) ==
                  hash(T([], prec = 80)) # FIXME
            @test hash(T([1])) == hash(T([1])) == hash(T([1], prec = 80))
            @test hash(T([1, 2, 3])) == hash(T([1, 2, 3])) == hash(T([1, 2, 3], prec = 80))

            @test hash(T([1, 2, 3])) != hash(T([1, 2, 4]))
            @test hash(T([0])) != hash(T([1]))
        end

        # Matrix
        for T in (ArbMatrix, AcbMatrix)
            @test hash(T([], prec = 256)) ==
                  hash(T([], prec = 256)) ==
                  hash(T([], prec = 80)) # FIXME
            @test hash(T([1])) == hash(T([1])) == hash(T([1], prec = 80))
            @test hash(T([1, 2, 3])) == hash(T([1, 2, 3])) == hash(T([1, 2, 3], prec = 80))

            @test hash(T([1, 2, 3])) != hash(T([1, 2, 4]))
            @test hash(T([0])) != hash(T([1]))
        end
    end

    @testset "struct" begin
        let cstruct = Arblib.cstruct
            # Test so that hashes for different types don't overlap and
            # that hashes of same values are same
            @test hash(cstruct(Mag(1))) == hash(cstruct(Mag(1))) != hash(Mag(1))
            @test hash(cstruct(Arf(1 // 3))) ==
                  hash(cstruct(Arf(1 // 3))) !=
                  hash(Arf(1 // 3))
            @test hash(cstruct(Arb(1 // 3))) ==
                  hash(cstruct(Arb(1 // 3))) !=
                  hash(Arb(1 // 3))
            @test hash(cstruct(Acb(1 // 3))) ==
                  hash(cstruct(Acb(1 // 3))) !=
                  hash(Acb(1 // 3))
            @test hash(cstruct(ArbVector([1]))) ==
                  hash(cstruct(ArbVector([1]))) !=
                  hash(ArbVector([1]))
            @test hash(cstruct(AcbVector([1]))) ==
                  hash(cstruct(AcbVector([1]))) !=
                  hash(AcbVector([1]))
            @test hash(cstruct(ArbPoly([1]))) ==
                  hash(cstruct(ArbPoly([1]))) !=
                  hash(ArbPoly([1]))
            @test hash(cstruct(AcbPoly([1]))) ==
                  hash(cstruct(AcbPoly([1]))) !=
                  hash(AcbPoly([1]))
            @test hash(cstruct(ArbMatrix([1]))) ==
                  hash(cstruct(ArbMatrix([1]))) !=
                  hash(ArbMatrix([1]))
            @test hash(cstruct(AcbMatrix([1]))) ==
                  hash(cstruct(AcbMatrix([1]))) !=
                  hash(AcbMatrix([1]))

            @test hash(cstruct(Mag())) != hash(cstruct(Arf()))
            @test hash(cstruct(Arf())) != hash(cstruct(Arb()))
            @test hash(cstruct(Arb())) != hash(cstruct(Acb()))
            @test hash(cstruct(ArbVector([1]))) != hash(cstruct(AcbVector([1])))
            @test hash(cstruct(ArbPoly([1]))) != hash(cstruct(AcbPoly([1])))
            @test hash(cstruct(ArbMatrix([1]))) != hash(cstruct(AcbMatrix([1])))
        end
    end
end
