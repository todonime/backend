defmodule Todonime.Mapper.Genre do
  use Todonime.Mapper, table: "genres", struct: Todonime.Genre

  alias Todonime.Exception.SqlException

  def get_by_anime(anime_id) do
    case Sqlitex.Server.query(:db, 
      "SELECT genres.* FROM anime_genres
      JOIN genres ON genres.id = anime_genres.genre_id 
      WHERE anime_genres.anime_id = #{anime_id}", into: %{}
    ) do
      {:ok, genres} -> {:ok, Enum.map(genres, &prepare(&1))}
      {:error, details} -> {:error, details}
    end
  end

  def get_by_anime!(anime_id) do
    case get_by_anime(anime_id) do
      {:ok, genres} -> genres
      {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}"
    end
  end

  def link_with_anime(anime_id, genre_id) do
    case Sqlitex.Server.query(:db, 
      "INSERT INTO anime_genres(anime_id, genre_id) 
      VALUES(?,?)",
      bind: [anime_id, genre_id]
    ) do
      {:ok, _} -> :ok
      {:error, details} -> {:error, details}
    end
  end
end