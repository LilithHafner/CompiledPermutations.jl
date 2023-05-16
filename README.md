# CompiledPermutations

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://LilithHafner.github.io/CompiledPermutations.jl/stable/)
[![Build Status](https://github.com/LilithHafner/CompiledPermutations.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/LilithHafner/CompiledPermutations.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/LilithHafner/CompiledPermutations.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/LilithHafner/CompiledPermutations.jl)

CompiledPermutations.jl
is a micro-package which provides a function
`compile_permutation!` that compiles a given permutation so that it can be
efficiently applied multiple times using
`permute!`.
This is useful if you would like to permute several `AbstractVector`s in the same manner.
For example, when sorting a [`DataFrame`](https://dataframes.juliadata.org/stable/),
[`StructArray`](https://juliaarrays.github.io/StructArrays.jl/stable/), or similar data structure.
