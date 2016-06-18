str = 'wombat'
str |> is_list |> IO.puts
str |> length |> IO.puts
str |> Enum.reverse |> IO.puts


# equivalent to 'CAT'
s = [ 67, 65, 84 ]
s |> IO.puts

# Applying usual list functions
('pole' ++ 'vault') |> IO.puts

# Print 99 = code point for 'c'
[ head | tail ] = 'cat'
IO.puts head

# Using ? notation
c_codepoint = ?c
IO.puts c_codepoint

defmodule Parse do
  def number([ ?- | tail ]), do: _number_digits(tail, 0) * -1
  def number([ ?+ | tail ]), do: _number_digits(tail, 0)
  def number(str), do: _number_digits(str, 0)
  defp _number_digits([], value), do: value
  defp _number_digits([ digit | tail ], value)
    when digit in '0123456789' do
    _number_digits(tail, value*10 + digit - ?0)
  end
  defp _number_digits([ non_digit | _ ], _) do
    raise "Invalid digit '#{[non_digit]}'"
  end
end
Parse.number('123') |> IO.puts
Parse.number('-123') |> IO.puts

defmodule StringsAndBinaries1 do
  def is_all_ascii(str) do
    valid_characters = (Enum.to_list(?a..?z)  ++ Enum.to_list(?A..?Z))
    List.foldl(str, true, fn
      (_, false) -> false
      (ch, true) -> ch in valid_characters
    end)
  end
end

(StringsAndBinaries1.is_all_ascii 'abc') |> IO.puts
List.foldl([5, 5], 10, fn (x, acc) -> x + acc end)


#
dqs = "∂x/∂y"
dqs |> String.length |> IO.puts
dqs |> byte_size |> IO.puts

