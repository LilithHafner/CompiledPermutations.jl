using CompiledPermutations
using Test
using Random

@testset "Basic" begin
    perm = [2, 3, 1]
    x = [7.2, 2.0, 9.4]
    y = x[perm]
    cp = compile_permutation!(perm)
    @test x != y
    @test permute!(x, cp) === x
    @test x == y
end

struct T
    val::Int
end

function test_perm(p)
    x = T.(1:length(p))
    x0 = copy(x)
    y = x[p]
    cp = compile_permutation!(copy(p))
    cpi = compile_inverse_permutation!(p)
    @test cp isa CompiledPermutations.CompiledPermutation
    @test permute!(x, cp) === x
    @test x == y
    @test permute!(x, cpi) === x
    @test x == x0
end

@testset "Exhaustive" begin
    for len in 0:6
        p = Vector{Int}(undef, len)
        for i in 0:(len+3)^len
            digits!(p, i; base=len+3)
            p .-= 1
            if isperm(p)
                test_perm(p)
            else
                len > 3 && rand() < .8 && continue # Exceptions are slow
                len > 4 && rand() < .8 && continue # Exceptions are slow
                len > 5 && rand() < .8 && continue # Exceptions are slow
                @test_throws ArgumentError compile_permutation!(p)
            end
        end
    end
end

@testset "Random" begin
    for len in 1:3_000
        test_perm(randperm(len))
    end
    for _ in 1:10
        test_perm(randperm(rand(1:500_000)))
    end
end

@testset "Non-int types" begin
    @test_throws MethodError compile_permutation!([2.0, 3.0, 1.0])
    cp0 = compile_permutation!(UInt8[2, 3, 1])
    @test permute!([:a, :b, :c], cp0) == [:b, :c, :a]
end

@testset "API" begin
    # The public API is small:
    @test names(CompiledPermutations) == [:CompiledPermutations, :compile_inverse_permutation!, :compile_permutation!]
end

@testset "Length mismatch" begin
    cp = compile_permutation!(randperm(17))
    x = rand(16)
    @test_throws DimensionMismatch permute!(x, cp)
    x = rand(18)
    @test_throws DimensionMismatch permute!(x, cp)
end
