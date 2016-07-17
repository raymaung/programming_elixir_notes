#
# To run in IEX
#
# iex -S mix
# {:ok, pid} = GenServer.start_link Sequence.Server, 100
# GenServer.call pid, :next_number
# GenServer.cast pid, {:increment_number, 10}
# :sys.get_status pid
#
# To reload,
# r Sequence.Server
#
defmodule Sequence.Server do
  use GenServer

  def start_link(current_number) do
    GenServer.start_link __MODULE__, current_number, name: __MODULE__
  end

  def next_number do
    GenServer.call __MODULE__, :next_number
  end

  def increment_number(delta) do
    GenServer.cast __MODULE__, {:increment_number, delta}
  end

  ###########################
  # GenServer implementation
  def handle_call(:next_number, _from, current_number) do
    { :reply, current_number, current_number + 1}
  end

  def handle_call({:set_number, new_number}, _from, _current_number) do
    { :reply, new_number, new_number}
  end

  def handle_cast({:increment_number, delta}, current_number) do
    { :noreply, current_number + delta}
  end

  #
  # Formatting for :sys.get_status call
  #
  def format_status(_reason, [_pdict, state]) do
    [data: [{'State', "My current state is '#{inspect state}', and I'm happy"}]]
  end
end