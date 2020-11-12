defmodule Todonime.Mapper.Rate do
  use Todonime.Mapper, table: "rates", struct: Todonime.Rate

  alias Todonime.Exception.SqlException

  def get_for_user(id) do
    case Sqlitex.Server.query(:db, "SELECT * FROM rates WHERE user_id = #{id}", into: %{}) do
      {:ok, rates} -> {:ok, Enum.map(rates, &prepare(&1))}
      {:error, details} -> {:error, details}
    end
  end
  def get_for_user(id, anime_id) do
    case Sqlitex.Server.query(:db, "SELECT * FROM rates WHERE user_id = #{id} AND anime_id = #{anime_id}", into: %{}) do
      {:ok, [rate]} -> {:ok, prepare(rate)}
      {:ok, []} -> :not_found
      {:error, details} -> {:error, details}
    end
  end

  def get_for_user!(id) do
    case get_for_user(id) do
      {:ok, rates} -> rates
      {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}"
    end
  end
  def get_for_user!(id, anime_id) do
    case get_for_user(id, anime_id) do
      {:ok, rate} -> rate
      :not_found -> raise Todonime.Exception.NotFound, message: "User ##{id} not have rate for anime ##{anime_id}."
      {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}"
    end
  end
end