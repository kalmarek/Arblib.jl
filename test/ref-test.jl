@testset "MagRef" begin
    @test isequal(MagRef(), Mag())

    x = Arb()
    Arblib.set!(Arblib.radref(x), UInt(2))
    @test Arblib.radref(x) == Mag(UInt(2))

    y = Mag(Arblib.radref(x))
    Arblib.set!(y, UInt(3))
    @test Arblib.radref(x) == Mag(UInt(2))

    z = Arblib.radref(x)[]
    Arblib.set!(z, UInt(4))
    @test Arblib.radref(x) == Mag(UInt(2))
end

@testset "ArfRef" begin
    @test ArfRef() isa Arf
    @test isequal(ArfRef(), Arf())
    @test precision(ArfRef()) == Arblib.DEFAULT_PRECISION[]
    @test precision(ArfRef(prec = 80)) == 80

    x = Arb()
    ptr = Arblib.midref(x).arf_ptr
    parent = Arblib.parentstruct(x)
    @test ArfRef(ptr, parent) == Arf()
    @test precision(ArfRef(ptr, parent)) == Arblib.DEFAULT_PRECISION[]
    @test precision(ArfRef(ptr, parent, prec = 80)) == 80

    Arblib.set!(Arblib.midref(x), 2)
    @test Arblib.midref(x) == Arf(2)
    y = Arf(Arblib.midref(x))
    Arblib.set!(y, 3)
    @test Arblib.midref(x) == Arf(2)
    z = Arblib.midref(x)[]
    Arblib.set!(z, 4)
    @test Arblib.midref(x) == Arf(2)
end

@testset "ArbRef" begin
    @test ArbRef() isa Arb
    @test isequal(ArbRef(), Arb())
    @test precision(ArbRef()) == Arblib.DEFAULT_PRECISION[]
    @test precision(ArbRef(prec = 80)) == 80

    x = Acb()
    ptr = Arblib.realref(x).arb_ptr
    parent = Arblib.parentstruct(x)
    @test ArbRef(ptr, parent) == Arb()
    @test precision(ArbRef(ptr, parent)) == Arblib.DEFAULT_PRECISION[]
    @test precision(ArbRef(ptr, parent, prec = 80)) == 80

    Arblib.set!(Arblib.realref(x), 2)
    @test Arblib.realref(x) == Arb(2)
    Arblib.set!(Arblib.imagref(x), 3)
    @test Arblib.imagref(x) == Arb(3)
    y = Arb(Arblib.realref(x))
    Arblib.set!(y, 3)
    @test Arblib.realref(x) == Arf(2)
    z = Arblib.realref(x)[]
    Arblib.set!(z, 4)
    @test Arblib.realref(x) == Arf(2)
end

@testset "AcbRef" begin
    @test AcbRef() isa Acb
    @test isequal(AcbRef(), Acb())
    @test precision(AcbRef()) == Arblib.DEFAULT_PRECISION[]
    @test precision(AcbRef(prec = 80)) == 80

    v = AcbRefVector([0])
    x = v[1]
    ptr = x.acb_ptr
    parent = v.acb_vec
    @test AcbRef(ptr, parent) == Acb()
    @test precision(AcbRef(ptr, parent)) == Arblib.DEFAULT_PRECISION[]
    @test precision(AcbRef(ptr, parent, prec = 80)) == 80

    Arblib.set!(x, 2)
    @test v[1] == Acb(2)
    y = Acb(x)
    Arblib.set!(y, 3)
    @test v[1] == Acb(2)
    z = x[]
    Arblib.set!(z, 4)
    @test v[1] == Acb(2)
end

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
