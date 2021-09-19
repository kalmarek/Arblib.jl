@testset "Threading" begin
    @testset "Check number of threads" begin
        @test ccall(Arblib.@libflint(flint_get_num_threads), Cint, ()) == 1

        Arblib.flint_set_num_threads(2)
        @test ccall(Arblib.@libflint(flint_get_num_threads), Cint, ()) == 2

        Arblib.flint_set_num_threads(4)
        @test ccall(Arblib.@libflint(flint_get_num_threads), Cint, ()) == 4

        Arblib.flint_set_num_threads(1)
        @test ccall(Arblib.@libflint(flint_get_num_threads), Cint, ()) == 1
    end

    @testset "Disabled threading" begin
        # This manually unsets the threading flag and checks that we
        # get an error when trying to set the number of threads
        Arblib.__isthreaded[] = false

        @test_throws ErrorException Arblib.flint_set_num_threads(2)

        Arblib.__isthreaded[] = true
    end

    @testset "Matrix multiplication" begin
        A = ArbMatrix(reshape(1:10000, 100, 100))

        Arblib.flint_set_num_threads(1)
        B1 = Arblib.mul_threaded!(similar(A), A, A)

        Arblib.flint_set_num_threads(2)
        B2 = Arblib.mul_threaded!(similar(A), A, A)

        @test B1 == B2 == A * A

        Arblib.flint_set_num_threads(2)
    end
end
