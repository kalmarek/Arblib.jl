@testset "show" begin
    Mag = Arblib.Mag
    @testset "string" begin
        @test Arblib._string(Mag()) isa String
        @test Arblib._string(Arf()) isa String
        @test Arblib._string(Arb()) isa String
        @test Arblib._string(Acb()) isa String

        @test Arblib.string_decimal(Arf()) isa String
        @test Arblib.string_decimal(Arb()) isa String
        @test Arblib.string_decimal(Acb()) isa String

        @test Arblib.string_nice(Arb()) isa String
        @test Arblib.string_nice(Acb()) isa String
    end

    @testset "dump" begin
        x = Mag(1.1)
        for x in (Mag(1.1), Arf(1.1), Arb(1.1))
            y = zero(x)
            str = Arblib.dump_string(x)
            Arblib.load_string!(y, str)
            @test isequal(x, y)
        end
    end
end
