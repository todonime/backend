defmodule Todonime.Mapper.UserSettings do
  use Todonime.Mapper, table: "user_settings", struct: Todonime.UserSettings

  alias Todonime.Exception.{NotFound, SqlException}

  def get_by_user(user_id) do
    case Sqlitex.Server.query(:db, "SELECT * FROM user_settings WHERE user_id = #{user_id}", into: %{}) do
      {:ok, [settings]} -> {:ok, prepare(settings)}
      {:ok, []} -> :not_found
      {:error, details} -> {:error, details}
    end
  end

  def get_by_user!(user_id) do
    case get_by_user(user_id) do
      {:ok, settings} -> settings
      :not_found -> raise NotFound, message: "Settings for user ##{user_id} not found."
      {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}."
    end
  end
end