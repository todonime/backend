defmodule Todonime.Controller.User do
  def get_animes_in_list(conn, user_id) do
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

    Todonime.Mapper.Anime.get_for_user!(user_id, size: size, page: page)
    |> Jason.encode!
    |> (&Plug.Conn.send_resp(conn, 200, &1)).()
  end

  def get(conn, user_id) do
    Todonime.Mapper.User.get!(user_id)
    |> Todonime.User.with_settings!
    |> Jason.encode!
    |> (&Plug.Conn.send_resp(conn, 200, &1)).()
  end
end