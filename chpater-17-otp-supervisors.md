# Chapter 17 - OTP: Supervisors

*Elixir* way is not to worry about code that crashes, intead make sure the overall application keeps running.

In a typical application, if an unhandled error causes an exception, the application stops - nothing gets done until it is restarted - one error takes the whole application down.

Elixir application consists of *hundreds* or *thousands* of processes - each handling just a small part of a request. If one crashes, everything else carries on. In the Elixir and OTP worlds, *supervisors* perform all of this process monitoring and restarting.


## Supervisors and Workers

Elixir supervisor has *just* one purpose - it manages one or more worker processes.

> Supervisor is a process that uses the OTP supervisor behavior - it is given
> a list of processes to monitor and is told what to do if a process dies, how to prevent restart loops.

Supervisor uses Erlang VM's process-linking and monitoring facilities.

You can write supervisors as separate modules but Elixir style is to include them inline.

```
defmodule Sequence do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(Sequence.Server, [123]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sequence.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

```

* `worker(Sequence.Server, [123])` adds `Sequence.Server` to the children processes to be supervised.

## Managing Process State Across Restarts

* Some server are effectively stateless - it can be restared and let it run again when it fails
* For server that needs to remember, ie. `Sequence.Server` -have a separate worker process that can store and retrieve a value - we'll call it our *stash*

## Supervisors Are the Heart of Reliability

* Concrete representation of the idea of building rings of confidence in our code
* The outer sing where our code interacts with the world should be as reliable as we can
* Within that ring, there are other nested rings
    *  things can be less than perfect
    *  the trick is to ensure that the code in each ring knows how to deal with failures of the code in the next ring down.
* Just small fraction of supervisors capabilities
* You can use them to manage your workers means you are forced to think about reliability and state as you design your application.