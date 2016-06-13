data = %{ name: "Dave", state: "TX", likes: "Elixir" }

# Binding variable keys
for key <- [:name, :likes] do
  %{ ^key => value } = data
  IO.puts key
  value
end

m = %{ a: 1, b: 2, c: 3 }

# Only updating, doesn't allow adding new new entry
m1 = %{ m | b: "two"}

# To add new entry
m2 = Map.put_new m, :two, "two"

defmodule Subscriber do
  defstruct name: "", paid: false, over_18: true
end

#
# Struct
#
defmodule Subscriber do
  defstruct name: "", paid: false, over_18: true

  def print_name(s = %Subscriber{}) do
    IO.puts s.name
  end
end
s1 = %Subscriber{}
s2 = %Subscriber{ name: "Dave" }

Subscriber.print_name s1
Subscriber.print_name s2

#
# Nested Dictionary Structure
#
defmodule Customer do
  defstruct name: "", company: ""
end

defmodule BugReport do
  defstruct owner: %Customer{}, details: "", severity: 1
end

report = %BugReport{
  owner: %Customer{
    name: "Dave",
    company: "Pragmatic"
  }
}

# Updating report
report2 = %BugReport{ report |
  owner: %Customer { report.owner |
    company: "PragProg"
  }
}

# Using put_in
put_in report.owner.company, "PragProg"


#
# Dynamic Nested Accessors
#
nested = %{
  buttercup: %{
    actor: %{
      first: "Robin"
      last: "Wright"
    },
    role: "princess"
  },
  westley: %{
    actor: %{
      first: "Carey",
      last: "Ewes"
    },
    role: "farm boy"
  }
}