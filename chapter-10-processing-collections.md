# Chapter 10 - Processing Collections - Enum and Stream

* *Lists*, *Maps*, *Ranges*, *Files* act as collections
* Colllections differ in their implementation
    * Can Iterate through them
    * Share some additional trait
* Implement *Enumerable* protocol
* `Enum` module provides the workhorse for collections
* `Stream` module lets you enumerate a collection lazily

## Enum - Processing Collections

* `Enum` module
    * to iterate, filter, combine, split and manipulate collections

```
list = Enum.to_list 1..5

Enum.map(list, &(&1 * 10))

Enum.at(10..20, 3)

require Integer
Enum.filter(list, &Integer.is_even/1)
```

## A Note on Sorting

```
Enum.sort ["there", "was", "a", "crooked", "man"],
    &(String.length(&1) <= String.length(&2))

```

* Important to use `<=` instead of `<` if you want the sort to be stable

## Streams - Lazy Enumerables

* `Enum` module is greedy; potentially consumes all the contents of that collections

```
[ 1, 2, 3, 4, 5 ]
  |> Enum.map(&(&1*&1))
  |> Enum.with_index
  |> Enum.map(fn {value, index} -> value - index end)
  |> IO.inspect
```
* A new list created for each `|>`
* Problem when the list is very long like when processing files

## A Stream is A composable enumerator

```
[1,2,3,4]  |> Stream.map(&(&1*&1))  |> Stream.map(&(&1+1))  |> Stream.filter(fn x -> rem(x,2) == 1 end)
  |> Enum.to_list```
* No itermediate list created
* Streams aren't only for the list

```
IO.puts File.open!("/usr/share/dict/words")
        |> IO.stream(:line)        |> Enum.max_by(&String.length/1)
```
* `IO.stream` converts an IO device into a stream that serves one line at a time.
* Consider case where reading data from a remote server, successive lines might arrive slowly
    * *Enum* you'd have to wait all the lines to arrive before start processing
    * With streams, process them as they arrive

## Infinite Streams

* Because streams are lazy, no need for the whole collection to be available up front
    * `Enum.map(1..10_000_000, &(&1+1)) |> Enum.take(5)`
        * take 8 or more seconds 
        * Elixir is busy creating 10-million element list
    * `Stream.map(1..10_000_000, &(&1+1)) |> Enum.take(5)`
        * Result comes back instantaneously
        * `take` just need five values  

## Creating your own streams

* Streams are implemented solely in Elixir libraries
    * no specific runtime support
    * Actual implementation is very complex
* Use some helpful wrapper functions to do the heavy lifting
    * `cycle`, `repeatedly`, `iterate`, `unfold`, `resource`

### `Stream.cycle`

* Takes an enumerable and returns an infinite stream of elements

```
Stream.cycle(~w{ green white })
    |> 
```

### `Stream.repeatedly`

* Takes a function and invokes each time a new value is wanted

    ```
    Stream.repeatedly(fn -> true end) |> Enum.take(3)
    ```

### `Stream.iterate`

* Generate an infinite stream
* `Stream.iterate(start_value, next_fun)`
    * `start_value` is the first value
    * `next_fun` function to generate next value 

### `Stream.unfold`

* Related to `Stream.iterate` but can be more explicit
    * the values output to the stream and the values passed to the next iteration
* Supply two values; initial value and function
    * Function is use the argument to create two values as tuple
    * 1st value = the value return by this iteration
    * 2nd value = the value to be passed in as argument for the next iteration

* `fn state -> { stream_value, new_state } end` is a general form of the function

```
Stream.unfold(
  {0, 1},
  fn
    {f1, f2} -> {f1, {f2, f1 + f2} }
  end
) |> Enum.take(10)
```

### `Stream.resource`

* builds upon `Stream.unfold`
* Unlike `unfold` taking 1st argument as value, `resource` takes a function that returns a value
    * Allow the stream to *not* to open the resource until the stream starts delivering values 
* Take 3rd argument to close it

```
Stream.resource(fn -> File.open!("sample") end,                fn file ->                  case IO.read(file, :line) do                    data when is_binary(data) -> {[data], file}                    _ -> {:halt, file}                  end
                end,                fn file -> File.close(file) end)
```

### Streams in Practice

* Consider using streams when you want to defer processing until you need the data
* Need to deal with large numbers of things without necessarily generating them all at once

## The Collectable Protocol

* `Enumerable` protocol lets you iterate over the elements in a type
* `Collectable` is in some sense the opposite; it allows you to build a collection
* Not all collections are *collectable*; ie. *Ranges* do not allow new entries
* Very low level - typically access via `Enum.into`
* `Enum.into 1..5, [100] # [100, 1, 2, 3, 4, 5]`
* `Enum.into IO.stream(:stdio, :line), IO.stream(:stdio, :line)`
    * Output streams are collectable; lazily copies standard input into standard output

## Comprehensions 

* Elixir provides *comprehension*
* given one or more collections, extract all compinations of values from each, optionally filter the values and then generate a new collection
* Generate syntax - *result = for generator or filter... [, into: value], do: expression*

`for x <- [1, 2, 3, 4, 5], do: x * x`
* *pattern <- enumerable_thing*

## Comprehensions Work on Bits, Too

* A bit string is simply a collection of ones and zeros

`for << ch <- "hello" >>, do: ch`

## Scoping and Comprehensions
```
name = "Dave"
for name < ["cat", "dog"], do: String.upcase(name)

# Name remain as "Dave"
IO.puts name 
```

## The Value Returned by a Comprehension

* Use `into:` to receive the results of the comprehensions
* `for x <- ["cat", "dog"], into: Map.new, do: { x, String.upcase(x) }`
* Collection does not have to be empty
* 