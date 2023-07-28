defmodule Todo.Application do
  @moduledoc """
  Main entry point of the app.
  """

  use Application
  require Logger

  alias AppConfig

  @impl true
  def start(_type, _args) do
    children = [
      {
      Plug.Cowboy,
      scheme: :http,
      plug: MyApp,
      options: [port: AppConfig.get_port()]},
      Repo
      #MetricsExample.Telemetry
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]

    Logger.info("Plug now running on localhost: #{inspect(AppConfig.get_port())}")
    Supervisor.start_link(children, opts)
  end
end
