defmodule Currexbot do
  use Application

  @task_name Currexbot.Task
  @task_supervisor_name Currexbot.TaskSupervisor

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: @task_supervisor_name]]),
      worker(Task, [@task_name, :pull_updates, []])
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Currexbot.Supervisor)
  end
end
