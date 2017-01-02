defmodule Bitmap do
  defstruct value: 0

  def fetch_bit(%Bitmap{value: value}, bit) do
    use Bitwise
    (value >>> bit) &&& 1
  end
end

defimpl Enumerable, for: Bitmap do
  import :math, only: [log: 1]

  def count(%Bitmap{ value: value }) do
    {:ok, trunc(log(abs(value)) / log(2)) + 1 }
  end

  def member?(value, bit_number) do
    {:ok, 0 <= bit_number && bit_number < Enum.count(value)}
  end

  def reduce(bitmap, {:cont, acc}, fun) do
    bit_count = Enum.count(bitmap)
    _reduce({bitmap, bit_count}, {:cont, acc}, fun)
  end

  defp _reduce({_bitmap, -1}, {:cont, acc}, _fun), do: {:done, acc}

  defp _reduce({bitmap, bit_number}, {:cont, acc}, fun) do
    with bit = Bitmap.fetch_bit(bitmap, bit_number),
    do: _reduce({bitmap, bit_number - 1}, fun.(bit, acc), fun)
  end

  defp _reduce({_bitmap, _bit_number}, {:halt, acc}, _fun), do: {:halt, acc }

  defp _reduce({bitmap, bit_number}, {:suspend, acc}, fun),
  do: { :suspended, acc, &_reduce({bitmap, bit_number}, &1, fun), fun }
end

defimpl String.Chars, for: Bitmap do
  def to_string(bitmap) do
    import Enum
    bitmap
      |> reverse
      |> chunk(3)
      |> map(fn
          three_bits -> three_bits
                          |> reverse
                          |> join
        end
      )
      |> reverse
      |> join("_")
  end
end

fifty = %Bitmap{value: 50}
IO.puts "Fifty in bits is :#{fifty}"
