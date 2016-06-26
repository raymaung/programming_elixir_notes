#
# Increase the default VM process limit
#
# elixir --erl "+P 1000000" -r chain.ex -e "Chain.run(400_000)"
#
defmodule Chain do
  def counter(next_pid) do
    receive do
      n -> send next_pid, n + 1
    end
  end

  def create_processes(n) do
    last = Enum.reduce 1..n, self,
            fn
              (_, send_to) ->
                spawn(Chain, :counter, [send_to])
            end
    send last, 0 # start the count by sending a zero to the last process

    receive do
      # is_integer(final_anser) guard is due to some Elixir compilier bug
      final_answer when is_integer(final_answer) ->
        "Result is #{inspect(final_answer)}"
    end
  end

  def run(n) do
    IO.puts inspect :timer.tc(Chain, :create_processes, [n])
  end
end