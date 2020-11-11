defmodule Todonime.Mapper.User do
  use Todonime.Mapper,
    table: "users"

  def verify_and_get(name, hash) do
    case get_by_name(name) do
      {:ok, user} -> (if user.hash != hash, do: :invalid, else: {:ok, user})
      {:error, :not_found} -> :invalid
      {:error, {_, details}} -> raise Todonime.Exception.SqlException, message: "SQLException: #{details}"
    end
  end

  def get_by_name(name) do
    case Sqlitex.Server.query(:db, "SELECT * FROM users WHERE name = ?", bind: [name], into: %{}) do
      {:ok, [user]} -> {:ok, prepare(user)}
      {:ok, []} -> {:error, :not_found}
      {:error, details} -> {:error, details}
    end
  end

  def get_by_name!(name) do
    case get_by_name(name) do
      {:ok, user} -> user
      {:error, :not_found} -> raise Todonime.Exception.NotFound, message: "user #{name} not found."
      {:error, {_, message}} -> raise Todonime.Exception.SqlException, message: "SQLException: #{message}."
    end
  end

  defp prepare(user), do:
    struct(Todonime.User, user)
    |> (&%{&1 | avatar: Todonime.User.avatar_url(&1)}).()
end