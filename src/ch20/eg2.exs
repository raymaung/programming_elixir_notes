defmodule My do
  defmacro macro(code) do
    quote do
      #
      # Result in compile error as `code`
      # is literally inserted into the Elixir
      # compiler as the code fragment, instead of
      # what `code` internal representation
      #
      IO.inspect(code)
    end
  end
end


defmodule Test do
  require My

  My.macro(IO.puts("Hello"))
end