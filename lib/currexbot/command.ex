defmodule Currexbot.Command do
  @moduledoc """
  Commands for handle user input
  """
  defstruct [:cmd, :ru, :en]

  def values(command) do
    command
    |> Map.values
    |> Enum.reject(fn(v) -> v == Currexbot.Command end)
    |> List.flatten
  end
end
