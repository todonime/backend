defmodule Todonime.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug :match
  plug Todonime.AuthAccessPipeline
  plug :dispatch

  get "/watch/:id", do: Todonime.Controller.Watch.get(conn, id)
  post "/auth", do: Todonime.Controller.Auth.internal(conn)

  def handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    case reason.__struct__ do
      Todonime.Exception.ClientException -> reason.message
      Todonime.Exception.NotFound -> reason.message
      _ -> "server error"
    end
    |> (&send_resp(conn, conn.status, Jason.encode! %{message: &1})).()
  end
end