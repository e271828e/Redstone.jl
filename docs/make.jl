using Documenter, Redstone

# The home page is the README, copied at build time so the two never diverge.
cp(joinpath(@__DIR__, "..", "README.md"), joinpath(@__DIR__, "src", "index.md");
   force = true)

# The glossary page is generated from the spec's Appendix D.
include("glossary.jl")
write_glossary(joinpath(@__DIR__, "..", "design", "spec.md"),
               joinpath(@__DIR__, "src", "glossary.md"))

DocMeta.setdocmeta!(Redstone, :DocTestSetup, :(using Redstone); recursive = true)

makedocs(;
    sitename = "Redstone.jl",
    authors = "Miguel Alonso <miguel883@gmail.com>",
    modules = [Redstone],
    doctest = true,
    checkdocs = :exports,
    pagesonly = true,
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
        "Glossary" => "glossary.md",
    ],
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", nothing) == "true",
        size_threshold_ignore = ["api.md"],  # one page for the whole surface
    ),
)

deploydocs(; repo = "github.com/e271828e/Redstone.jl.git")
