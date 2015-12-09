defmodule Currexbot.Task do
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

  def dispatch_updates(updates) do
    updates
    |> Enum.each(&Task.Supervisor.start_child(Currexbot.TaskSupervisor, Currexbot.Bot, :handle_message, [&1.message]))
  end
end
