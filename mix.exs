defmodule WebServer.MixProject do
  use Mix.Project

  @integration_toolkit_version "redis-connection"
  @integration_toolkit_repo "https://GrupoBancolombia@dev.azure.com/GrupoBancolombia/Vicepresidencia%20Servicios%20de%20Tecnolog%C3%ADa/_git/NU0195001_INTEGRATION_TOOLKIT_EX"


  def project do
    [
      app: :web_server,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [release: :prod]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Todo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.2.0"},
      {:distillery, "~> 2.1"},
      {:cache_manager,
       git: @integration_toolkit_repo, tag: @integration_toolkit_version, sparse: "cache_manager"},

      #{:trx_logging,
       #git: @integration_toolkit_repo, tag: @integration_toolkit_version, sparse: "trx_logging"},
    ]
  end
end
