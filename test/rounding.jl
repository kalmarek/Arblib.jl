@testset "rounding" begin
    @test convert(Arblib.arb_rnd, RoundToZero) == Arblib.ArbRoundToZero
    @test convert(Arblib.arb_rnd, RoundFromZero) == Arblib.ArbRoundFromZero
    @test convert(Arblib.arb_rnd, RoundDown) == Arblib.ArbRoundDown
    @test convert(Arblib.arb_rnd, RoundUp) == Arblib.ArbRoundUp
    @test convert(Arblib.arb_rnd, RoundNearest) == Arblib.ArbRoundNearest

    @test convert(RoundingMode, Arblib.ArbRoundToZero) == RoundToZero
    @test convert(RoundingMode, Arblib.ArbRoundFromZero) == RoundFromZero
    @test convert(RoundingMode, Arblib.ArbRoundDown) == RoundDown
    @test convert(RoundingMode, Arblib.ArbRoundUp) == RoundUp
    @test convert(RoundingMode, Arblib.ArbRoundNearest) == RoundNearest
end
