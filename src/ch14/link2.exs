#
# To run the script
# > elixir -r link2.exs
#
defmodule Link2 do
  import :timer, only: [ sleep: 1]

  def sad_function do
    sleep 500
    exit(:boom)
  end

  def run do
    spawn_link(Link2, :sad_function, [])
    receive do
      msg ->
        IO.puts "Mesage Received: #{msg}"
    after 500 ->
      IO.puts "Nothing happened as far as I am concerned"
    end
  end
end

Link2.run