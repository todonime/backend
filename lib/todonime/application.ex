defmodule Todonime.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    db_path = Application.fetch_env!(:todonime, :database)
    port = Application.get_env(:todonime, :port, 9001)

    db_child_spec = %{
      id: Sqlitex.Server,
      start: {Sqlitex.Server, :start_link, [db_path, [name: :db]]}
    }
    plug = {
      Plug.Cowboy,
      scheme: :http,
      plug: Todonime.Router,
      options: [port: port]
    }

    childs = [
      db_child_spec,
      plug
    ]

    opts = [
      strategy: :one_for_one,
      name: Todonime.Supervisor
    ]
    Supervisor.start_link(childs, opts)
  end
end
