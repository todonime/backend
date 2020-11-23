defmodule Todonime.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    db_path = Application.fetch_env!(:todonime, :database)
    port = case System.get_env("PORT") do
      port when is_binary(port) -> String.to_integer(port)
      nil -> 9001
    end

    childs = [
      %{
        id: Sqlitex.Server,
        start: {Sqlitex.Server, :start_link, [db_path, [name: :db]]}
      },
      {
        Plug.Cowboy,
        scheme: :http,
        plug: Todonime.Router,
        options: [port: port]
      }
    ]

    opts = [
      strategy: :one_for_one,
      name: Todonime.Supervisor
    ]

    case Supervisor.start_link(childs, opts) do
      {:ok, pid} ->
        add_erlcron_jobs()
        {:ok, pid}
      err -> err
    end
  end

  defp add_erlcron_jobs do
    Johanna.at({0, :am}, {Todonime.Task.Backup, :run, []})
    Johanna.at({2, :am}, {Todonime.Task.Anime.StatusSync, :run, []})
    Johanna.at({3, :am}, {Todonime.Task.Anime.Pull, :run, []})
  end
end
