defmodule Todonime.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug :match
  plug Todonime.AuthAccessPipeline
  plug :dispatch

  get "/watch/:id", do: Todonime.Controller.Watch.get(conn, id)
  post "/auth", do: Todonime.Controller.Auth.internal(conn)

  match "" do
    {:ok, version} = :application.get_key(:todonime, :vsn)
    send_resp(conn, 200, "Todonime #{List.to_string(version)}.")
  end

  get _, do: send_resp(conn, 404, "{\"message\": \"Route not found.\"}")

  def handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    case reason.__struct__ do
      Todonime.Exception.ClientException -> reason.message
      Todonime.Exception.NotFound -> reason.message
      _ -> "server error"
    end
    |> (&send_resp(conn, conn.status, Jason.encode! %{message: &1})).()
  end
end