defmodule Sequence.Supervisor do
  use Supervisor

  def start_link(initial_number) do
    #
    # 1. start up the super visor - automatically invoke `init`
    #
    {:ok, supervisor_pid } = Supervisor.start_link(__MODULE__, [initial_number])

    #
    # 3. start workers
    #
    start_workers(supervisor_pid, initial_number)
  end

  def start_workers(supervisor_pid, initial_number) do
    #
    # 4. start the stash worker with initial number
    #
    {:ok, stash_pid} =
      Supervisor.start_child(supervisor_pid, worker(Sequence.Stash, [initial_number]))

    # and then the subsupervisor for the actual sequence server
    Supervisor.start_child(supervisor_pid, supervisor(Sequence.SubSupervisor, [stash_pid]))
  end

  def init(_) do
    #
    # 2. the empty list to supervise
    #
    supervise [], strategy: :one_for_one
  end
end