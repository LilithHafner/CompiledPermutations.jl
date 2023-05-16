```@meta
CurrentModule = CompiledPermutations
```

# CompiledPermutations.jl

[CompiledPermutations](https://github.com/LilithHafner/CompiledPermutations.jl)
is a micro-package which provides a function
[`compile_permutation!`](@ref) that compiles a given permutation so that it can be
efficiently applied multiple times using
[`permute!`](https://docs.julialang.org/en/v1/base/arrays/#Base.permute!-Tuple{Any,%20AbstractVector}).
This is useful if you would like to permute several `AbstractVector`s in the same manner.
For example, when sorting a [`DataFrame`](https://dataframes.juliadata.org/stable/),
[`StructArray`](https://juliaarrays.github.io/StructArrays.jl/stable/), or similar data structure.

```@docs
compile_permutation!
compile_inverse_permutation!
```
