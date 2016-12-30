list = Enum.to_list 1..5
IO.puts list

list = Enum.concat([1,2,3], [4,5,6])
IO.puts list

l = Enum.map(list, &(&1 * 10))
IO.puts l

require Integer
Enum.filter(list, &Integer.is_even/1)

IO.puts "\nExpect: [1, 3, 7, 13, 21]"
[ 1, 2, 3, 4, 5 ]
  |> Enum.map(&(&1*&1))
  |> Enum.with_index
  |> Enum.map(fn {value, index} -> value - index end)
  |> IO.inspect

s = Stream.map [1, 3, 5, 7], &(&1 + 1)


IO.puts "\nExpect: [5, 17]"
[1,2,3,4]
  |> Stream.map(&(&1*&1))
  |> Stream.map(&(&1+1))
  |> Stream.filter(fn x -> rem(x,2) == 1 end)
  |> Enum.to_list
  |> IO.inspect