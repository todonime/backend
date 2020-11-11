defmodule Todonime.Mapper.Episode do
  use Todonime.Mapper,
    table: "episodes",
    struct: Todonime.Episode

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