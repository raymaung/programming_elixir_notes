# Chapter 16 - OTP:Servers

> OTP - Open Telecom Platform

* a bundle that includes Erlang, a database (*Mnesia*) and a innumerable number of libraries.
* Define a structure for your applications
* Very large complex frameworks

## Some OTP Definitions

OTP defines systems in terms of hierarchies of applications.

* an application consists of one or more processes
* process follow one of a small number of OTP conventions - *behaviors*

There is a behavior used for

* one general-purpose servers - 
* one for implementating event handlers
* one for finite-state machines
* Each run in its own process


* *GenServer*
    * server behavior
* *supervisor*
    * monitors the health of these processes 
    * implements strategires for restarting them if needed

## An OTP Server

when we write an OTP server, we write a module containing

* one or more call back functions with starnd ard names.
* OTP invoke the appropriate callback to handle a particular situation

##  State and the Single Server

```
defmodule MyList do
  def sum([], total), do: total
  def sum([head | tail], total), do: sum(tail, total + head)
end
```

* `total` maintains the state while the function trundles down the list.

> In our earlier-chapter Fibonacci code, we maintained a lot of state in the >
> `schedule_processes` function - in face all theree of its parameters were used
> for state information.

Now think about servers. They use recursion to loop, handling one request one each call - so they can pass state to themselves as a parameters in this recursive call - that's one of the thing OTP manages for us.

* Our handler functions get passed the current state and they return (among other things) a potentially updated state.
* What ever state a function returns, is the state that will passed to the next request handler.

## Our First OTP Server

* Writing the simplest OTP server
    * pass a number when you start it up - that becomes the current state of the server
    * when you call it with a `:next_number` request, it returns that current state to the caller at the same time increments the state and ready for the next call.

## Create New Project Using Mix

```
defmodule Sequence.Server do
  use GenServer

  def handle_call({:next_number, _from, current_number}) do
    { :reply, current_number, current_number + 1}
  end
end
```

* `use GenServer` adds the OTP *GenServer* behaviors to our module
    * we don't have to defne every callback in our module - the behavior defines defaults for them all
* when a client calls our server, GenServer invokes the `handle_call` function that follows
    * the information the client passed to the call as its first parameter
        * ie. `:next_number`
    * the PID of the client as the second parameter
        * ie. `_from`
    * and the server state as the third parameter
        * ie. `current_number`
* Return a tuple to OTP `{:reply, current_number, current_number + 1}`
    * `:reply` tells OTP to reply to the client
    * Passing back the value
    * third element defines the new state - it will be passed as the last parameter to `handle_call` the next time it is invoked

```
iex -S mix
{ :ok, pid } = GenServer.start_link(Sequence.Server, 100)

GenServer.call pid, :next_number
```
* From the Elixir `GenServer` module
    * `start_link` behaves like `spawn_link`
        * asks `GenServer` to start a new process and link to us
        * Pass in the module `Sequence.Server` to run as server
        * Pass in Initial state `100`
        * Use default third parameter
        * return `{:ok, pid}`
    * `call` function takes in `pid` and call `handle_call`
        * second parameter is passed as first argument to `handle_call`


```
def handle_call({:set_number, new_number}, _from, _current_number) do
    { :reply, new_number, new_number}
end
```
* server can support multiple actions by implemeting multile `handle_call`

## One-Way Calls

* `call` function calls a server and waits for a reply
* `cast` is like `call` but no reply - `cast` is sent to `handle_cast`
    * since there is no response, `cast` takes only two parameters
        * call argument and the current state
        * returns `{:noreply, new_state}`

## Tracing a Server's Execution

* third parameter to `start_link` is a set of options
    * a useful one is the debug trace
    * `> {:ok, pid} = GenServer.start_link(Sequence.Server, 100, [debug [:trace])`
        * `:trace`
        * `:statistics`
            * `:sys.statistics pid, :get`
            * Erlang `sys` is your interface to the world of *system messages*
* the list associated with the `debug` parameter is simply the names of functions to call in the `sys` module
    * `[debug: [:trace, :statistics]]` then those functions will be called in `sys` passing in the server PID

* You can turn things on and off *after* you have started a server
    * `:sys.trace pid, true` to turn on/off `:trace`
    * `:sys.get_status pid`  

    ```
      def format_status(_reason, [_pdict, state]) do
        [data: [{'State', "My current state is '#{inspect state}', and I'm happy"}]]
      end
    ```
    
## Digging Evn Deepter

* `iex> :observer.start()` to get basic system information 

## GenServer Callbacks

* GenServer is OTP protocol
* OTP works by assuming that your module defines a number of call back functions - six in the case of GenServer
    * If you were writing a GenServer in Erlang, your code would have to contain implementations for all six
    * `use GenServer` in Elixir automatically creates default implementation

### Six Functions

* `init(start_arguments)`
    * should return `{:ok, state}` on success, `{:stop, reason}` if the server couldn't be started
    * Optional time out using `{:ok, state, timeout}` - GenServer sends the process a `:timeout` message whenever no message iss received in a span of *timeout* ms.

* `handle_call(request, from, state)`
    * Invoked when a client uses `GenServer.call(pid, request)`
    * `from` is a a tuple containing the client PID, and a unique tag
    * `state` is the server state
    * default implementation stops the server with a `:bad_call` error
        * you will need to implement for every call request type your server implements

* `handle_cast(request, state)`
    * Response to `GenServer.cast(pid, request)`
    * Success Response is `{:noreply, new_state}`
    * Can also retunr `{:stop, reason, new_state}`
    * Default implementation is `:bad_cast` error

* `handle_info(info, state)`
    * Handle incoming message that are not `call` or `cast` request
    * Example `timeout` messages are handled here, so are termination messages from any linked process
    * Messages send to the PID using `send`; bypassing GenServer


* `terminate(reason, state)`
    * Called when the server is about to be terminated

* `code_change(from_version, state, extra)`
    * OTP lets us replace a running server without stopping the system
    * `code_change` to invoked to change from the old state format to the new

* `format_status(reason, [pdict, state])`
    * To customize the state display of the server
    * Convention Response is `[data: [{'State', state_info}]]`

`call` and `cast` handlers return standardized responses.  Some responses can contain an optional `:hibernate` or `timeout` parameter

* if `higernate` is returned, the server state is removed from memory but is recovered on the next reques to save memory at the expense of some CPU
* `timeout` option can be the atom `:inifinite` (default) or a number
    * if a number, a `:timeout` message is sent if the server is idel for the specified number of milliseconds

The first responses are common between `call` and `cast`

* `{:noreply, new_state, [, :hibernate | timeout ]}`
* `{:stop, reason, new_state}` signal that the server is to terminate

Only `handle_call` can use the last two

* `{:reply, response, new_state, [, :hibernate | timeout]}` sends `response` to the client
* `{:stop, reason, reply, new_state}` sends the  response and signal that the server is about to terminate.

## Naming a Process

* Alternatives way to reference processes, instead of PID
* Simplest is local naming
    * assign a name that is unique for all OTP processes on our server
    * use the name instead of the PID
    * to create a locally named process
        * use `name:` option

        ```
        {:ok, pid} = GenServer.start_link(Sequence.Server, 100, name: :seq)
        GenServer.call(:seq, :next_number)
        
        :sys.get_status :seq
        ```
## Tidying Up the Interface

To use the server, the callers have to make

* Explicit `GenServer` call
* Have to know the registered name for the server process

To avoid that, wrap this interface in a set of three functions in our server module

* `start_link`
* `next_number`
* `increment_number`

```
defmodule Sequence.Server do
  use GenServer

  #
  # register itself
  #
  def start_link(current_number) do
    GenServer.start_link __MODULE__, current_number, name: __MODULE__
  end

  #
  # delegate to GenServer
  #
  def next_number do
    GenServer.call __MODULE__, :next_number
  end

  #
  # delegate to GenServer
  #
  def increment_number(delta) do
    GenServer.cast __MODULE__, {:increment_number, delta}
  end
  ...
end
```

An OTP GenServer is just a regular Elixir process in which the message handling has been abstracted out.

GenServer defines a message loop internally and maintains a state variable. The message loop then calls out to various functions.
