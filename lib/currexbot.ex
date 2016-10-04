defmodule Currexbot do
  @moduledoc """
  Starts Supervisor
  """
  use Application

  @task_name Currexbot.Task
  @task_supervisor_name Currexbot.TaskSupervisor

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Currexbot.Server, []),
      supervisor(Currexbot.Repo, []),
      supervisor(Task.Supervisor, [[name: @task_supervisor_name]]),
      supervisor(Task, [@task_name, :pull_updates, []])
    ]

    opts = [strategy: :one_for_one, name: Currexbot.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
