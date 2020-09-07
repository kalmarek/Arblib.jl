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

@testset "Refs from AcbRef" begin
    v = AcbRefVector([1, 2, 3])
    @test v[1] isa AcbRef
    @test Arblib.realref(v[1]) isa ArbRef
    @test Arblib.midref(Arblib.realref(v[1])) isa ArfRef
    @test Arblib.imagref(v[1]) isa ArbRef
    @test ComplexF64(v[1]) == 1
end
