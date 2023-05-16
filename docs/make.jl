using CompiledPermutations
using Documenter

DocMeta.setdocmeta!(CompiledPermutations, :DocTestSetup, :(using CompiledPermutations); recursive=true)

makedocs(;
    modules=[CompiledPermutations],
    authors="Lilith Hafner <Lilith.Hafner@gmail.com> and contributors",
    repo="https://github.com/LilithHafner/CompiledPermutations.jl/blob/{commit}{path}#{line}",
    sitename="CompiledPermutations.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://LilithHafner.github.io/CompiledPermutations.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/LilithHafner/CompiledPermutations.jl",
    devbranch="main",
)
