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

### Create The Project Tree
* `mix new issues`

* `config/` - application specific configuration
* `lib/` - the project source
* `mix.exs` - the project configuration options
* `test/` - test folder

## Transformation Parse the Command Line

* To avoid coupling the handling of command line options into the main body of our program
  * Create *Project.CLI* module by convention - ie. `Isues.CLI`

## Transformation: Fetch from GitHub
* To run `mix run -e 'Issues.CLI.run(["-h"])'`

## Task: Use Libraries

* http://elixir-lang.org/docs/
* http://erlang.org/doc/ 
* if the built-in libraries don’t have what you need, you’ll have to add an external dependency.

## Finding an External Library

* `hex` Package Managers
* http://hex.pm

## Adding a Library to Your Project

* Add library to `mix.exs`, `deps` section
```
defp deps do [  { :httpoison, "~> 0.8" } ]end
```
* Run `mix deps.get` to install/download deps

## Back to the Transformation

* `HTTPoison.start` to run as a separate application
* To start in *Elixir*, add to `application` section of `mix.exs`
```
def application do  [ applications: [ :logger, :httpoison ] ]end
```
* `iex -S mix`; `-S` to run `mix` before running in interactive mode
    * Running the code in IEX `%> Issues.GithubIssues.fetch("elixir-lang", "elixir")`

## Transformation: Convert Response

* Add `poison` library to `mix.exs`

## Application Configuration

* Add `config :issues, github_url: "https://api.github.com"` to `config/config.exs`
* Each `config` line adds one or more key/value pairs to the given applicant `environment`
* For Multiple lines for the same applicatin, they accumulate
    * Duplicate keys in later lines overriding values from earlier ones* Application environment is commonly used in Erlang code
* To configure depending on the application environment, use `import_config` function
    ```
    use Mix.config
    import_config "#{Mix.env}.exs"
    ``` 
* To override the default config file, use `--config` option to elixir

## Transformation: Sort Data

## Task: Make a Command-Line Executable

* Mix can package the code with its dependencies into a single ile that can be run on any Unix based platform.
* It uses `escript` utility which can run precompiled programs stored as a Zip archive

### `escript`

* When `escript` runs a program, it looks in `mix.exs` for the option `escript`
* `escript` option returns a list of configuration settings
    * the most important is `main_module`
    *  