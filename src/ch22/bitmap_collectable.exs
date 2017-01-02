defmodule Bitmap do
  defstruct value: 0

  def fetch_bit(%Bitmap{value: value}, bit) do
    use Bitwise
    (value >>> bit) &&& 1
  end
end

defimpl Collectable, for: Bitmap do
  use Bitwise

  def into(%Bitmap{value: target}) do
    {
      target,
      fn
        acc, {:cont, next_bit} -> (acc <<< 1) ||| next_bit
        acc, :done             -> %Bitmap{value: acc}
        _, :halt               -> :ok
      end
    }
  end
end

# %Bitmap{value: 50}
result = Enum.into [1,1,0,0,1,0], %Bitmap{value: 0}

IO.inspect result