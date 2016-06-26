defmodule FibSolver do
  def fib(scheduler) do
    send scheduler, {:ready, self}
    receive do
      { :fib, n, client} ->
        send client, {:answer, n, fib_calc(n), self}
        fib(scheduler)

      {:shutdown} -> exit(:normal)
    end
  end

  defp fib_calc(0), do: 0
  defp fib_calc(1), do: 1
  defp fib_calc(n), do: fib_calc(n - 1) + fib_calc(n - 2)
end


#
# - public API is `run` function
# - it receives
#     - the number of processes to run
#     - the module and function to spawn
#     - a list of things to process
#
defmodule Scheduler do
  # the number of processes to run
  # the module and function to spawn
  # a list of things to process
  def run(num_processes, module, func, to_calculate) do
    (1..num_processes)
      |> Enum.map(fn (_) -> spawn(module, func, [self]) end)
      |> schedule_processes(to_calculate, [])
  end

  #
  # Basically, a receive loop
  #
  defp schedule_processes(processes, queue, results) do
    receive do
      #
      # If there is more work in the `queue` then
      #   passes the next number to the calculator
      #   recurse with one fewer number in the queue
      #
      {:ready, pid} when length(queue) > 0 ->
        [next | tail] = queue
        send pid, {:fib, next, self}
        schedule_processes processes, tail, results

      #
      # If the work queue is empty,
      #   send `:shutdown` to the server
      #
      {:ready, pid} ->
        send pid, {:shutdown}

        if length(processes) > 1 do
          #
          # If it isn't the last process then
          #   it removes the process from the list of processes and
          #   recurse to handle another message
          #
          schedule_processes(List.delete(processes, pid), queue, results)
        else
          # If it is the last process then
          #   the work is done, sort the result
          Enum.sort(results, fn {n1, _}, {n2, _} -> n1 <= n2 end)
        end

      #
      # if it gets an :answer, it records the answer in the result
      # accumulator and recurses to handle the next message
      #
      {:answer, number, result, _pid} ->
        schedule_processes(processes, queue, [{number, result} | results])
    end
  end
end

to_process = [37, 37, 37, 37, 37, 37]
# to_process = [27, 27, 27, 27, 27, 27]
Enum.each 1..10, fn num_processes ->

  {time, result} = :timer.tc(
    Scheduler, :run,
    [num_processes, FibSolver, :fib, to_process]
  )

  if num_processes == 1 do
    IO.puts inspect result
    IO.puts "\n #\t\ttime (s)"
  end
  :io.format "~2B\t\t~.2f~n", [num_processes, time/ 1_000_000.0]
end

