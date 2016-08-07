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
  require Logger

  @vsn "1"
  defmodule State do
    defstruct current_number: 0, stash_pid: nil, delta: 1
  end

  def start_link(stash_pid) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)
  end

  def next_number do
    Logger.info "version 0.0.3 - next_number"
    with next_number = GenServer.call(__MODULE__, :next_number),
    do: "The next number is #{next_number} - version 0.0.3"
  end

  def increment_number(delta) do
    GenServer.cast __MODULE__, {:increment_number, delta}
  end

  ###########################
  # GenServer implementation
  def init(stash_pid) do
    current_number = Sequence.Stash.get_value stash_pid
    { :ok,
      %State{current_number: current_number, stash_pid: stash_pid} }
  end

  def handle_call(:next_number, _from, state) do
    { :reply,
      state.current_number,
      %{state | current_number: state.current_number + state.delta } }
  end

  def handle_cast({:increment_number, delta}, state) do
    { :noreply,
      %{state | current_number: state.current_number + delta, delta: delta } }
  end

  def terminate(_reason, state) do
    Sequence.Stash.save_value state.stash_pid, state.current_number
  end

  #
  # Formatting for :sys.get_status call
  #
  # def format_status(_reason, [_pdict, state]) do
  #   [data: [{'State', "My current state is '#{inspect state}', and I'm happy"}]]
  # end

  def code_change("0", old_state = {current_number, stash_pid}, _extra) do
    new_state = %State{ current_number: current_number,
                        stash_pid: stash_pid,
                        delta: 1
                }
    Logger.info "Changing code 0 to 1"
    Logger.info inspect(old_state)
    Logger.info inspect(new_state)
    {:ok, new_state}
  end
end