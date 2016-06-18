# Chapter 13 - Organizing a Project

* `mix` - Elixir build tool
* Directory structure
* Manage dependencies
* `ExUnit` to write tests

## The Project: Fetch Issues from GitHub

* `https://api.github.com/repos/user/project/issues` - GitHub API to fetch issues
* Get the issues, reformat, sort, filter out the oldest *n*, present the result as a table


## Task: Use Mix to Create Our New Project

* `mix help` to list help
* `mix new`: to create a new project
* `mix run`: to run the given file or expression
* `mix test`: to run tests
* `iex -S mix`: Start IEX and run the default task

### Create Project
* `mix new issues` 