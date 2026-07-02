using Documenter
using AutomaticCalculus

const on_ci = get(ENV, "CI", "false") == "true"
const github_repository = get(ENV, "GITHUB_REPOSITORY", "diffinitive/AutomaticCalculus")


config = if on_ci
    println("Using CI config.")
    Documenter.HTML(
        repolink = "https://github.com/$github_repository",
        edit_link = "main",
    )
else
    println("Using local config.")
    Documenter.HTML(prettyurls = false, disable_git = true, edit_link = nothing, repolink = nothing)
end

makedocs(
    sitename = "AutomaticCalculus",
    modules = [AutomaticCalculus],
    format = config,
    pages = ["Home" => "index.md"],
    remotes = nothing,
)

if "--open" in ARGS
    index_path = joinpath(@__DIR__, "build", "index.html")
    run(`open $index_path`)
end
