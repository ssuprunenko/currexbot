defmodule Currexbot.Task do
  @moduledoc """
  Contains app's tasks
  """
  alias Currexbot.TaskSupervisor
  alias Currexbot.Bot

  def pull_updates(offset \\ -1) do
    case Nadia.get_updates(offset: offset) do
      {:ok, updates} when length(updates) > 0 ->
        offset = List.last(updates).update_id + 1
        dispatch_updates(updates)
        :timer.sleep(200)
      _ -> :timer.sleep(500)
    end
    pull_updates(offset)
  end

  defp dispatch_updates(updates) do
    updates
    |> Enum.each(&Task.Supervisor.start_child(TaskSupervisor, Bot, :handle_message, [&1.message]))
  end
end
