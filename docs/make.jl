using Documenter, Redstone

# The home page is the README, copied at build time so the two never diverge.
cp(joinpath(@__DIR__, "..", "README.md"), joinpath(@__DIR__, "src", "index.md");
   force = true)

# The schema of record is served beside the pages, at the address its `$id` names.
cp(joinpath(@__DIR__, "..", "src", "descriptor.json"), joinpath(@__DIR__, "src", "descriptor.json");
   force = true)

# The glossary page is generated from the spec's Appendix D.
include("glossary.jl")
write_glossary(joinpath(@__DIR__, "..", "design", "spec.md"),
               joinpath(@__DIR__, "src", "glossary.md"))

DocMeta.setdocmeta!(Redstone, :DocTestSetup, :(using Redstone); recursive = true)

# The tutorial's plot theme, the one setup its pages do not show. A figure renders as a PNG
# at twice its size in pixels, so its weight does not grow with the length of the log.
using CairoMakie
CairoMakie.enable_only_mime!("png")
set_theme!(size = (720, 420), fontsize = 13, linewidth = 1.5,
           Axis = (xgridcolor = (:black, 0.08), ygridcolor = (:black, 0.08)))

makedocs(;
    sitename = "Redstone.jl",
    authors = "Miguel Alonso <miguel883@gmail.com>",
    modules = [Redstone],
    doctest = true,
    checkdocs = :exports,
    pagesonly = true,
    pages = [
        "Home" => "index.md",
        "Tutorial" => [
            "tutorial/index.md",
            "1\\. The aircraft" => "tutorial/aircraft.md",
            "2\\. Trim" => "tutorial/trim.md",
            "3\\. Linearize" => "tutorial/linearize.md",
        ],
        "API" => "api.md",
        "Glossary" => "glossary.md",
    ],
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", nothing) == "true",
        # the Tutorial group stays collapsed unless one of its pages is open
        collapselevel = 1,
        # one page for the whole surface, and one for the whole glossary
        size_threshold_ignore = ["api.md", "glossary.md"],
    ),
)

deploydocs(; repo = "github.com/e271828e/Redstone.jl.git")
