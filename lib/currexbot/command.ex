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

  def translate(lang, command) when is_map(command) do
    case lang do
      "ru" -> command.ru
      _ -> command.en
    end
  end
end
