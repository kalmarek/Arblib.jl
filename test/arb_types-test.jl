@testset "arb_types" begin
    mag = Arblib.mag_struct(0,0)
    arf = Arblib.arf_struct(0,0,0,0)
    arb = Arblib.arb_struct(0,0,0,0,0,0)
    acb = Arblib.acb_struct(0,0,0,0,0,0, 0,0,0,0,0,0)
    @test typeof(mag) == Arblib.mag_struct
    @test typeof(arf) == Arblib.arf_struct
    @test typeof(arb) == Arblib.arb_struct
    @test typeof(acb) == Arblib.acb_struct

    for x in (mag, arf, arb, acb)
        @test begin
            Arblib.init!(x)
            Arblib.clear!(x)
            true
        end
    end
end
