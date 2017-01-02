defmodule Bitmap do
  defstruct value: 0

  defimpl Inspect, for: Bitmap do
    import Inspect.Algebra
    def inspect(%Bitmap{value: value}, _opts) do
      concat([
        nest(
         concat([
           "%Bitmap{",
           break(""),
           nest(concat([to_string(value),
                        "=",
                        break(""),
                        as_binary(value)]),
                2),
         ]), 2),
        break(""),
        "}"])
    end
    defp as_binary(value) do
      to_string(:io_lib.format("~.2B", [value]))
    end
  end
end

#
# %Bitmap{12345678901234567890=
#    1010101101010100101010011000110011101011000111110000101011010010}
#
IO.inspect  %Bitmap{value: 12345678901234567890}