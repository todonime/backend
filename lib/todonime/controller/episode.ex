defmodule Todonime.Controller.Episode do
  def set_watched(conn, episode_id) do
    episode = Todonime.Mapper.Episode.get!(episode_id)
    anime = Todonime.Mapper.Anime.get!(episode.anime_id)

    user = Guardian.Plug.current_resource(conn)
    if user == nil do
      raise Todonime.Exception.NotAuthorized, message: "Not auth."
    end
    rate = Todonime.User.rate_for!(user, anime)

    if rate == nil do
      Todonime.Mapper.Rate.create!(%{
        anime_id: anime.id,
        user_id: user.id,
        episodes: episode.number,
        type: "watching"
      })
    else
      Todonime.Mapper.Rate.update_by_id!(rate.id, %{episodes: episode.number})
      %{rate | episodes: episode.number}
    end
    |> Jason.encode!
    |> (&Plug.Conn.send_resp(conn, 200, &1)).()
  end

  def get(conn, episode_id) do
    episode = Todonime.Mapper.Episode.get!(episode_id)
    anime = Todonime.Mapper.Anime.get!(episode.anime_id)

    user = Guardian.Plug.current_resource(conn)
    rate = (if user != nil, do: Todonime.User.rate_for!(user, anime))

    Todonime.Mapper.Episode.get!(episode_id)
    |> (&(if rate != nil, do: Todonime.Episode.apply_rate(&1, rate), else: &1)).()
    |> Jason.encode!
    |> (&Plug.Conn.send_resp(conn, 200, &1)).()
  end

  def get_for_anime_by_number(conn, anime_id, number) do
    anime = Todonime.Mapper.Anime.get!(anime_id)

    user = Guardian.Plug.current_resource(conn)
    rate = (if user != nil, do: Todonime.User.rate_for!(user, anime))

    Todonime.Mapper.Episode.get_by_number!(anime_id, number)
    |> (&(if rate != nil, do: Todonime.Episode.apply_rate(&1, rate), else: &1)).()
    |> Jason.encode!
    |> (&Plug.Conn.send_resp(conn, 200, &1)).()
  end

  def get_for_anime(conn, anime_id) do
    anime = Todonime.Mapper.Anime.get!(anime_id)

    user = Guardian.Plug.current_resource(conn)
    rate = (if user != nil, do: Todonime.User.rate_for!(user, anime))

    Todonime.Mapper.Episode.get_for_anime!(anime_id)
    |> Enum.map(&(if rate != nil, do: Todonime.Episode.apply_rate(&1, rate), else: &1))
    |> Jason.encode!
    |> (&Plug.Conn.send_resp(conn, 200, &1)).()
  end
end