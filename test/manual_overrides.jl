@testset "Manual overrides" begin
    @testset "arf_get_d / arf_get_si" begin
        a = Arf(2.3)

        @test Arblib.get_d(a) isa Float64
        @test Arblib.get_d(a) == 2.3
        @test Arblib.get_d(a, rnd = RoundNearest) == 2.3
        @test Arblib.get_d(a, RoundNearest) == 2.3

        @test Arblib.get_si(a) isa Int
        @test Arblib.get_si(a) == 2
        @test Arblib.get_si(a, rnd = RoundUp) == 3
        @test Arblib.get_si(a, RoundUp) == 3
        @test Arblib.get_si(a, RoundToZero) == 2
    end
end
