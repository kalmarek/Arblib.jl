@testset "ArfRef from ArbRef" begin
    v = ArbRefVector([1.0, 2.0, 3.0])
    @test v[3] isa ArbRef
    x = Arblib.midref(v[3])
    @test x isa ArfRef
    @test startswith(sprint(show, x), "3")
    y = typeof(x)()
    @test y isa Arf
    y[] = x
    @test startswith(sprint(show, y), "3")
    @test y == x
end
