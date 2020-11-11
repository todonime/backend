defmodule Todonime.MixProject do
  use Mix.Project

  def project do
    [
      app: :todonime,
      version: "0.1.0",
      elixir: "~> 1.7.4",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:edeliver],
      extra_applications: [:logger],
      mod: {Todonime.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:storage, path: "local_deps/storage"},
      {:jason, "~> 1.2"},
      {:sqlitex, "~> 1.7"},
      {:plug_cowboy, "~> 2.0"},
      {:guardian, "~> 2.1"},
      {:distillery, "~> 2.1"},
      {:edeliver, "~> 1.6"}
    ]
  end
end
