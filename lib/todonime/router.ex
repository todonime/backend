defmodule Todonime.Router do
  use Plug.Router
  use Plug.ErrorHandler

  alias Todonime.Controller

  plug :match
  plug Todonime.AuthAccessPipeline
  plug :dispatch

  get "/watch/:id", do: Controller.Watch.get(conn, id)

  get "/animes/:anime_id/episodes", do: Controller.Episode.get_for_anime(conn, anime_id)
  get "/animes/:anime_id/episodes/:number", do: Controller.Episode.get_for_anime_by_number(conn, anime_id, number)
  get "/animes/:anime_id", do: Controller.Anime.get(conn, anime_id)
  
  get "/users/:user_id", do: Controller.User.get(conn, user_id)
  get "/users/:user_id/rates", do: Controller.User.get_animes_in_list(conn, user_id)

  get "/episodes/:episode_id", do: Controller.Episode.get(conn, episode_id)
  post "/episodes/:episode_id/set_watched", do: Controller.Episode.set_watched(conn, episode_id)
  get "/episodes/:episode_id/videos", do: Controller.Video.get_for_episode(conn, episode_id)

  post "/auth", do: Controller.Auth.internal(conn)

  match "" do
    {:ok, version} = :application.get_key(:todonime, :vsn)
    send_resp(conn, 200, "Todonime #{List.to_string(version)}.")
  end

  match _, do: send_resp(conn, 404, "{\"message\": \"Route not found.\"}")

  def handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    case reason.__struct__ do
      Todonime.Exception.ClientException -> reason.message
      Todonime.Exception.NotFound -> reason.message
      Todonime.Exception.NotAuthorized -> reason.message
      _ -> "server error"
    end
    |> (&send_resp(conn, conn.status, Jason.encode! %{message: &1})).()
  end
end