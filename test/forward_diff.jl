using ForwardDiff: derivative

@test derivative(Arb(3)) do x
    promote(x, Arb(1))[1]
end == Arb(1)

@test derivative(Arb(3)) do x
    T = promote_type(typeof(x), Arb)
    T(2x + 1)
end == Arb(2)
