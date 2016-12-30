# Chapter 8 Maps, Keyword Lists, Sets, and Structs


## How to Choose Between Maps and Keyword Lists

* Pattern-match against the contents, ie. `:name`
    * Use a map
* Want more than one entry with the same key?
    * Use *Keyword module* 
* Gurantee the elements are ordered?
    * Use *Keyword*
* Everything else
    * Use *map*

## Keyword Lists

* Typically used in the context of options passsed to functions
* List of tuples - the following are equivalents
    * `foo = [ {hello: "hello"}, {world: "world"} ]`
    * `foo = [ hello: "hello", world: "world" ]`

```
options = [
  fg: "red",
  style: "italic",
  style: "bold"
]

// returns "red"
options[:fg] 

// returns "italic"
Keyword.get(options, :style)

// returns ["italic", "bold"]
Keyword.get_values(options, :style)

```

## Maps

* Syntax `%{ foo: "foo" }`
* Key-Value Data Structure
* Good performance at all sizes

```
map = %{ name: "Dave", likes: "Programming", where: "Dallas" }

// returns [:likes, :name, :where]
Map.keys map

// returns ["Programming", "Dave", "Dallas"]
Map.values map

// return "Dave"
map.name

```

* `Map.put map, :also_likes, "Ruby"`
    * returns `%{also_likes: "Ruby", likes: "Programming", name: "Dave", where: "Dallas"}`
* `Map.pop` removes a key-value pair
    * returns a tuple *{value, updated_map}* 

## Pattern Matching and Updating Maps
* `person = %{ name: "Dave", height: 1.88 }`
* `%{ name: a_name } = person`
    * returns `a_name` as `"Dave"` 
* `%{ foo_key: foo_value } = person` 
    * returns *Errors*

## Pattern Matching Can't Bind Keys
* `%{ item => :ok } = %{ 1 => :ok, 2 => :error }`
    * Error `item` can't be bound to `1`

## Pattern Martching Can Match Variable Keys

```
data = %{ name: "Dave", state: "TX", likes: "Elixir" }

for key <- [:name, :likes] do
  %{ ^key => value } = data
  value
end
```
* returns `["Dave", "Elixir"]`
* `^` is a pin operator

## Updating a Map

```
m = %{ a: 1, b: 2, c: 3 }

# Update :b value to "two"
m1 = %{ m | b: "two" }

# Error - Not allow to add new entry
m2 = %{ m | two: "two" }

# Use Map.put_new/3
m2 = Map.put_new m, :two, "two"
```


## Structs
* *typed map*: a map that has fixed set of fields and default values
* Struct a module that wraps a limited form of map
  * limited 'cus *keys* must be atoms
  * Dont have `Dict` capabilities
* Uses the same syntax as map `%{}`


```
defmodule Subscriber do  defstruct name: "", paid: false, over_18: true
  
  def print_name(s = %Subscriber{}) do
    IO.puts s.name
  endend
```
* `s1 = %Subscriber{}` creates a subscriber with default values
* `s2 = %Subscriber{name: "Dave" }` creates a subscriber with default values except `:name`
* `s1.name` to access name

## Nested Dictionary Structures

```
defmodule Customer do  defstruct name: "", company: ""enddefmodule BugReport do  defstruct owner: %Customer{}, details: "", severity: 1end


report = %BugReport{
  owner: %Customer{
    name: "Dave",
    company: "Pragmatic"
  }
}

# Updating report
report = %BugReport{ report |
  owner: %Customer { report.owner |
    company: "PragProg"
  }
}
```
* Alternative, use `put_in`
    * `put_in report.owner.company, "PragProg"`
    * `put_in` is a macro that generates the long-winded code

* `update_in` to apply a function to a value in structure
    * `update_in(report.owner.name, &("Mr. " <> &1))`
        * Prefix `"Mr. "` to name

        
## Nested Accessors and Nonstructs
* For maps and keywords lists, *atoms* can be used
    * `put_in(report[:owner][:company], "PragProg")`

## Dynamic (Runtime) Nested Accessors

* `put_in`, `update_in`, `get_in` and `get_and_update_in` are just macros
    * Operate at compile time
* Limitations
    *  The number of keys youpass a particular call is static
    *  You can't pass the set of keys as parameters between functions.
* To overcome the limitations, `put_in`, `update_in`, `get_in` and `get_and_update_in` take a list of keys as separate parameters

```
nested = %{
  buttercup: %{
    actor: %{
      first: "Robin",
      last: "Wright"
    },
    role: "princess"
  },
  westley: %{
    actor: %{
      first: "Carey",
      last: "Ewes"
    },
    role: "farm boy"
  }
}
```
* `get_in(nested, [:buttercup, :actor, :first])` returns `"Robin"`
* `put_in(nested, [:westley, :actor, :last], "Elwes")` 

### Cool Trick
* Dynamic versions of both `get_in` and `get_and_update_in` support
   * pass a function as a key and function is invoked to return the corresponding values

```
authors = [  %{ name: "José", language: "Elixir" },
  %{ name: "Matz", language: "Ruby" },
  %{ name: "Larry", language: "Perl" }]languages_with_an_r = fn
  (:get, collection, next_fn) ->
    for row <- collection do      if String.contains?(row.language, "r") do
        next_fn.(row)      end
    endendIO.inspect get_in(authors, [languages_with_an_r, :name])
``` 

## Sets
* `MapSet` is one implementation of sets

```
set1 = Enum.into 1..5, MapSet.new
set2 = Enum.into 3..8, MapSet.new

# return true
MapSet.member? set1, 3

# union two sets
MapSet.union set1, set2
```

## With Great Power Comes Great Temptation* *Structs*, *maps* and *modules*  are not for writing object-orientated code

