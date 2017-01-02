# Chapter 23 - More Cool Stuff

## Writing Your Own Sigils

Built-in sigils

```
string = ~s{now is the time}
regex = ~r{..h..}
```

* When you write a sigle such as `~s{...}` Elixir converts it into a call to the function `sigil_s`
* `sigil_s` takes in two values
    * the string between the delimiters
    * a list containing any lowercase letters that immediately follow the closing delimiter
        * to pick up any options you pass in

## Multi-app Umbrella

* Erlang chose to call self-contained bundles of code **apps**
    * but closer to **shared libraries** 
* As the projects grow, you may find yourself wanting to split your code into multiple libraries or apps
* Elixir calls these multi-app projects umbrella projects

## Create an Umbrella Project

```
> mix new --umbrella eval
```

* Umberella project is pretty lightwieght - just a mix file and an apps directory

## Create the Subprojects

```
> cd eval/apps
> mix new line_sigil
..

> mix new evaluator
..

```

* In the umbrella project folder, `> mix compile` to compile all `apps`

## Making the Subproject Decision

* Subprojects are just regular mix projects
    * you don't have to worry whether to start a new project using an umbrella or not
    * simply start as a simple project
        * then create an umbrellat project
        * move existing simple project into the `apps` directory

## Linking the Subprojects

* Configure the subproject `mix.exs` to add other subprojects as dependencies