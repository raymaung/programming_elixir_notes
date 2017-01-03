# Appendix 1 - Exceptions; `raise` and `try`, `catch` and `throw`

* Elixir (like Erlang) takes the view that errors should normally be **fatal** to the process
* Typical Elixir application design involves many processes which means an error will be localized
    * A supervisor will detect the failing process and restart
* In Elixir, Exceptions are raised but rarely catch them
* Exceptions for things that should never happen


## Raising an Exception

```
> raise "Giving up"

> raise RuntimeError

> raise RuntimeError, message: "override message"
```

* You can intercept exceptions using the `try` function
    * take a block of code to execute
    * optional `rescue`, `catch` and `after` clauses

* `exception.ex`

    ```
    try do
      raise_error(n)
    rescue
      #
      # One of the two exceptions
      #
      [
        FunctionClauseError,
        RuntimeError
      ] ->
        IO.puts "no function match or runtime error"

      #
      # match ArithmeticError
      #
      error in [ArithmeticError] ->
        IO.inspect error
        IO.puts "un-oh! Arithmetic error"
        reraise "too late, we're doomed", System.stacktrace

      #
      # Catch all
      #
      other_errors ->
        IO.puts "Disaster! #{inspect other_errors}"
      after
        IO.puts "DONE!"
    end
    ```
    
## `catch`, `exit`, and `throw`

* Elixir code (and Erlang libraries) can raise a **second** kind of error
* they are generated when a process calls `error`, `exit` or `throw`
    * all three take a parameter

* `catch.ex`

    ```
    try do
      incite(n)
    catch
      :exit, code   -> "Exited with code #{inspect code}"
      :throw, value -> "throw called with #{inspect value}"
      what, value   -> "Caught #{inspect what} with #{inspect value}"
    end
    ```

## Defining Your own Exceptions

* Exceptions in Elixir are basically records
* In side `module`, use `defexception` to define the various fields in the exception

## Now Ignore This Appendix

* Elixir source code for `mix` utility contains no exception
* Elixir compiler contains a total of **five**

If you find yourself defining new exceptions, ask if you should be isolating the code in a separate process instead.

After all, if it can go wrong, wouldn't you want to isolate it?
