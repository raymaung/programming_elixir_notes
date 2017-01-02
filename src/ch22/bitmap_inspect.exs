defmodule Bitmap do

  defstruct value: 0

  defimpl Inspect do
    def inspect(%Bitmap{value: value}, _opts) do
      "%Bitmap{#{value}=#{as_binary(value)}}"
    end

    defp as_binary(value) do
      to_string(:io_lib.format("~.2B", [value]))
    end
  end
end

#
# %Bitmap{50=110010}
#
fifty = %Bitmap{value: 50}
IO.inspect fifty

#
# "%{__struct__: Bitmap, value: 50}"
#
IO.inspect fifty, structs: false

#
# %Bitmap{12345678901234567890=0101010110101010010101001100011001110 1011000111110000101011010010}
#
IO.inspect  %Bitmap{value: 12345678901234567890}