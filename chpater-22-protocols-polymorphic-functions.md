# Chapter 22 - Protocols - Polymorphic Functions

A **Protocol** is a little like the behaviours. A **behaviour** is internal to a module but **protocols** implementations are outside the module.

It means, protocol allows to extend modules functionality without having to add code to them.

## Defining a Protocol

* Very similar to basic module definitions
* Can contain *module* and *function* level documentation (ie. `@moduledoc` and `@doc`)
* Contain one or more function definitions **but** no bodies;
    * just to delcare the interface that the protocal requires.
* Example

    ```
    defprotocol Inspect do
        def inspect(thing, opts)
    end
    ```
## Implementing a Protocol

* `defimpl` macro to implement a protocol

```
defimpl Inspect, for: PID do
  def inspect(pid, _opts) do
    "#PID" <> IO.iodata_to_binary(:erlang.pid_to_list(pid))
  end
end

defimpl Inspect, for: Reference do
  def inspect(ref, _opts) do    '#Ref' ++ rest = :erlang.ref_to_list(ref)    "#Reference" <> IO.iodata_to_binary(rest) endend
```

## The Available Types

## Protocols and Structs

* Elixir doesn't have classes - but has user-defined types; it pulls off this magic using structs and a few conventions.

```
defmodule Blob do
  defstruct content: nil
end

> b = %Blob{content: 123}

> inspect b
"%Blob{content: 123}"

> inspect b, structs: false
"%{__struct__: Blob, content: 123}"
```

* By default `inspect` recognizes structs; can be turn off using `structs: false`
* If you ask it to inspect a map containing a key `__struct__`

    ```
    > b = %Blob{content: 123}

    > Map.get b, :__struct__
    Blob
    ```

## Built-In Protocols

Elixir comes with the following protocols

* Enumerable and Collectable
* Inspect
* List.Chars
* String.Chars

## Built-in Protocols: Enumerable and Collectable

* `Enumerable` protocol is the basic of all functions in the `Enum` module
* The protocol defined in terms of three functions
    
    ```
    defprotocol Enumberable do
      def count(collection)
      def memeber?(collection, value)
      def reduce(collection, acc, fun)
    end
    ``` 
    
    * `count` returns the number of elements in the collection
    * `member?` truthy if the collection contains `value`
    * `reduce` applies the given function to successive values in the collection and the accumulator

* `reduce` General Form `reduce(enumerable, accumulator, function)`
    * Takes each item in turn from `enumerable`, passing it and accumulator to the `function` 
    * The value the function returns becomes the accumulators next value

```
> fifty = %Bitmap{value: 50}
> IO.puts Enum.count fifty # => 6

> IO.puts Enum.member? fifty, 4
true

> IO.puts Enum.member? fifty, 6
false

> IO.inspect Enum.reverse fifty
[0, 1, 0, 0, 1, 1, 0]

> IO.inspect Enum.join fifty, ":"
"0:1:1:0:0:1:0"

> fifty |> Enum.into([])
[0, 1, 1, 0, 0, 1, 0]

```


```
> Enum.into [0,1,1,0,0,1,0], %Bitmap{value: 0}
** Error...
```
* Need `Collectable` protocol to fix the above

## `Collectable`

* the target of `Enum.into` must implement the `Collectable` protocol

## Remember the Big Picture

If you think all this enumerable/collectable stuff is complicated, you are correct. In part, that's because these conventions allow all enumerable values to be used both eagerly and lazily.

## Built-In Protocols: `Inspect`

* Used to inspect a value
* If you can return a representation that is a valid Elixir literal, do so
* Otherwise, prefix the representation with `#Typename`

* `bitmap_inspect.exs`

    ```
    > %Bitmap{value: 12345678901234567890}
    %Bitmap{12345678901234567890=0101010110101010010101001100011001110 1011000111110000101011010010}
    ```
    
    * Formatting for large number is too long wrapped by the console.
    * To fix it, use **algebra documents**

    > **Algebra document is a tree structure that represents some
    > data you like to pretty-print.

## Built-In Protocols: `List.Chars` and `String.Chars`

* `List.Chars` protocol is used by the Kernel `to_char_list` function to convert a value into a list of characters. 
* `String.Chars` protocol is used to conver a value to a string (binary or doublle-quoted string)
    * This is the protocol used for string interpolation

* The protocols are implemented identically, except
    * `List.Chars` requires a `to_char_list` function
    * `String.Chars` requires `to_string`

## Protocols Are Polymorphism

* When you want to write a function that behaves differently depending on the type of its arguments, you are looking at a polymorphic function.
* Protocols let you package the hehaviour in a well-documented and diciplined way