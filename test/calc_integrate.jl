@testset "integration" begin
    prec = 128
    @test Arblib.integrate((res,x; prec)-> Arblib.mul!(res, x,x, prec=prec), 0, 1, prec=prec) isa Acb
    @test real(Arblib.integrate((res,x; prec)-> Arblib.mul!(res, x,x, prec=prec), 0, 1, prec=prec)) - 1/3 < eps(Float64)
    @test Arblib.contains_zero(real(Arblib.integrate(Arblib.sin!, 0, π, prec=prec)) - 2)
    @test Arblib.contains_zero(real(Arblib.integrate(Arblib.cos!, -Acb(π), Acb(π), prec=prec)))
end
