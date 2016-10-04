defmodule Currexbot do
  @moduledoc """
  Starts Supervisor
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Currexbot.Server, []),
      supervisor(Currexbot.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Currexbot.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
