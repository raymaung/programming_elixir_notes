#=> [1,3,7,13,21]
[1, 2, 3, 4, 5]
  |> Enum.map(&(&1 * &1))
  |> Enum.with_index
  |> Enum.map(fn {value, index} -> value - index end)
  |> IO.inspect

IO.puts File.read!("ch10.exs")
        |> String.split
        |> Enum.max_by(&String.length/1)

# A Stream Is a Composable Enumerator
s = Stream.map [1, 3, 5, 7], &(&1 + 1)
s |> Enum.to_list


[1,2,3,4]
  |> Stream.map(&(&1*&1))
  |> Stream.map(&(&1+1))
  |> Stream.filter(fn x -> rem(x,2) == 1 end)
  |> Enum.to_list
  |> IO.inspect

IO.puts File.open!("ch10.exs")
        |> IO.stream(:line)
        |> Enum.max_by(&String.length/1)
        |> IO.inspect

Stream.cycle(~w{ green white })
  |> Stream.zip(1..5)
  |> Enum.map(
      fn
        {class, value} ->
          ~s{<tr class="#{class}"><td>#{value}</td></tr>\n}
      end
    )
  |> IO.puts


# Stream.unfold
Stream.unfold(
  {0, 1},
  fn
    {f1, f2} -> {f1, {f2, f1 + f2} }
  end
) |> Enum.take(10)