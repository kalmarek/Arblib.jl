using Documenter, Arblib

makedocs(
    sitename = "Arblib",
    pages = [
        "index.md",
        "Low level wrapper" => [
            "Types" => "wrapper-types.md",
            "Methods" => "wrapper-methods.md",
            "Floating point wrapper" => "wrapper-fpwrap.md",
        ],
        "High level interface" => [
            "Types" => "interface-types.md",
            "Interval methods" => "interface-interval.md",
            "Integration" => "interface-integration.md",
        ],
        "Rigorous numerics" => "rigorous.md",
    ],
)
