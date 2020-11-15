defmodule Todonime.Mapper.Video do
  use Todonime.Mapper, table: "Videos", struct: Todonime.Video

  alias Todonime.Exception.{NotFound, SqlException}

  def get_for_episode(anime_id, episode_id) do
    case Sqlitex.Server.query(:db, "
      SELECT videos.*, vendors.template FROM videos
      LEFT JOIN vendors ON vendors.id = videos.vendor_id
      WHERE videos.episode_id = #{episode_id} AND anime_id = #{anime_id}
    ", into: %{})
    do
      {:ok, videos} -> 
        Enum.map(videos, fn video ->
          Map.put(video, :url, create_url(video.template, video.video_id))
          |> Map.delete(:template)
          |> prepare()
        end)
        |> (&{:ok, &1}).()
      {:error, details} -> {:error, details}
    end
  end

  def get_for_episode!(anime_id, episode_id) do
    case get_for_episode(anime_id, episode_id) do
      {:ok, videos} -> videos
      {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}" 
    end
  end

  def get_with_url(id) do
    case Sqlitex.Server.query(:db, "
      SELECT videos.*, vendors.template FROM videos 
      LEFT JOIN vendors ON vendors.id = videos.vendor_id 
      WHERE videos.id = #{id}
    ", into: %{}) do
      {:ok, [video]} -> 
        Map.put(video, :url, create_url(video.template, video.video_id))
        |> Map.delete(:template)
        |> prepare()
        |> (&{:ok, &1}).()
      {:ok, []} -> :not_found
      {:error, details} -> {:error, details}
    end
  end

  defp create_url(template, id) when is_binary(id), do: String.replace(template, "%id", id)
  defp create_url(template, id) when is_integer(id), do: String.replace(template, "%id", Integer.to_string(id))

  def get_with_url!(id) do
    case get_with_url(id) do
      {:ok, video} -> video
      :not_found -> raise NotFound, message: "Video ##{id} not found."
      {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}" 
    end
  end

  def prepare(video) do
    struct(Todonime.Video, video)
    |> Map.put(:kind, Map.get(%{nil => nil, 0 => "dub", 1 => "sub"}, Map.get(video, :kind)))
    |> Map.put(:lang, Map.get(%{nil => nil, 0 => "ru", 1 => "en"}, Map.get(video, :lang)))
  end
end