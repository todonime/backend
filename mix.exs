defmodule Todonime.MixProject do
  use Mix.Project

  def project do
    [
      app: :todonime,
      version: "0.3.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger,
        :plug_cowboy,
        :timex
      ],
      mod: {Todonime.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:storage, path: "local_deps/storage"},
      {:jason, "~> 1.2"},
      {:sqlitex, "~> 1.7"},
      {:plug_cowboy, "~> 2.4"},
      {:guardian, "~> 2.1"},
      {:distillery, "~> 2.1"},
      {:edeliver, "~> 1.8"},
      {:johanna, "~> 0.2.1"},
      {:timex, "~> 3.5"},
      {:httpoison, "~> 1.7"}
    ]
  end
end
