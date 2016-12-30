# Chapter 20 - Macros and Code Evaluation

## Warning

* macros can easily make the code harder to understand
* Essentially rewriting parts of the language

> Never use a macro when you can use a function

## Implementing an `if` statement

We want to call it using something like


```
myif << condition >> do
  << evaluate if true >>
else
  << evaluate if false >>
end
```

Since Blocks in Elixir are converted into keyword parameters, so the above is equivalent to

```
myif << condition >>,
    do: << evaluate if true >>
    else: << evaluate if false >>
    
Example:

My.myif 1 == 2, do: (IO.puts "1 == 2"), else: (IO.puts "1 != 2")

```

Could be implemented as normal function

```
defmodule My do
  def myif(condition, clauses) do
    do_clause = Keyword.get(clauses, :do, nil)
    else_clause = Keyword.get(clauses, :else, nil)

    case condition do
      val when val in [false, nil]
        -> else_clause
      _otherwise
        -> do_clause
    end
  end
end

iex> My.myif 1==2, do: (IO.puts "1 == 2"), else: (IO.puts "1 != 2") 1 == 21 != 2
```

* `do:` and `else:` are **evaluated** all its parameters before passing them in.
* Need a way to dealy the clause executions

## Macros Inject Code

* Use `defmacro`, `quote` and `unquote` to tell the compiler that we'd like to manipulate a part of that tuple

* `defmacro` defines a macro

```
defmodule My do
  defmacro macro(param) do
    IO.inspect param
  end
end

defmodule Test do
  require My

  # These values represent themselves
  My.macro :atom        #=> :atom
  My.macro 1            #=> 1
  My.macro 1.0          #=> 1.0
  My.macro [1, 2, 3]    #=> [1, 2, 3]
  My.macro "binaries"   #=> "binaries"
  My.macro { 1, 2 }     #=> {1, 2}
  My.macro do: 1        #=> [do: 1]

  # And these are represented by 3-element tuples
  My.macro {1, 2, 3, 4, 5}  #=> {:{}, [line: 20], [1, 2, 3, 4, 5]}

  My.macro do: (a = 1; a + a)
  #=>
  # [do: {:__block__, [],
  #   [{:=, [line: 22], [{:a, [line: 22], nil}, 1]},
  #    {:+, [line: 22], [{:a, [line: 22], nil}, {:a, [line: 22], nil}]}]}]

  My.macro do
    1 + 2
  else
    3 + 4
  end
  #=>
  # [do: {:+, [line: 29], [1, 2]},
  #  else: {:+, [line: 31], [3, 4]}]
end
```

* atoms, numbers, lists (including keyword lists), binaries and tuples with two elements are represented internally as themselves
    * All other Elixir code is represented by a three-element tuple

## Load Order

* Macros are expanded before a program executes
* the macro defined in one module must be available as Elixir is compiling another module that uses those macros
    * `require` to compile the named module is compiled before the current one

## The `quote` function

* `quote` takes a block and returns the internal representation of that bloack

```
> quote do: :atom
:atom

> quote do: 1
1

> quote do: {1, 2, 3, 4, 5}
{:"{}", [], [1, 2, 3, 4, 5]}

> quote do: (a = 1; a + a)
{:__block__, [],
 [{:=, [], [{:a, [], Elixir}, 1]},
  {:+, [context: Elixir, import: Kernel],
   [{:a, [], Elixir}, {:a, [], Elixir}]}]}

```

## Using the Representation As Code

* When extracting the internal representation of some code (either via a **macro** parameter or using `quote`), we stop Elixir from adding it automatically to the tuples of code it is building during compilation.
    * Effectively creating a free-standing island of code

### Two ways to inject the code back into our program's internal representations

* Using macro
    * Like function, the value a macro returns is the last expression
    * Expected to be a fragment of code in Elixir's internal representation
        * Elixir does not return this representation to the code that invoked the macro, instead
            * it injects the code back into the internal representation of our program.
        * the caller gets the **result** of executing that code, but that execution takes place only if needed.


* `eg.exs`

    ```
    defmodule My do
      defmacro macro(code) do
        IO.inspect code
        
        #
        # No changes to the code - return as-is
        #
        code
      end
    end
    
    defmodule Test do
      require My
    
      My.macro(IO.puts("Hello"))
    end
    ```
    
    Returns, note `Hello`
    
    ```
    > {{:., [line: 11], [{:__aliases__, [counter: 0, line: 11], [:IO]}, :puts]},
     [line: 11], ["Hello"]}
    Hello
    ```

* `eg1.exs`

    ```
    defmodule My do
      defmacro macro(code) do
        IO.inspect code
        
        #
        # Replacing the original code with new internal
        # representation using `quote`
        #
        quote do: IO.puts "Different Code"
      end
    end
    
    defmodule Test do
      require My
    
      My.macro(IO.puts("Hello"))
    end
    
    defmodule My do
      defmacro macro(code) do
        IO.inspect code
        quote do: IO.puts "Different Code"
      end
    end
    
    defmodule Test do
      require My
    
      My.macro(IO.puts("Hello"))
    end
    
    ```
    returns, note `Different Code`
    
    ```
    > {{:., [line: 11], [{:__aliases__, [counter: 0, line: 11], [:IO]}, :puts]},
     [line: 11], ["Hello"]}
    Different Code
    ```

## The `unquote` Function

> `unqoute` can only be used inside a `quote`.
>  Better to read `unquote` as `inject_code_fragment`

* `eg2.exs`

    ```
    defmodule My do
      defmacro macro(code) do
        
        #
        # Elixir is just parsing reqular code so the name `code` is
        # inserted literally into the code
        #
        quote do
          IO.inspect(code)
        end
      end
    end
    
    
    defmodule Test do
      require My
    
      My.macro(IO.puts("Hello"))
    end
    ```
    
    results in error
    
    ```
    == Compilation error on file eg2.exs ==
    ** (CompileError) eg2.exs:13: undefined function code/0
    expanding macro: My.macro/1
    eg2.exs:13: Test (module)
    ```

* `eg3.exs`

    ```
    defmodule My do
      defmacro macro(code) do
        quote do
          #
          # Using `unquote` to temporarily turns off quoting
          # and simply injects a code fragment
          # into the sequence of code being returned by quote
          #
          IO.inspect(unquote(code))
        end
      end
    end
    
    
    defmodule Test do
      require My
    
      My.macro(IO.puts("Hello"))
    end
    ```
    
    * Inside the `quote` block, Elixir is busy parsing the code and generating its internal representation.
    * When it hits the `unquote`, it stops parsing and simply copies the `code` parameter into the generated code,
    * After `unquote`, it goes back to regular parsing

    > Alternatively way to think, using `unquote` inside a `quote` is
    > a way of deferring the execution of the unquoted code. It doesn't
    > run when the quote bloack is parsed. Instead, it runs when the code
    > generated by the quote block is executed
    > 
    
    > Also think, in terms of our qoute-as-string-literal-analogy.
    > `unquote` is a little like the interpolation.
    > 
    > When we write `quote do: def unquote(name) do end`, Elixir
    > interpolates the content of `name` into the code representation
    
## Expanding a List - `unquote_slicing`

```
#
# [3, 4] is inserted as a list, into the overall list, resulting
# in [1, 2, [3, 4]], 
#
> Code.eval_quoted(quote do: [1,2,unquote([3,4])])
{[1, 2, [3, 4]], []}

#
# To insert just the elements of the list, use
# unquote_slicing
#
> Code.eval_quoted(quote do: [1,2,unquote_splicing([3,4])])
{[1, 2, 3, 4], []}
```

## Back to Our `myif` Macro

* `myif.ex`

```
defmodule My do
  defmacro if(condition, clauses) do
    do_clause = Keyword.get(clauses, :do, nil)
    else_clause = Keyword.get(clauses, :else, nil)

    quote do
      case unquote(condition) do
        val when val in [false, nil] -> unquote(else_clause)
        _                            -> unquote(do_clause)
      end
    end
  end
end

defmodule Test do
  require My

  My.if 1 == 2 do
    IO.puts "1 == 2"
  else
    IO.puts "1 != 2"
  end
end
```

## Using Bindings to Inject Values

There are **two** ways of injecting values into quoated bloacks; one is using `quote` and the other is to use a **binding**; the two have different uses and different semantics.

* A **Binding** is simply a keyword list of variable names and their values.

* `macro_binding`

    ```
    defmodule My do
      defmacro mydef(name) do
        #
        # Using bind_quoted: option
        #
        quote bind_quoted: [name: name] do
          def unquote(name)(), do: unquote(name)
        end
      end
    end
    
    defmodule Test do
      require My
    
      [:fred, :bret ] |> Enum.each(&My.mydef(&1))
    end
    
    IO.puts Test.fred
    ```

    * Two things happens here,
        * First, the binding makes the current value of `name` available in the body
        * Second the presence of the `bind_quoted:` option automatically defers the execution of the `unquote` calls in the body
            * the method are defined at run time.

        > `bind_quoted` takes a quoted code fragment - Simply things such
        > as tuples are the same as normal and quoted code, but for most
        > values, you probably want to quote them or use `Macro.escape`
        > to ensure it is interpreted correctly
        
## Macros Are Hygienic

* Macros are more than  texual substituation

```
defmodule Scope do
  defmacro update_local(val) do
    local = "some value"

    result = quote do
      local = unquote(val)
      IO.puts "End of macro body, local = #{local}"
    end

    IO.puts "In macro definition, loca = #{local}"
    result
  end
end

defmodule Test do
  require Scope

  local = 123

  Scope.update_local("cat")

  IO.puts "On return, local = #{local}"
end


#
# Out put - Note to the last out put line
#
In macro definition, loca = some value
End of macro body, local = cat
On return, local = 123

```

* If the macro body was jut substitued in at the point of call, it would have resulted

    ```
    In macro definition, local = some value    End of macro body, local = cat
    
    #
    # local would have been changed.
    #    On return, local = cat
    ```

* Macro definition has both its won scope and a scope during execution of the quoted macro body
    * macro will not clobber each other's variables or the variables of modules and functions that use them

* `import` and `alias` functions are also locally scoped. see documentation for `quote`    

## Other Ways to Run Code Fragments

* `Code.eval_quoted` to evaluated code fragments

    ```
    > fragment = quote do: IO.puts(var!(a))
    {{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [], ["hello"]}
    
    > Code.eval_quoted fragment
    hello
    {:ok, []}
    ```

* `Code.string_to_quoted` converts a string containing code to its quoted form
* `Macro.to_string` converts a code fragment back into a string

    ```
    > fragment = Code.string_to_quoted("defmodule A do def b(c) do c+1 end end")
    {:ok,
     {:defmodule, [line: 1],
      [{:__aliases__, [counter: 0, line: 1], [:A]},
       [do: {:def, [line: 1],
         [{:b, [line: 1], [{:c, [line: 1], nil}]},
          [do: {:+, [line: 1], [{:c, [line: 1], nil}, 1]}]]}]]}}
    
    > Macro.to_string(fragment)
    "{:ok, defmodule(A) do\n  def(b(c)) do\n    c + 1\n  end\nend}"
    ```

* `Code.eval_string` to evaluate a string directly
    
    ```
    > Code.eval_string("[a, a*b, c]", [a: 2, b: 3, c: 4])
    {[2, 6, 4], [a: 2, b: 3, c: 4]}
    ```

## Macros and Operators

> Warning: Dangerous Ground

You can override the unary and binary operators in Elixir using macros

```
defmodule Operators do
  defmacro a + b do
    quote do
      to_string(unquote(a)) <> to_string(unquote(b))
    end
  end
end

defmodule Test do
  #
  # "579"
  #
  IO.puts 123 + 456

  #
  # remove exising + operator
  #
  import Kernel, except: [+: 2]

  import Operators

  #
  # "123456"
  #
  IO.puts 123 + 345
end

#
# "579"
#
IO.puts 123 + 456
```

* Macro's definition is lexically scoped - the `+` operator is overridden from the point when we import the `Operators` module through the end of the module that imports it

* `Macro` module has two functions that lists the unary and binary operators

```
> require Macro

> Macro.binary_ops
[:===, :!==, :==, :!=, :<=, :>=, :&&, :||, :<>, :++, :--, :\\, :::, :<-, :..,
 :|>, :=~, :<, :>, :->, :+, :-, :*, :/, :=, :|, :., :and, :or, :when, :in, :~>>,
 :<<~, :~>, :<~, :<~>, :<|>, :<<<, :>>>, :|||, :&&&, :^^^, :~~~]
 

> Macro.unary_ops
[:!, :@, :^, :not, :+, :-, :~~~, :&] 
```

## Digging Deeper

`Code` and `Macro` modules contain the functions that manipulate the internal representation of code

Check the source of the `Kermel` module for a list of the majority of the operator macros, along with macros for things such as `def`, `defmodule`, `alias` and so on.

## Digging Ridiculously Deep

Example internal representation of a simple expression

```
> quote do: 1 + 2
{:+, [context: Elixir, import: Kernel], [1, 2]}
```
* A three-element tuple
    * First is Function
    * Second is housekeeping metadata
    * Third is the arguments

We know we can evaluate this code fragment using `eval_quoted`

```
> Code.eval_quoted {:+, [], [1,2]}
{ 3, [] }
```

We can start to see the promise (and danger) of a **homoiconic language**. Because the code is just tuples and because we can manipuate those tuples,

* we can rewrite the definitions of existing functions
* We can create a new code on the fly
* and we can do it in a safe way because we can control
* the scope of both the changes and the access to variables 
