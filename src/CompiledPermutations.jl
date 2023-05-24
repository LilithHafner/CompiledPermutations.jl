module CompiledPermutations

export compile_permutation!, compile_inverse_permutation!

# Implementation details (NOT COVERED BY SYMVER)
# CompiledPermutation uses product-of-transpositions representation
# This method is slightly faster to construct and apply than zero-terminated-cycle notation
# and is slightly more compact.

# There are many possible product-of-transposition representations of a permutation. We use
# one where the transpositions are of the form zip(::Vector, 1:n) so that half of the
# endpoints are stored implicitly. We also maintain the property that a < b for all pairs
# (a,b) in zip(::Vector, 1:n). This means that, when performing permute!, the initial access
# of each index of the permuted vector is part of a linear sweep and therefore likely a
# cache hit. Subsequent accesses are therefore more likely to be cache hits whereas random
# access first incurs more cache misses (I think) and is therefore slower (I measured,
# though it is possible I didn't compare to the best alternate implementation).

# perm[1:init] == 1:init for some init >= 1, so we store init and permute! skips the first
# init indices of the vector. This gives significant savings in the case of a reverse or
# near reverse permutation. Experimentation with storing init in perm[1] showed minor
# performance regressions.

# For example, consider the permutation p which takes [1, 2, 3, 4, 5] to [3, 1, 2, 5, 4].
# In classical notation, we express this as [3, 1, 2, 5, 4] and apply this representation
# with permute!
#     permute!([:a, :b, :c, :d, :e], p) == [:c, :a, :b, :e, :d]
# In product-of-transpositions notation, we express this as the product
# (1,1)(1,2)(1,3)(4,4)(4,5), represented with the vector [1, 1, 1, 4, 4], and stored as
# cp = CompiledPermutations.CompiledPermutation{Vector{Int64}}(2, [1, 1, 1, 4, 4])
# where 2 is the index of the first non-trivial transposition. This can also be
# applied with permute!
#     permute!([:a, :b, :c, :d, :e], cp) == [:c, :a, :b, :e, :d]

struct CompiledPermutation{V <: AbstractVector{<:Integer}}
    init::Int
    perm::V

    global _compile_permutation!

    function _compile_permutation!(p, ip)
        @inbounds for i in length(p):-1:2
            j = ip[i]
            p[j] = p[i]
            p[i] = j
            ip[p[j]] = j
        end
        init = 2
        @inbounds while init <= length(p) && p[init] == init; init += 1; end
        new{typeof(p)}(init, p)
    end
end



"""
    compile_permutation!(p::AbstractVector{<:Integer}) -> cp

Convert a permutation `p` into a compiled permutation `cp` which can be efficiently
applied with `permute!(v, cp)`.

`permute!(v, compiled_permutation!(p)))` produces the same result as `permute!(v, p)` and is
often less efficient unless you reuse the compiled result. This function is useful when the
same permutation is applied to many vectors.

!!! note
    `compile_permutation!` may mangle `p` and/or return an object which shares memory
    with `p`. Use `compile_permutation!(copy(p))` if you would like to avoid this.


## Example

```jldoctest
julia> cp = compile_permutation!([2, 3, 1]);

julia> v = [:a, :b, :c];

julia> permute!(v, cp)
3-element Vector{Symbol}:
 :b
 :c
 :a
```

Here is an example where this function provides performance benefits:

```jldoctest; filter = r"[0-9\\.]+ μs", setup = :(using BenchmarkTools, Random)
julia> perm = randperm(1000); data = [rand(1000) for _ in 1:30];

julia> @btime for x in \$data; permute!(x, \$perm); end
  25.917 μs (30 allocations: 238.12 KiB)

julia> @btime (cp = compile_permutation!(copy(\$perm)); for x in \$data; permute!(x, cp); end)
  16.708 μs (2 allocations: 15.88 KiB)
```
"""
compile_permutation!(p::AbstractVector{<:Integer}) = _compile_permutation!(p, invperm(p))

"""
    compile_inverse_permutation!(p::AbstractVector{<:Integer}) -> cp

Equivalent to `compile_permutation!(invperm(p))`, though possibly more efficient.
"""
compile_inverse_permutation!(p::AbstractVector{<:Integer}) = _compile_permutation!(invperm(p), p)

# No docstring needed. To quote the first docstring from Base,
# """
#     permute!(v, p)
#
# Permute vector `v` in-place, according to permutation `p`. No checking is done
# to verify that `p` is a permutation.
#
# [...]
# """
function Base.permute!(x, cp::CompiledPermutation)
    length(x) == length(cp.perm) || throw(DimensionMismatch())
    @inbounds for i in cp.init:length(cp.perm)
        j = cp.perm[i]
        x[i], x[j] = x[j], x[i]
    end
    x
end

end
