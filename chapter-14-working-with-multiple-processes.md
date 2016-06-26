# Chapter 14 - Working With Multiple Processes

* Elixir uses the *actor* model of concurrency
    * an actor is an independent process that shares nothing with any other process
    * You can `spawn` new processes; send the messages, `receive` messages back
* Elixir processes are not native operating-system processes
    * the operating-system processes are too slow and bulky
    * Elixir uses process support in Erlang - run across all your CPUs (just like native processes) but little overhead
    * Very easy to handle hundreds of thousands of Elixir processes on even a modest computer

## A simple Process

```
defmodule SpawnBasic do
  def greet do
    IO.puts "Hello"
  endend
```
* Nothing special - just regular code
* May run `SpawnBasic.greet`
* Or Spawn `spawn(SpawnBasic, :greet, [])`
    *  Kicks off a new process
    *  Comes in many forms
    *  Returns a *Process Identifier* - called *PID*
        *  *PID* - could be unique among all processes in the world;
    * Run the code we specify
    * We don't know exactly when it will execute - we know only that it is ieligible to run
    * Example Code:
        * output `Hello` prior to *iex* reporting the PID but you can't rely on it.
        * Use messages to synchronize your processes' activity

## Sending Messages Between Processes

```
defmodule Spawn1 do
  def greet do
    receive do
      {sender, msg} ->
        send sender, {:ok, "Hello #{msg}"}
    end
  end
end

# Here's a client
pid = spawn(Spawn1, :greet, [])
send pid, {self, "World!"}

receive do
  {:ok, message} -> IO.puts message
end
```

* `spawn` to create a process
    * Wait for the message to `receive`
* `send pid, {self, "World!"}` to send a message to the spawned process
    * You can send anything, but most Elixir developers seem to use atoms and tuples
    * `pid` holdes the PID of the spawned process
    * `self` returns its called PID
* Wait for the response
    * notice the `{:ok message}` pattern matching

## Handling Multiple Messages

```
defmodule Spawn4 do
  def greet do
    receive do
      {sender, msg} ->
        send sender, {:ok, "Hello #{msg}"}
        #
        # wait itself to receive messages
        #
        greet
    end
  end
end

# Here's a client
pid = spawn(Spawn4, :greet, [])
send pid, {self, "World!"}

receive do
  {:ok, message} -> IO.puts message
end

send pid, {self, "Kermit!"}
receive do
  {:ok, message} -> IO.puts message
  #
  # Error after waiting for half seconds
  #
  after 500 ->
    IO.puts "The greeter has gone away"
end
```
* the process wait itself to receive more messages

## Recursion, Looping, and the Stack

* `greet` ends up calling itself, but it doesn't happen in Elixir as it simplements *tail-call optimization*
    * tail-call optimization is when it call itself
* Example
*
```
defmodule TailRecursive do  def factorial(n), do: _fact(n, 1)  defp _fact(0, acc), do: acc  defp _fact(n, acc), do: _fact(n-1, acc*n)
end
```

## Process Overhead
```ruby
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
      final_answer when is_integer(final_answer) ->
        "Result is #{inspect(final_answer)}"
    end
  end

  def run(n) do
    IO.puts inspect :timer.tc(Chain, :create_processes, [n])
  end
end
```

* `counter` function run in separate process.
    * it is passed the PID of the next process in the chain
    * when it receives a number, it increments and sends the result to the next process
* `create_processes` is passed the number of processes to create
    * Each process is passed the PID of the *previous* process so it knows who to send the updated number to
* `reduce` call iterates over the range `1..n`
    * each time around an accumulator as the second parameter to its functions
    * initial value of the accumlator to `self`
    * `spawn` returns the PID ofthe newly created process; which becomes the accumulators's value for the next iteration
    * returns the accumlator's final value which is the PID of the last process created
* `send last, 0` sends `0` to the last process
    *  `last` process increments, then passes on the value to the process before the last and so on.
* Run in `elixir -r chain.ex -e "Chain.run(10_000)"`
    * Failed at `elixir -r chain.ex -e "Chain.run(400_000)"`
        * Due to the default Virtual Machine process limit
        * Increase the limit using `+P` virtual machine parameter limit
            * `elixir --erl "+P 1000000" -r chain.ex -e "Chain.run(400_000)"`
* Run a million processes in about 5.5 seconds and time per process is pretty much linear once we overcame the startup time.
    * This kind of performance is stunning
    * Can create hundreds of little helper processes
    * Each process can contain its own state in a way processes in Elixir are like objects in an object oriented system

## When Processes Die

* When a process dies, no one is told;
    * VM knows and can report to the console but the coe will be oblivious unless explicitly handled
    * Top level got no notification when the spawned process exited

    > To run an Elixir script
    > `elixir -r link1.exs`

## Linking Two Processes

* When processes are *linked*, each can receive information when ithe other exits
* `spawn_link` call spawns a process and links it to hte caller in one operation
* When a child process die, it killed the entire application
    * that's the default behaviour of linked processes
    * when one exits abnormally, it kills the other

### How to handle the dead of another process?

* You don't want to do this
* Elixir uses the OTP framework for constructing process trees
* OTP includes the concept of process supervision
* Convert the exit signals a linked process into a message by trapping the exit
    * `Process.flag(:trap_exit, true)` to trap exit signal

## Monitoring a Process

* *monitoring* lets a process spawn another and be notified of its termination
    * but without the reverse notification
    * one-way only

    > `:DOWN` message is received when the process (that's being monitor) exits or fails or doesn't exist.

* `spawn_monitor` to turn on monitoring when you spawn a process
    * or use `Process.monitor` to link to an existing process
        * Potential race conditions if the other process dies before your monitor call completes
* `spawn_link` and `spawn_monitor` versions are atomic, however so you will always catch a failures

    > Sample message from spa 
    > `{:DOWN,#Reference<0.0.0.53>,:process,#PID<0.37.0>,:boom}`
    > `Reference`: Identity of the monitor that was created

### when do you use links and when to use monitor?

* If *intent* is that a failure in one process should terminate another
    * use *links*
* If you need to know when some other process exits for any reason
    *  choose *monitors*

## Parallel Map - The `Hello World` of Erlang

```
defmodule Parallel do
  def pmap(collection, fun) do
    me = self
    collection
      |> Enum.map(fn
          (elem) ->
            #
            # me = the parent PID 
            # self = the PID of the spawned process
            #
            spawn_link fn -> (send me, {self, fun.(elem)}) end
        end)
      |> Enum.map(fn
          (pid) ->
            receive do
              {^pid, result} -> result
            end
        end)
  end
end
```

* First tranform `collection` into a list of *PIDs 
    * Each PID runs a given function on an individual list element
* Use `^pid` in the `receive` block to get the result for each PID in turn
    * Without `^pid` this we'd get back the results in random order
    * Changing to `_pid` may return the results in the same order but clearly contains a bug

## A Fibonacci Server & The Task Scheduler

* See, the source code `src/ch14/fib.exs`

## Agents - A Teaser

* Elixir modules are basically buckets of functions
    * They cannot hold states
* Process can hold state
* Elixir comes with `Agent` module that makes it easy to wrap a process containing state
* To Be Covered More on **Agents and Tasks**

## Thinking in Processes

* Just about every decent Elixir program will have many, many processes
    * Easy to create
    * Manage as the objects where in object-oriented programming
* Abstraction for *processes* is the *node*
    * see **Chapter 15 - Nodes - The Key to Distributing Services**