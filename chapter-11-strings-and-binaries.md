# Chapter 11 - Strings and Binaries

* Two kinds of Strings - Single quoted and Double quoted; they are significantly different

* String can hold *UTF-8* characters encoding
    * May contain escpate sequences
    * ie. `\a`, `\b\`
* Allow interpolation using `#{..}` syntax
    * `"Hello, #{String.capitalize name}"`  
* Support *heredocs*


## Heredocs

* Any string can span several lines

```
IO.puts "start
  my
  string
"
```
* Retain the leading and trailing new lines

```
IO.puts """
   my
   string
   """ # trailing delimiter
```
* `"""` heredocs notation indent thr trailing delimiter to the same margin as the string contents

## Sigils

* Alternative syntax for some literals ie `~r{...}`
* Delimiters can be `<...>`, `{...}`, `[...]`, `|...|`, `/.../`

## The Name "strings"

* `"cat"` double-quoted = string
* `'cat'` single-quoted = a list of characters

> **Important**
> Single and Double quoted strings are very different and libraries that work on strings work only on the double-qouted form
> 

## Single-Quoted Strings - Lists of Characters Codes

* Represented by a list of interger values

```
str = 'wombat'
is_list str 
```
* Return `true`
* To look at internal representation

``` 
str = 'wombat'
List.to_tuple str
:io.format "~w~n", [str] # ~n = new line
str ++ [0]
```

* Because a character list is a list, usual pattern matching can be used
    * `'pole' ++ 'vault'`
* `?` notation to return the code point
    * `a = ?c` return 99, the code point for `'c'`
    * Useful when employing patterns to extract information from character lists 

## Double-Quoted Strings Are Binaries

* the contents of a double quoted string (dqs) are stored as a consecutive sequence of bytes in *UTF-8*
* As some *UTF-8* characters take more than one byte, the binary size may not be the same as the string length

```
dqs = "∂x/∂y"

# return 5
String.length dq

# return 9
byte_size dqs

# ["∂", "x", "/", "∂", "y"]
String.codepoints(dqs)
```

## Strings and Elixir Libraries

* `String` module defines functions that work with doulbe-quoted strings

## Binaries and Pattern Matching* First Rule of Binaries: *if in doublt, specify the type of each field"
* Available types are
    * *binary*
    * *bits*
    * *bitstring*
    * *bytes*
    * *float*
    * etc

     