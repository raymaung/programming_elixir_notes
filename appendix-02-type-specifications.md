# Appendix 02 - Type Specifications and Type Checking

```
@callback parse(uri_info :: URI.Info.t) :: URI.Info.t
@callback default_port() :: integer
```

* `URI.Info.t` and `integer` are examples of type specifications

## When Specifications Are Used

* Elixir type specifications come from Erlang.
* Very common to see Erlang code where every expored (public) functions is preceded by a `-spec` line

### Example Elixir Parser Code (written in Erlang)

```
-spec return_error(integer(), any()) -> no_return().return_error(Line, Message) ->      throw({error, {Line, ?MODULE, Message}}).
```

* it says `return_error` function takes two parameters;
    * an integer and any type
    * never return

* Tools such as **dialyzer** can perform static analysis of Erlang code and report type mismatches.

* Same can be done in Elixir with `@spec` attribute for documenting a function's type specification

* In `iex`
    * `s` helper for displaying specifications
    * `t` helper for showing user-defined 

* However, Type specifications **are not** currently in wide use in the Elixir world
    * a matter of personal taste

## Specifying a Type

* A type is simply a subset of all possible values in a language
    * `integer` means all the possible integer values - exclude lists, binaries and etc.
* Basic types in Elixir are
    * `any`
        * its alias `_`
    * `atom`
    * `char_list` (single quoted string)
    * `float`
    * `fun`
    * `integer`
    * `map`
    * `none`
        * empty set
    * `pid`
    * `port`
    * `reference` and
    * `tuple`
* the value `nil` can be represented as `[]` or `nil`

## Collection Types

* A list is represented as `[type]` where `type` is any of the basic or combined types

* Binaries are represented as
    * `<<>>`
        * an empty binary (size 0)
    * `<< _ :: size >>`
        * A sequence of `size` bits - it isi called a **bitstring** 
    * `<< _ :: size * unit_size >>`
        * A sequence of size units, where each unit is **unit_size** bits long

    * In the last two instances **size** can be specified as `_`; the binary has an arbitrary number of bits/units
    * The predefined type `bitstring` is equivalent to `<< _ :: _ >>`
        * an arbitrarily sized sequence of bits
    * Binaries defined as `<< _ :: _ * 8 >>`
        * an arbitrary sequence of 8-bit bytes
* Tuples are represented as `{ type, type, ... }` or using the type `tuple`

## Combining Types

* The range operator (`..`) can be used with literal integers to create a type representing that range.
* Three built-in types represent integers that are greater than or equal to, greather than, or less than zero
    * `non_integer`
    * `pos_integer` and
    * `neg_integer`

* The union operator (`|`) indicates that the acceptable values are the unions of its arguments

* Parentheses may be used to group terms in a type specification

## Types and Structures

* As structures ar ebasically maps, you caould just use the `map` type for them
* but instead recommend to define a specific type for each struct

    ```
    defmodule LineItem do
        defstruct sku: "", quantity: 1
        @type t :: %LineItem { sku: String.t, quantity: integer }
    end
    ```
    
    * Can you reference this type as `LineItem.t`

## Anonymouse Functions

* Anonymous functions are specified using `head -> return_type`
* `head` specifies the arity and possibly the types of the function parameters
    * it can be `...` meaning an arbitrary number of arbitrarily typed arguments or
    * a list of types in which as the number of types is the function's arity

    ```
    (... -> integer)                # Arbitrary parameters; returns an integer    (list(integer) -> integer)      # Takes a list of integers and returns an integer    (() -> String.t)                # Takes no parameters and returns an Elixir string    (integer, atom -> list(atom))   # Takes an integer and an atom and returns                                    # a list of atoms
    ```

## Handling Truthy Values

* `as_boolean(T)` says that the actual value matched will be type `T` but the function that uses the value will treat it as a truthy value
    * anything other than `nil` or `false` is considered `true`
* `Enum.count` function specification is

    ```
    @spec count(t, (element -> as_boolean(term))) :: non_neg_integer
    ```

## Some Examples

* *integer | float*
    * Any number (Elixir as an alias for this)

* *[ { atom, any } ]* or *list(atom, any)*
    * A list of key/value pairs, the two forms are the same

* *non_neg_integer | {:error, String.t}*
    * An integer greater than or equal to zero or a tuple containing the atom `:error` and a string

* *( integer, atom -> { :pair, atom, integer} )*
    * An anonymous function that takes an integer and an atom and returns a tuple containing the atom `:pair`, an atom and an integer

* *<< _ :: _ * 4 >>*
    * A sequence of 4-bit nibbles

## Defining New Types

* The attrigute `@type` can be used to define new types
* Elixir uses this to predefine some built-in types and aliases 

```
@type term      :: any@type binary    :: <<_::_*8>>@type bitstring :: <<_::_*1>

@type boolean   :: false | true@type byte      :: 0..255@type char      :: 0..0x10ffff@type list      ::[any]@type list(t)   ::[t]@type number    :: integer | float@type module    :: atom@type mfa       :: {module, atom, byte}@type node      :: atom@type timeout   :: :infinity | non_neg_integer@type no_return :: none
```

* `list(t)` entry shows you can parameterize the types in a new definition
    * simply use one or more identifiers as parameters on the left side and use these identifers where you'd otherwise use type names on the right
    * Then when you use the newly defined type, pass in actual types for each of these parameters

    
```
@type variant(type_name, type) :: { :variant, type_name, type)

@spec create_string_tuple(:string, String.t) :: variant(:string, String.t)
``` 

* In addition to `@type`, Elixir has the `@typep` and `@opaque` module attributes
    * same syntax as `@type` and basically the same but in the visibility of the result
    * `@typep` defines a type that is local to the module that contains it; private
    * `@opaque` defines a type whose name may be known outside the module but whose defintion is not

## Specs for Functions and Callbacks

* `@spec` specifies a function's
    * parameter count
    * types
    * return-value
* it can appear anywhere in a module but
    * by convention, it sits immediately before the function definition
    * following any function documentation

### Examples

* `@spec values(t) :: [value]`    
    * `values` takes a collection (tuple or list) and returns a list of values (any)
* `@spec size(t) :: non_neg_integer`
    * `size` takes a collections and return an integer ( >= 0 )
* `@spec has_key?(t, key) :: boolean`
    * `has_key?` takes a collection and a key and return `true` or `false`
* `@spec update(t, key, value, (value -> value)) :: t`
    * `update` takes a collection, a key, a value and a function (that map a value to a value) and return a (new) collection

For functions with multiple head (or those with default values) you can specify multiple `@spec` attributes.

* Example from `Enum` module'

    ```
    @spec at(t, index) :: element | nil
    @spec at(t, index, default) :: element | default

    def at(collection, n, default \\ nil) when n >= 0 do
    ...    end
    ```
* For more information see `Kernel.Typespec` module

## Using Dialyzer

* Dialyzer analyzes code that runs on the Erlang VM - looking for potential errors.
* To use with Elixir, compile into `.beam` files with `debug_info` compiler option

* Dialyzer needs the specifictions for all the run time libraries you're using.
    * it stores them in a cache which it calls a **persistent lookup table** or **plt**
    * To initialise **plt** for the basic Erlang runtime (erts) and the basic Elixir run time

        ```
        #
        # getting Elixir Libarries Path 
        #
        > :code.lib_dir(:elixir)
        '/Users/raymaung/.kiex/elixirs/elixir-1.3.2/lib/elixir/bin/../lib/elixir'
        
        #
        # creating PLT (note /ebin is added to the path above)
        #
        $ dialyzer --build_plt --apps erts /Users/raymaung/.kiex/elixirs/elixir-1.3.2/lib/elixir/bin/../lib/elixir/ebin
        
        #
        # running dialyzer for the project (ie. Simple project)
        #
        $ cd simple
        $ mix compile
        $ dialyzer _build/dev/lib/simple/ebin
        ```

## Dialyzer and Type Inference

* works with unannotated code as it knows built-in function types (from PLT) and can infer