defmodule My do
  defmacro macro(code) do
    quote do
      #
      # Using `unquote` to pass
      #
      IO.inspect(unquote(code))
    end
  end
end


defmodule Test do
  require My

  My.macro(IO.puts("Hello"))
end