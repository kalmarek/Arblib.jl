@testset "arb_types" begin
    mag = Arblib.mag_struct()
    arf = Arblib.arf_struct()
    arb = Arblib.arb_struct()
    acb = Arblib.acb_struct()

    prec = 256
    for x in (arf, arb, acb)
        @test precision(x) == prec
        @test precision(Ptr{typeof(x)}()) == prec
        @test precision(typeof(x)) == prec
        @test precision(Ptr{typeof(x)}) == prec
    end
end
