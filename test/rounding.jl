@testset "rounding" begin
    @testset "round" begin
        xs = range(-3, 3, length = 25)
        # RoundNearest
        @test round.(xs) ==
              round.(Arf.(xs)) ==
              round.(Arf.(xs), RoundNearest) ==
              round.(Arb.(xs)) ==
              round.(Arb.(xs), RoundNearest)
        # RoundNearestTiesAway
        @test_throws ArgumentError round(Arf(0), RoundNearestTiesAway)
        @test_throws ArgumentError round(Arb(0), RoundNearestTiesAway)
        # RoundNearestTiesUp
        @test_throws ArgumentError round(Arf(0), RoundNearestTiesUp)
        @test_throws ArgumentError round(Arb(0), RoundNearestTiesUp)
        # RoundToZero
        @test round.(xs, RoundToZero) ==
              round.(Arf.(xs), RoundToZero) ==
              round.(Arb.(xs), RoundToZero)
        # RoundFromZero
        @test round.(xs, RoundFromZero) == round.(Arf.(xs), RoundFromZero)
        @test_throws ArgumentError round(Arb(0), RoundFromZero)
        # RoundUp
        @test round.(xs, RoundUp) == round.(Arf.(xs), RoundUp) == round.(Arb.(xs), RoundUp)
        # RoundDown
        @test round.(xs, RoundDown) ==
              round.(Arf.(xs), RoundDown) ==
              round.(Arb.(xs), RoundDown)

        # Make sure it works correctly for intervals
        @test Arblib.contains(round(Arb((0.4, 0.6))), 0)
        @test Arblib.contains(round(Arb((0.4, 0.6))), 1)

        @test Arblib.contains(round(Arb((0.9, 1.1)), RoundToZero), 0)
        @test Arblib.contains(round(Arb((0.9, 1.1)), RoundToZero), 1)

        @test Arblib.contains(round(Arb((0.9, 1.1)), RoundDown), 0)
        @test Arblib.contains(round(Arb((0.9, 1.1)), RoundDown), 1)

        @test Arblib.contains(round(Arb((0.9, 1.1)), RoundUp), 1)
        @test Arblib.contains(round(Arb((0.9, 1.1)), RoundUp), 2)

        # Complex
        ys = transpose(xs)
        for rr in (RoundNearest, RoundToZero, RoundFromZero, RoundUp, RoundDown)
            for ri in (RoundNearest, RoundToZero, RoundFromZero, RoundUp, RoundDown)
                @test round.(complex.(xs, ys), rr, ri) == round.(Acf.(xs, ys), rr, ri)
            end
        end
        for rr in (RoundNearest, RoundToZero, RoundUp, RoundDown)
            for ri in (RoundNearest, RoundToZero, RoundUp, RoundDown)
                @test round.(complex.(xs, ys), rr, ri) == round.(Acb.(xs, ys), rr, ri)
            end
        end
        @test_throws ArgumentError round(Acf(1, 1), RoundNearestTiesAway, RoundDown)
        @test_throws ArgumentError round(Acf(1, 1), RoundDown, RoundNearestTiesAway)
        @test_throws ArgumentError round(Acb(1, 1), RoundNearestTiesAway, RoundDown)
        @test_throws ArgumentError round(Acb(1, 1), RoundDown, RoundNearestTiesAway)
    end

    @testset "div" begin
        xs = range(-10, 10, length = 41)
        ys = transpose(xs)

        # Checks if x and y are equal, treating zeros as equal
        # independent of sign and NaN as equal independent of
        # representation.
        _isequal_or_both_zero_or_nan(x, y) =
            isequal(x, y) || (iszero(x) && iszero(y)) || (isnan(x) && isnan(y))

        # RoundNearest
        @test all(_isequal_or_both_zero_or_nan.(div.(xs, ys), div.(Arb.(xs), Arb.(ys))))
        # RoundNearestTiesAway
        @test_throws ArgumentError div(Arb(1), Arb(1), RoundNearestTiesAway)
        # RoundNearestTiesUp
        @test_throws ArgumentError div(Arf(1), Arb(1), RoundNearestTiesUp)
        @test_throws ArgumentError div(Arb(1), Arb(1), RoundNearestTiesUp)
        # RoundToZero
        @test all(
            _isequal_or_both_zero_or_nan.(
                div.(xs, ys, RoundToZero),
                div.(Arb.(xs), Arb.(ys), RoundToZero),
            ),
        )
        # RoundFromZero
        @test_throws ArgumentError div(Arb(1), Arb(1), RoundFromZero)
        # RoundUp
        @test all(
            _isequal_or_both_zero_or_nan.(
                div.(xs, ys, RoundUp),
                div.(Arb.(xs), Arb.(ys), RoundUp),
            ),
        )
        # RoundDown
        @test all(
            _isequal_or_both_zero_or_nan.(
                div.(xs, ys, RoundDown),
                div.(Arb.(xs), Arb.(ys), RoundDown),
            ),
        )

        # Test that creating ranges work. This uses div internally and
        # was the initial motivation for implementing div
        @test (Arb(1):Arb(10)) == (Arb.(1:10))
        @test_throws InexactError Arb(π):(Arb(π)+1)
    end
end
