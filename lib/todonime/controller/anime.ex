defmodule Todonime.Controller.Anime do
  def get(conn, anime_id) do
    anime = Todonime.Mapper.Anime.get!(anime_id)
    user = Guardian.Plug.current_resource(conn)
    rate = (if user != nil, do: Todonime.User.rate_for!(user, anime))

    Todonime.Mapper.Anime.get!(anime_id)
    |> Todonime.Anime.with_genres!
    |> (&(if rate != nil, do: Todonime.Anime.apply_rate(&1, rate), else: &1)).()
    |> Jason.encode!
    |> (&Plug.Conn.send_resp(conn, 200, &1)).()
  end
end