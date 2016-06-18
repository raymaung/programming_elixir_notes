# Chapter 12 - Control Flow

## `if` and `unless`

```
if 1 == 1, do: "true part", else: "false part"
if 1 == 2, do: "true part", else: "false part"

if 1 == 1 do
  "true part"
else
  "false part"
end

unless 1 == 1 do: "error", else: "ok

unless 1 == 2 do
  "Ok"
else
  "error"
end
```


## `cond`

* a macro to list out a series of conditions

```
def is_zero(current) do
  next_answer =
    cond do
      0 == 0 -> "Zero"
      
      # Catch-all
      true -> "Not Zero"
    end
end
```

## `case`

* test a value against a set of patterns
* pattern may include guard causes

```
case File.open("case.exs") do
  {:ok, file} -> "File list: #{IO.read file, :line}"
  {:error, reason} -> "Failed to open file: #{reason}"
end

dave = %{name: "Dave", age: 27}case dave do
  person = %{age: age} when is_number(age) and age >= 21 ->
    IO.puts "You are cleared to enter the Foo #{person.name}"
  _ ->
    IO.puts "Sorry, no admissioin"     
end

```

## Raising Exceptions

> * Exceptions in Elixir are not control-flow structures
> * Use less exception in Elixir than other language
> * Design philosophy is the errors should propagat back to an external supervising process

* Exception examples
    * Database going down
    * Name server failing to response
    * Failing to open a configuration file of *fixed name*

* Not-Exception Examples
    * Failing to open a file *user entered*

* To raise exception
    * `raise "Giving Up"`
    * `raise RuntimeError` 
    * `raise RuntimeError, message: "override message"`

## Designing with Exceptions

```
case File.open(user_file_name) do
  {:ok, file} -> process(file)
  {:error, message} ->    IO.puts :stderr, "Couldn't open #{user_file_name}: #{message}"
end
```
* The above does not expect the file to open each time

```
case File.open("config_file") do
  {:ok, file} -> process(file)
  {:error, message} ->    raise "Failed to open config file: #{message}"
end
```
* Expect the file to be opened successfully each time

```
# Elixir will raise MatchError when the file opeing fails
{ :ok, file } = File.open("config_file")
process(file)
```
* Expect the file to be opened - let the Exception raise an exception

* By convention `!` trailing exclamation point will raise meaningful exception on error
    * `file = File.open!("config_file")`
