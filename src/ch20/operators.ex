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