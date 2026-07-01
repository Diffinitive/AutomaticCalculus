using Documenter
using AutomaticCalculus

makedocs(
    sitename = "AutomaticCalculus",
    modules = [AutomaticCalculus],
    format = Documenter.HTML(prettyurls = false, disable_git = true, edit_link = nothing, repolink = nothing),
    pages = ["Home" => "index.md"],
    remotes = nothing,
)

if "--open" in ARGS
    index_path = joinpath(@__DIR__, "build", "index.html")
    run(`open $index_path`)
end
