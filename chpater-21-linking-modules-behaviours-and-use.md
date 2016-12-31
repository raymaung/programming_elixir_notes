# Chapter 21 - Linking Modules: Behaviours and Use

```
defmodule Sequence.Server do
    use GenServer    ...
```

We'll explore what lines such as `use GenServer` actuall do and how we can write modules that extend the capabilities of other modules that use them.

## Behaviours

An Elixir **behaviour** is nothing more than a list of functions.

* a module that declares that it implements a particular behaviour must implement **all** of the associated functions.
    * If it doesn't, Elixir will generate compilation **warning**.
    * Being like an abstract base class in OO, or *interface* in Java.

* For example, an OTP `GenServer` should implement a standard set of callbacks
    * `handle_call`
    * `handle_cast`
    * so on
* By declaring, our module implements a behaviour, we let compiler validate that we have actually supplied the necessary interface.

## Defining Behaviours

* Define a behaviour with `@callback` definitions

Example Behaviour in `Mix.Scm`

```
defmodule Mix.SCM do    @moduledoc """    This module provides helper functions and defines the behaviour
    required by any SCM used by Mix.    """    @type opts :: Keyword.t    @doc """    Returns a boolean if the dependency can be fetched or it is meant
    to bepreviously available in the filesystem.
    Local dependencies (i.e. non fetchable ones) are automatically
    recompiled every time the parent project is compiled.    """    @callback fetchable? :: boolean    @doc """    Returns a string representing the SCM. This is used when printing
    the dependency and not for inspection, so the amount of
    information should be concise and easy to spot.    """    @callback format(opts) :: String.t    # and so on for 8 more callbacks
```

* the module defines the interface using `@callback`
* Syntax looks different because we are using **minilanguage**
    * Erlang type specifications
    * `fetchable?` function takes no parameters and returns a boolean
    * `format` takes a parameter of type `opts` and return a string


## Declaring Behaviours

* We can declare that another module implements the behaviour using `@behaviour` attribute

```
defmodule Mix.SCM.Git do
  @behaviour Mix.SCM

  def fetchable? do
    true  end  def format(opts) do
    opts[:git]
  end  #...end
```

## `use` and `__using__`

* `use` is a trivial function - pass in a module along with an optional argument
    * it invokes the function or macro `__using__`
    
When we write an OTP server, we write `use GenServer` and we get both a behaviour that documents the `gen_server` callback and default implementations of those callbacks.

Typically the `__using__` calback will be implemented as a macro as it will be used to invoke code in the origianl module

## Putting It Together - Tracing Method Calls

* `tracer4.ex`

    ```
    defmodule Tracer do
      def dump_args(args) do
        args
          |> Enum.map(&inspect/1)
          |> Enum.join(", ")
      end
    
      def dump_defn(name, args) do
        "#{name}(#{dump_args(args)}"
      end
    
      defmacro def(definition = {name, _, args}, do: content) do
        quote do
          Kernel.def(unquote(definition)) do
            IO.puts "==> call: #{Tracer.dump_defn(unquote(name), unquote(args))}"
            result = unquote content
            IO.puts "<== result: #{result}"
            result
          end
        end
      end
    
      defmacro __using__(_opts) do
        quote do
          import Kernel, except: [def: 2]
          import unquote(__MODULE__), only: [def: 2]
        end
      end
    end
    
    defmodule Test do
      use Tracer
    
      def puts_sum_three(a, b, c), do: IO.inspect(a + b + c)
      def add_list(list), do: Enum.reduce(list, 0, &(&1 + &2))
    end
    
    Test.puts_sum_three(1, 2, 3)
    Test.add_list([5,6,7,8])
    ```

## Use `use`

* `use` let you easily inject functionality into modules your write
* Not just for library creators; can be used to cut down on duplication
* For adding behaviours to modules that **you** are writing; not written by other
    * To extend the functionalities of other, uses `protocols`
