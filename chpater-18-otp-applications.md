# Chpater 18 - OTP: Applications

## This Is Not Your Father's Application

* OTP comes from the ERLANG
* In the OTP world, an *application* is a bundle of code that comes with a descriptor
    * Descriptor tells the runtime what dependencies the code has, what global names it registers and so on
    * More like a dynamic link library or a shred object than a conventional application

* Help to see the word *application* but prononce it *component* or *service*

## The Application Specification File

* *name.app* - *name* is the application's name
    * called *application specification file to define the application to the runtime environment
    * *mix* automatically create the file from `mix.exs`
    * this file is consulted to get things loaded
* Your application doesn't need to use all OTP functionalities, but once you start using OTP supervision tress, stuffs in`mix.exs` will get copied into the `.app` file

## Turning Our Sequence Program into an OTP Application

* The Chapter-17 app is already a full-blown OTP application.

```
  def application do
    [
      applications: [:logger],
      mod: {Sequence, 456},
      registered: [ Sequence.Server ]
    ]
  end
```
* the above in in `mix.exs` defines the application function
* it says the top level module of our application is called `Sequence`
	* it assumes the module implement a `start` function
	* it will pass in the empty list as a parameter
	* `registered:` lists the names of that our application will register
		* use this to ensure each name is unique across all loaded applications in a node or cluster
		* In our case, `Sequence.Server` registers itself

* run `mix compile` to compile and update `sequence.app` application specification
	* Build folder `_build/dev/lib/sequence/ebin`
	* `sequence.app`
		* contains an Erlang tuple that defines the app
		* some information comes from the project and application section of `mix.exs`
		* Mix also automatically added a list of the names of all the compiled modules in our app `*.beam` files

## More on Application Parameters

* Instead of passing in the interger `456` to the application as an initail parameter, better to passed in a key-word list

```
def application do
  [    mod: { Sequence, [] },    env: [initial_number: 456],
    registered: [ Sequence.Server ]  ]end
```

* Use `Application.get_env(:sequence, :initial_number)` to grab value from environment variable

## Supervision Is the Basis of Reliability

* Two supervisor processes and two worker processes got started
* they are knitted together so our system continued to run with no loss of state even if the worker is crashed
* `start` function takes two parameters
    * the second corresponds to the value specified in the `mod:` in the `mix.exs` file
    * the first one specifies the status of the *restart*

## Releasing Your Code

* A *release* is a bundle that contains a particular version of your application, its dependencies, its configuration, and any metadata it requires to get running and stay running.
* A *deployment* is away of getting a release into an environment where it can be used
* A *hot upgrade* a kind of deployment that allows the release of a currently running application to be changed while that application continues to run

## EXRM - the Elixir Release Manager

* `exrm` is an Elixir package that makes most release task easy
* Built on top of `relx` package - which uses some special features of the Erlang virtual machine

## Before we Start

* In Elixir, we version *both* the application code and the data it operates on.
* These two are independent.
    * you might go for a dozen code releases without changing any data structures
* the code version is stored in the `project` dictionary in `mix.exs`

In an OTP Application

* all state is maintained by servers
* Each server state is independent
* it makes sense to version the app data within each server module
    * ie. a server initial holdes its state in a 2-element tuple for version 0, but later changed to hold state in a three-element tuple in version 1.

* `@vsn` directive to se the version of the state data in our server

```
defmodule Sequence.Server do
  use GenServer
  @vsn "0"
  ...
```

## Your First Release

* Add `exrm` as a project dependency in `mix.exs`
* `mix do deps.get, deps.compile` to install dependencies
* `mix release` to compile and release
* `./rel/sequence` release folder
    * `bin` global scripts
    * `erts-7.1` the erlang runtime
    * `lib` beam files for all the app's dependencies
    * `releases` metadata for individual releases
        * `0.0.1/sequence.tar.gz` the most important file, contains everything needed to run the release

## A Toy Development Environment

```
> ssh localhost mkdir ~/deploy
> scp rel/sequence/releases/0.0.1/sequence.tar.gz localhost:deploy
> ssh localhost tar -x -f ~/deploy/sequence.tar.gz -C ~/deploy
```

* copy the tar file to the target machine
* unzip the tar file in a folder
* run the app `~/deploy/bin/sequence console`
* Don't quit - for the next host loading new version

### Hot Loading new version

* First version as it has to create an environment for the app
* For subsequence releases, copy over the tar file under `deploy/releases/0.0.2/`
* to upgrade run `deploy/bin/sequence upgrade 0.0.2`
* Done - run `Sequence.Server.next_number` and the new version will take effect
* In case new release was a disaster, downgrade again by running
    * `deploy/bin/sequence downgrade 0.0.2`

> Erlang can run two versions of a *module* at the same time.
> Currently executing code will continue to use the old version until code explicitly cites the name of the module that has changed.
> Until the next request reference the module explicitly and the new code will be loaded
> In our case, calling `Sequence.Server.next_number` triggers the reload
