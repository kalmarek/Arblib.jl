@testset "Promotion" begin
    for T in [Mag, MagRef]
        @test promote_type(T, Arf) == promote_type(T, ArfRef) == Arf
        @test promote_type(T, Arb) == promote_type(T, ArbRef) == Arb
        @test promote_type(T, Acb) == promote_type(T, AcbRef) == Acb
    end
    @test promote_type(MagRef, Mag) == promote_type(Mag, MagRef) == Mag

    for T in [Arf, ArfRef]
        @test promote_type(T, Mag) == promote_type(T, MagRef) == Arf
        @test promote_type(T, Arb) == promote_type(T, ArbRef) == Arb
        @test promote_type(T, Acb) == promote_type(T, AcbRef) == Acb
    end
    @test promote_type(ArfRef, Arf) == promote_type(Arf, ArfRef) == Arf

    for T in [Arb, ArbRef]
        @test promote_type(T, Mag) == promote_type(T, MagRef) == Arb
        @test promote_type(T, Arf) == promote_type(T, ArfRef) == Arb
        @test promote_type(T, Acb) == promote_type(T, AcbRef) == Acb
    end
    @test promote_type(ArbRef, Arb) == promote_type(Arb, ArbRef) == Arb

    for T in [Acb, AcbRef]
        @test promote_type(T, Mag) == promote_type(T, MagRef) == Acb
        @test promote_type(T, Arf) == promote_type(T, ArfRef) == Acb
        @test promote_type(T, Arb) == promote_type(T, ArbRef) == Acb
    end
    @test promote_type(AcbRef, Acb) == promote_type(Acb, AcbRef) == Acb

    for T in [Mag, MagRef, Arf, ArfRef, Arb, ArbRef, Acb, AcbRef]
        @test promote_type(T, Float64) == Arblib._nonreftype(T)
    end
end
