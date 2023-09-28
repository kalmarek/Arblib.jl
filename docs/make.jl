using Documenter, Arblib

makedocs(
    sitename = "Arblib",
    modules = [Arblib],
    pages = [
        "index.md",
        "Low level wrapper" => [
            "Types" => "wrapper-types.md",
            "Methods" => "wrapper-methods.md",
            "Floating point wrapper" => "wrapper-fpwrap.md",
        ],
        "High level interface" => [
            "Types" => "interface-types.md",
            "Ball methods" => "interface-ball.md",
            "Integration" => "interface-integration.md",
            "Series" => "interface-series.md",
            "Mutable arithmetic" => "interface-mutable.md",
        ],
        "Rigorous numerics" => "rigorous.md",
    ],
    warnonly = [:missing_docs, :cross_references],
)
