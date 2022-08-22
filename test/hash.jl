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
end
