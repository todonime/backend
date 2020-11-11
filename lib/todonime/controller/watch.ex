defmodule Todonime.Controller.Watch do
  alias Todonime.Mapper
  alias Todonime.Exception.SqlException
  alias Todonime.{User, Video, Rate, Anime, Episode}
  import Plug.Conn, only: [send_resp: 3]
  
  def get(conn, video_id) do
    video = Mapper.Video.get_with_url!(video_id)
    anime = Video.get_anime!(video) |> Todonime.Anime.with_genres!()
    episode = Video.get_episode!(video)
    arch = 
      case Episode.get_arch(episode) do
        {:ok, arch} -> arch
        :not_found -> nil
        {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}"
      end

    user = Guardian.Plug.current_resource(conn)
    user = (if user != nil, do: Todonime.User.with_settings!(user), else: nil)
    rate = (if user != nil, do: Todonime.User.rate_for!(user, anime), else: nil)

    anime = (if rate != nil, do: Todonime.Anime.apply_rate(anime, rate), else: anime)
    episode = (if rate != nil, do: Todonime.Episode.apply_rate(episode, rate), else: episode)

    %{
      anime: anime,
      episode: episode,
      arch: arch,
      video: video,
      suggest: %{
        prev: nil,
        nex: nil
      },
      rate: rate,
      user: user
    }
    |> Jason.encode!
    |> (&send_resp(conn, 200, &1)).()
  end
end