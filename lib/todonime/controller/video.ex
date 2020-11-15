defmodule Todonime.Controller.Video do
  def get_for_episode(conn, episode_id) do
    episode = Todonime.Mapper.Episode.get!(episode_id)

    Todonime.Mapper.Video.get_for_episode!(episode.anime_id, episode_id)
    |> Jason.encode!
    |> (&Plug.Conn.send_resp(conn, 200, &1)).()
  end
end