# Chapter 19 - Tasks and Agents

* `spawn` primitive along with essage sending/receiving and multinode operations
* *OTP* the 800-pound gorilla of proces architecture
* *Tasks and Agents* something in the middle
    * run simple processes - either background job or maintaining state
    * don't want to be bothered with the low level details of `spawn`, `send` and `receive`
    * don't need the extra control with `GenServer`

## Tasks

An Elixir task is a function that runs in the background.

```
defmodule Fib do
  def of(0), do: 0
  def of(1), do: 1
  def of(n), do: Fib.of(n - 1) + Fib.of(n - 2)
end

IO.puts "Start the task"

worker = Task.async(fn -> Fib.of(20) end)

IO.puts "Do something else"

IO.puts "Wait for the task"
result = Task.await(worker)

IO.puts "The result is #{result}"
```

* `Task.async` creates a separate process that runs in the given function
    * returns a task descriptor (actuall a PID and a ref)
* `Task.await` waits for the background job to finish and returns its value

```
worker = Task.async(Fib, :of, [20])
result = Task.await(worker)
IO.puts "The result is #{result}"
```
* You can also pass `Task.async` the name of a module and function

## Tasks and Supervision

* Tasks are implemented as OTP servers
    * they can be added to the application supervisions tree
* Two ways to add to the supervision tree

* First, you can link a task to a currently supervised process by calling `start_link`, instead of `async`
    * If the function in the task crashes, and we use `start_link`, our *process* will be terminated immediately
    * If instead we use `async`, our process will be terminated only when we subsequently call `await` on the crashed task

* Second, To run them directly from a supervisor; pretty much the same as specifying any other worker
    ```
    import Supervisor.Spec
    children = [
        worker(Task, [fn -> do_something_extraordinary() end])
    ]
    supervise children, strategy: :one_for_one
    ```
## Agents

* An agent is a background process that maintains state.
    * the state can be accessed at different places within
        * a process or
        * node or
        * across multiple nodes.
    * Initial state is set by a function we pass in when we start the agent
    * `Agent.get` to interrogate the state
        * Passing in the agent descriptor
        * Passing in a function; the agent runs the function on its current state and returns the result

    * `Agent.update` to change the state held by an agent
        * Pass in a function - the function's result becomes the new state

    * Example
        ```
        #
        # count holds the PID
        #
        > { :ok, count } = Agent.start( fn -> 0 end)
        {:ok, #PID<..>}

        > Agent.get(count, &(&1))
        0
        
        > Agent.update(count, &(&1 + 1))
        :ok
        
        > Agent.update(count, &(&1 + 1))
        :ok
        
        > Agent.get(count, &(&1))
        2
        ```
    * You can also give agents a local or global name and access them using the name
        ```
        > Agent.start(fn -> 1 end, name: Sum)
        {:ok, #PID<..>}
        
        > Agent.get(Sum, &(&1))
        1
        
        > Agent.update(Sum, &(&1 + 99))
        :ok
        
        > Agent.get(Sum, &(&1))
        100
        ```
    * See `agent_dict.exs`
        * You can look at the `Frequency` module as the implementation part of a `gen_server` using agents has simply abstracted away all the house keeping we had to do.


## A Bigger Example

* see. `anagrams.exs`
* 

## Making It Distributed

* Agents and tasks run as OTP servers, so they can be easy to distribute

`@name {:global, __MODULE__}`

## Agents and Tasks, or GenServer

When do you use agents, tasks or a GenServer?

* Use the simplest approach that works
    * *Agents and Tasks* are great when you are dealing with very specific background activities
    * *GenServer* are more general
* You can eliminate the need to make a decision by wrapping your agents and tasks in modules
    * You can always switch from the agent or task implementation to thefull-blown GenServer without affecting therest of the code base.