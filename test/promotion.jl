@testset "Promotion" begin
    for T in [Mag, MagRef]
        @test promote_type(T, Arf) == promote_type(T, ArfRef) == Arf
        @test promote_type(T, Arb) == promote_type(T, ArbRef) == Arb
        @test promote_type(T, Acb) == promote_type(T, AcbRef) == Acb
        @test promote_type(T, ArbSeries) == ArbSeries
        @test promote_type(T, AcbSeries) == AcbSeries
    end
    @test promote_type(MagRef, Mag) == promote_type(Mag, MagRef) == Mag

    for T in [Arf, ArfRef]
        @test promote_type(T, Mag) == promote_type(T, MagRef) == Arf
        @test promote_type(T, Arb) == promote_type(T, ArbRef) == Arb
        @test promote_type(T, Acb) == promote_type(T, AcbRef) == Acb
        @test promote_type(T, ArbSeries) == ArbSeries
        @test promote_type(T, AcbSeries) == AcbSeries
    end
    @test promote_type(ArfRef, Arf) == promote_type(Arf, ArfRef) == Arf

    for T in [Arb, ArbRef]
        @test promote_type(T, Mag) == promote_type(T, MagRef) == Arb
        @test promote_type(T, Arf) == promote_type(T, ArfRef) == Arb
        @test promote_type(T, Acb) == promote_type(T, AcbRef) == Acb
        @test promote_type(T, ArbSeries) == ArbSeries
        @test promote_type(T, AcbSeries) == AcbSeries
    end
    @test promote_type(ArbRef, Arb) == promote_type(Arb, ArbRef) == Arb

    for T in [Acb, AcbRef]
        @test promote_type(T, Mag) == promote_type(T, MagRef) == Acb
        @test promote_type(T, Arf) == promote_type(T, ArfRef) == Acb
        @test promote_type(T, Arb) == promote_type(T, ArbRef) == Acb
        @test promote_type(T, ArbSeries) == AcbSeries
        @test promote_type(T, AcbSeries) == AcbSeries
    end
    @test promote_type(AcbRef, Acb) == promote_type(Acb, AcbRef) == Acb

    @test promote_type(ArbSeries, Mag) == promote_type(ArbSeries, MagRef) == ArbSeries
    @test promote_type(ArbSeries, Arf) == promote_type(ArbSeries, ArfRef) == ArbSeries
    @test promote_type(ArbSeries, Arb) == promote_type(ArbSeries, ArbRef) == ArbSeries
    @test promote_type(ArbSeries, Acb) == promote_type(ArbSeries, AcbRef) == AcbSeries
    @test promote_type(ArbSeries, AcbSeries) == AcbSeries

    @test promote_type(AcbSeries, Mag) == promote_type(AcbSeries, MagRef) == AcbSeries
    @test promote_type(AcbSeries, Arf) == promote_type(AcbSeries, ArfRef) == AcbSeries
    @test promote_type(AcbSeries, Arb) == promote_type(AcbSeries, ArbRef) == AcbSeries
    @test promote_type(AcbSeries, Acb) == promote_type(AcbSeries, AcbRef) == AcbSeries
    @test promote_type(AcbSeries, ArbSeries) == AcbSeries

    for T in [Mag, MagRef, Arf, ArfRef, Arb, ArbRef, Acb, AcbRef, ArbSeries, AcbSeries]
        @test promote_type(T, Float64) == Arblib._nonreftype(T)
    end

    for T in [Arf, ArfRef, Arb, ArbRef, Acb, AcbRef, ArbSeries, AcbSeries]
        @test promote_type(T, BigFloat) == Arblib._nonreftype(T)
    end

    @test promote_type(Arb, ComplexF64) == Acb
    @test promote_type(ArbRef, ComplexF64) == Acb
    @test promote_type(ArbSeries, ComplexF64) == AcbSeries
end
