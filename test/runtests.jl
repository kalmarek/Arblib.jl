using Arblib, Test

@testset "Arblib" begin
    @test isa(Arb(π, 256), Arb)
end
