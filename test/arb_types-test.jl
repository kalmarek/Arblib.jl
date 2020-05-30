@testset "arb_types" begin
    mag = Arblib.mag_struct(0,0)
    arf = Arblib.arf_struct(0,0,0,0)
    arb = Arblib.arb_struct(0,0,0,0,0,0)
    acb = Arblib.acb_struct(0,0,0,0,0,0, 0,0,0,0,0,0)

    for x in (mag, arf, arb, acb)
        @test begin
            Arblib.init!(x)
            Arblib.clear!(x)
            true
        end
    end

    prec = 256
    for x in (arf, arb, acb)
        @test precision(x) == prec
        @test precision(Ptr{typeof(x)}()) == prec
        @test precision(typeof(x)) == prec
        @test precision(Ptr{typeof(x)}) == prec
    end
end
