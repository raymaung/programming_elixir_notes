defmodule Cond do

  # Example cond usage
  def is_zero_using_cond(current) do
    cond do
      current == 0 -> "Zero"
      true -> "Not Zero"
    end
  end

  # cleaner implementation
  def is_zero(0), do: "Zero"
  def is_zero(_), do: "Not Zero"
end

defmodule CaseSpike do
  def case_spike(file_name) do
    case File.open(file_name) do
      {:ok, file} -> "File list: #{IO.read file, :line}"
      {:error, reason} -> "Failed to open file: #{reason}"
    end
  end
end

(CaseSpike.case_spike "ch12.exs") |> IO.puts