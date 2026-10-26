using Documenter, Redstone

# The home page is the README, copied at build time so the two never diverge.
cp(joinpath(@__DIR__, "..", "README.md"), joinpath(@__DIR__, "src", "index.md");
   force = true)

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
    ],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
)

deploydocs(; repo = "github.com/e271828e/Redstone.jl.git")
