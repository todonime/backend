defmodule Todonime.User do
  @derive {Jason.Encoder, except: [:hash, :scopes]}
  @derive {Inspect, only: [:hash, :scopes]}
  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :hash,
    :sex,
    :avatar,
    :scopes,
    :last_active,
    :created_at,
    settings: nil
  ]

  alias Todonime.Exception.SqlException

  def store_avatar(%__MODULE__{id: id}, source), do: 
    Storage.put(source, ["user", id], filename: "avatar")

  def avatar_url(%__MODULE__{id: id}) do
    root = Application.fetch_env!(:todonime, :public)
    Storage.url("#{root}/user/#{id}/avatar")
  end

  def get_rates!(%__MODULE__{id: id}) do
    Todonime.Mapper.Rate.get_for_user!(id)
  end

  def rate_for!(%__MODULE__{id: id}, %Todonime.Anime{id: anime_id}) do
    case Todonime.Mapper.Rate.get_for_user(id, anime_id) do
      {:ok, rate} -> rate
      :not_found -> nil
      {:error, {_, message}} -> raise SqlException, message: "SQLException: #{message}"
    end
  end

  def get_settings!(%__MODULE__{id: id}) do
    Todonime.Mapper.UserSettings.get_by_user!(id)
  end

  def with_settings!(user) do
    %{user | settings: get_settings!(user)}
  end
end