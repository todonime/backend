defmodule Todonime.Controller.Anime do
  def list(conn) do
    params = conn
    |> Plug.Conn.fetch_query_params
    |> (&(&1.query_params)).()

    size = case Map.fetch(params, "size") do
      {:ok, size} -> size
      :error -> 100
    end
    page = case Map.fetch(params, "page") do
      {:ok, page} -> page
      :error -> 1
    end

    Todonime.Mapper.Anime.list!(size: size, page: page)
    |> Enum.map(&maybe_apply_rate(&1, conn))
    |> Jason.encode!
    |> (&Plug.Conn.send_resp(conn, 200, &1)).()
  end

  def get(conn, anime_id) do
    Todonime.Mapper.Anime.get!(anime_id)
    |> Todonime.Anime.with_genres!
    |> maybe_apply_rate(conn)
    |> Jason.encode!
    |> (&Plug.Conn.send_resp(conn, 200, &1)).()
  end

  defp maybe_apply_rate(anime, conn) do
    with user when not is_nil(user) <- Guardian.Plug.current_resource(conn),
         rate when not is_nil(rate) <- Todonime.User.rate_for!(user, anime),
    do: Todonime.Anime.apply_rate(anime, rate) 
        |> (&%{&1 | rate: rate}).(),
    else: (_ -> anime)
  end
end