defmodule Todonime.Mapper.Episode do
  use Todonime.Mapper,
    table: "episodes",
    struct: Todonime.Episode

  def get_by_number(anime_id, number) do
    case Sqlitex.Server.query(:db, "SELECT * FROM episodes WHERE anime_id = #{anime_id} AND number = #{number}", into: %{}) do
      {:ok, [episode]} -> {:ok, prepare(episode)}
      {:ok, []} -> :not_found
      {:error, details} -> {:error, details}
    end
  end

  def get_by_number!(anime_id, number) do
    case get_by_number(anime_id, number) do
      {:ok, episode} -> episode
      :not_found -> raise Todonime.Exception.NotFound, message: "Episode ##{number} not found."
      {:error, {_, message}} -> raise Todonime.Exception.SqlException, message: "SqlException: #{message}"
    end
  end

  def get_for_anime(anime_id) do
    case Sqlitex.Server.query(:db, "SELECT * FROM episodes WHERE anime_id = #{anime_id} ORDER BY number ASC", into: %{}) do
      {:ok, episodes} -> {:ok, Enum.map(episodes, &prepare(&1))}
      {:error, details} -> {:error, details}
    end
  end

  def get_for_anime!(anime_id) do
    case get_for_anime(anime_id) do
      {:ok, episodes} -> episodes
      {:error, {_, message}} -> raise Todonime.Exception.SqlException, message: "SQLException: #{message}"
    end
  end
end