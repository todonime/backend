defmodule Todonime.Mapper.Arch do
  use Todonime.Mapper, table: "arches", struct: Todonime.Arch

  alias Todonime.Exception.{NotFound, SqlException}

  def get_by_episode(anime_id, episode_number) do
    case Sqlitex.Server.query(:db, 
      "SELECT * FROM arches 
      WHERE anime_id = #{anime_id} 
        AND (start <= #{episode_number} AND end >= #{episode_number})", into: %{}
    ) do
      {:ok, [arch]} -> {:ok, prepare(arch)}
      {:ok, []} -> :not_found
      {:error, details} -> {:error, details}
    end
  end

  def get_by_episode!(anime_id, episode_number) do
    case get_by_episode(anime_id, episode_number) do
      {:ok, arch} -> arch
      :not_found -> raise NotFound, message: "Arch for episode #{episode_number} not found."
      {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}"
    end
  end
end