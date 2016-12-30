# Chapter 9 - An Aside - What Are Types?

*  primitive data types are not necessarly the same as the types they represent
*  ie. primitive elixir list is just ordered group of values
    * `[..]` literal to create a list and `|` operator to deconstruct nad build lists
* `List` module provides a set of functions that operate on lists
* Primitive list is an implementation where `List` module adds an layer of abstraction
* `Keyword` type is an Elixir module -- implemented as a list of tuples

```
options = [ {:width, 72}, {:style, "light"}, {:style, "print"} ]

# returns {:style, "print"}
List.last options

# returns ["light", "print"] 
Keyword.get_values options, :style

```