# Chapter 15 - Nodes - The Key to Distributing Services

* *Node* is a running Erlang VM
* *Beam* = Erlang VM
    * Operating system Running on top of your host operating system
    * Handles its own
        * events
        * process scheduling
        * memory
        * naming services
        * interprocess communication
    * A node can connect to other nodes
        * in the same computer
        * across a LAN
        * across the Internet
    * A node provide smany the same servides across these connections that it provides to the processes it host locally

## Naming Nodes

* `Node.self` returns the node name
* Can set the node name when it is started
    * `iex --name wibble@light-boy.local`
    * `iex --sname wobble` to set short name
* `Node.list` returns 

### To connect to another node

* `Node.connect :"node_one@light-boy"` to connect to another node
* `Node.list` returns a list of connected node
    * If one node to connectd to another, both see as connected 

* `spawn` lets us specify a node name
    * `func = fn -> IO.inspect Node.self end`
    * `Node.spawn :"node_two@Raymonds-MacBook-Pro", func`
        * Run the `func` function on `node_two`
        * If run from `:node_one`, the output will appear on `:node_one`, regardless the process is spawned on `:node_two`
            * As the spawn was created on `node_one`, it inherits its process hirarchy from `node_one`

## Nodes, Cookies and Security

* Before a node lets another to connect, it check the remote node has permission,
    * by comparing *cookie* with its own *cookie*
    * *cookie* is an arbitrary string - ideally fairly long and very random
    * As an administrator of a distributed Elixir system, you need to create a cookie and then make sure all nodes use it
    
    > `iex --sname one --cookie chocolate-chip-1` to set the cookie
    > `Node.get_cookie` returns the cookie
    
    > When Erlang starts, it looks for an `.erlang.cookie` file in the home directory
    
## Naming Your Processes

* PID displayed as three numbers but just two fields
    * first number is the *node ID*
    * next two numbers are the low and high bits of the process ID
* When a process is run on your current node, its node ID always be *zero*
* When you export a PID to another node, the node ID is set to the number of node on which the process lives
* If you want to register a callback process on one node and an event generating process on another, just give the call back PID to the generator


* Common pattern to have `start` and `register` functions to allow calling when the module is loaded

## When to Name Processes

* When you name somthing, you are recording some global state
* Runtime has some trick to help us
    * see *packing and application page 228*
* General rule is to register your process names when your application starts

## I/O, PIDs,and Nodes

* Input and Out in the Erlang M are performed using I/O servers
    * Simply Erlang processes that implement a low-level message interface
* In Elixir, you identify an open file or device by the PIDs of its I/O server
    * they behave just like all other PIDs

Elixir `IO.put` implementation
```
def puts(device \\ group_leader(), item) do
  erl_dev = map_dev(device)  :io.put_chars erl_dev, [to_iodata(item), ?\n]end
```

### Window #1
 
```
> iex --sname one
> Node.connect :"two@xxxx" <---- connect to the Window#2 process
> two = :global.whereis_name :two
> IO.puts two, "hello" <------- will appear in Windoe#2

```

### Window #2

```
> iex --sname two
> :global.register_name(:two, :erlang.group_leader)
```

## Nodes Are the Basis of Distribution

* Create/interlink a number of Erlang virtual machines potentially communicating across a newtowk
* Easy to write concurrent applications with Elixir
    * Happy path is a lot easier than writing bullet-proof scalable and hot swappable world beating apps
    * Help is called **OTP** (see next chapter)