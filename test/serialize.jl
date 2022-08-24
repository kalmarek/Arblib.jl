@testset "Serialize" begin
    # Tests are organized similar to in Serialization package

    function create_serialization_stream(f::Function)
        s = IOBuffer()
        f(s)
        close(s)
    end

    isequal_and_prec_equal(x, y) = isequal(x, y) && precision(x) == precision(y)

    # Mag
    create_serialization_stream() do s
        for x in (Mag(), Mag(1), Mag(π), Mag(typemax(UInt), typemax(Int)))
            Serialization.serialize(s, x)
            Arblib.zero!(x) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal(Serialization.deserialize(s), Mag())
        @test isequal(Serialization.deserialize(s), Mag(1))
        @test isequal(Serialization.deserialize(s), Mag(π))
        @test isequal(Serialization.deserialize(s), Mag(typemax(UInt), typemax(Int)))
    end

    # Arf
    create_serialization_stream() do s
        for x in (
            Arf(),
            Arf(1),
            Arf(-Inf),
            Arf(Inf),
            Arf(NaN),
            Arf(1 // 3, prec = 64),
            Arf(1 // 3, prec = 256),
            Arf(1 // 3, prec = 512),
        )
            Serialization.serialize(s, x)
            Arblib.zero!(x) # To catch aliasing issues

        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf())
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(1))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(-Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(NaN))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(1 // 3, prec = 64))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(1 // 3, prec = 256))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(1 // 3, prec = 512))
    end

    # Arb
    create_serialization_stream() do s
        for x in (
            Arb(),
            Arb(1),
            Arb(-Inf),
            Arb(Inf),
            Arb(NaN),
            Arb(π, prec = 64),
            Arb(π, prec = 256),
            Arb(π, prec = 512),
        )

            Serialization.serialize(s, x)
            Arblib.zero!(x) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb())
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(1))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(-Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(NaN))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(π, prec = 64))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(π, prec = 256))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(π, prec = 512))
    end

    # Acb
    create_serialization_stream() do s
        for x in (
            Acb(),
            Acb(1),
            Acb(0, 1),
            Acb(1, 2),
            Acb(-Inf, Inf),
            Acb(Inf, -Inf),
            Acb(NaN),
            Acb(0, NaN),
            Acb(π, ℯ, prec = 64),
            Acb(π, ℯ, prec = 256),
            Acb(π, ℯ, prec = 512),
        )
            Serialization.serialize(s, x)
            Arblib.zero!(x) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb())
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(1))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(0, 1))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(1, 2))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(-Inf, Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(Inf, -Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(NaN))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(0, NaN))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(π, ℯ, prec = 64))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(π, ℯ, prec = 256))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(π, ℯ, prec = 512))
    end

    # ArbVector
    create_serialization_stream() do s
        for v in (
            ArbVector([]),
            ArbVector(Arb[1]),
            ArbVector(Arb[1, 2, 3, 4]),
            ArbVector(Arb[1//3, π, ℯ, NaN]),
        )
            Serialization.serialize(s, v)
            Arblib.zero!(v) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbVector([]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbVector(Arb[1]))
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            ArbVector(Arb[1, 2, 3, 4]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            ArbVector(Arb[1//3, π, ℯ, NaN]),
        )
    end

    # AcbVector
    create_serialization_stream() do s
        for v in (
            AcbVector([]),
            AcbVector(Acb[1]),
            AcbVector(Acb[1, 2, 3, 4]),
            AcbVector(Acb[1//3, π, ℯ, NaN]),
            AcbVector(im * Acb[1//3, π, ℯ, NaN]),
            AcbVector((1 + 2im) * Acb[1//3, π, ℯ, NaN]),
        )
            Serialization.serialize(s, v)
            Arblib.zero!(v) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbVector([]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbVector(Acb[1]))
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbVector(Acb[1, 2, 3, 4]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbVector(Acb[1//3, π, ℯ, NaN]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbVector(im * Acb[1//3, π, ℯ, NaN]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbVector((1 + 2im) * Acb[1//3, π, ℯ, NaN]),
        )
    end

    # ArbMatrix
    create_serialization_stream() do s
        for v in (
            ArbMatrix([]),
            ArbMatrix([]),
            ArbMatrix(Arb[1;;]),
            ArbMatrix(Arb[1 2; 3 4]),
            ArbMatrix(Arb[1 2 3; 4 5 6]),
            ArbMatrix(Arb[1//3 π; ℯ NaN]),
        )
            Serialization.serialize(s, v)
            Arblib.zero!(v) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbMatrix([]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbMatrix([]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbMatrix(Arb[1;;]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbMatrix(Arb[1 2; 3 4]))
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            ArbMatrix(Arb[1 2 3; 4 5 6]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            ArbMatrix(Arb[1//3 π; ℯ NaN]),
        )
    end

    # AcbMatrix
    create_serialization_stream() do s
        for v in (
            AcbMatrix([]),
            AcbMatrix([]),
            AcbMatrix(Acb[1;;]),
            AcbMatrix(Acb[1 2; 3 4]),
            AcbMatrix(Acb[1 2 3; 4 5 6]),
            AcbMatrix(Acb[1//3 π; ℯ NaN]),
            AcbMatrix(im * Acb[1//3 π; ℯ NaN]),
            AcbMatrix((1 + 2im) * Acb[1//3 π; ℯ NaN]),
        )
            Serialization.serialize(s, v)
            Arblib.zero!(v) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbMatrix([]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbMatrix([]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbMatrix(Acb[1;;]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbMatrix(Acb[1 2; 3 4]))
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbMatrix(Acb[1 2 3; 4 5 6]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbMatrix(Acb[1//3 π; ℯ NaN]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbMatrix(im * Acb[1//3 π; ℯ NaN]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbMatrix((1 + 2im) * Acb[1//3 π; ℯ NaN]),
        )
    end

    # ArbPoly
    create_serialization_stream() do s
        for v in (
            ArbPoly([]),
            ArbPoly(Arb[1]),
            ArbPoly(Arb[1, 0, 0]),
            ArbPoly(Arb[1, 2, 3, 4]),
            ArbPoly(Arb[1//3, π, ℯ, NaN]),
        )
            Serialization.serialize(s, v)
            Arblib.zero!(v) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbPoly([]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbPoly(Arb[1]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbPoly(Arb[1, 0, 0]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbPoly(Arb[1, 2, 3, 4]))
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            ArbPoly(Arb[1//3, π, ℯ, NaN]),
        )
    end

    # AcbPoly
    create_serialization_stream() do s
        for v in (
            AcbPoly([]),
            AcbPoly(Acb[1]),
            AcbPoly(Acb[1, 0, 0]),
            AcbPoly(Acb[1, 2, 3, 4]),
            AcbPoly(Acb[1//3, π, ℯ, NaN]),
            AcbPoly(im * Acb[1//3, π, ℯ, NaN]),
            AcbPoly((1 + 2im) * Acb[1//3, π, ℯ, NaN]),
        )
            Serialization.serialize(s, v)
            Arblib.zero!(v) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbPoly([]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbPoly(Acb[1]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbPoly(Acb[1, 0, 0]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbPoly(Acb[1, 2, 3, 4]))
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbPoly(Acb[1//3, π, ℯ, NaN]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbPoly(im * Acb[1//3, π, ℯ, NaN]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbPoly((1 + 2im) * Acb[1//3, π, ℯ, NaN]),
        )
    end

    # ArbSeries
    create_serialization_stream() do s
        for v in (
            ArbSeries([]),
            ArbSeries(Arb[1]),
            ArbSeries(Arb[1, 0, 0]),
            ArbSeries(Arb[1, 2, 3, 4]),
            ArbSeries(Arb[1//3, π, ℯ, NaN]),
            ArbSeries(Arb[1, 0, 0]),
        )
            Serialization.serialize(s, v)
            Arblib.zero!(v) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbSeries([]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbSeries(Arb[1]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), ArbSeries(Arb[1, 0, 0]))
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            ArbSeries(Arb[1, 2, 3, 4]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            ArbSeries(Arb[1//3, π, ℯ, NaN]),
        )
        # Check that it allocates space according to the degree
        # This fails with the default implementation of deserialize
        @test Arblib.cstruct(Serialization.deserialize(s)).alloc == 3
    end

    # AcbSeries
    create_serialization_stream() do s
        for v in (
            AcbSeries([]),
            AcbSeries(Acb[1]),
            AcbSeries(Acb[1, 0, 0]),
            AcbSeries(Acb[1, 2, 3, 4]),
            AcbSeries(Acb[1//3, π, ℯ, NaN]),
            AcbSeries(im * Acb[1//3, π, ℯ, NaN]),
            AcbSeries((1 + 2im) * Acb[1//3, π, ℯ, NaN]),
            AcbSeries(Acb[1, 0, 0]),
        )
            Serialization.serialize(s, v)
            Arblib.zero!(v) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbSeries([]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbSeries(Acb[1]))
        @test isequal_and_prec_equal(Serialization.deserialize(s), AcbSeries(Acb[1, 0, 0]))
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbSeries(Acb[1, 2, 3, 4]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbSeries(Acb[1//3, π, ℯ, NaN]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbSeries(im * Acb[1//3, π, ℯ, NaN]),
        )
        @test isequal_and_prec_equal(
            Serialization.deserialize(s),
            AcbSeries((1 + 2im) * Acb[1//3, π, ℯ, NaN]),
        )
        # Check that it allocates space according to the degree
        # This fails with the default implementation of deserialize
        @test Arblib.cstruct(Serialization.deserialize(s)).alloc == 3
    end
end
