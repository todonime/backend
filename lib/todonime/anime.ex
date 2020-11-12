defmodule Todonime.Anime do
  @derive Jason.Encoder
  @enforce_keys [:id, :shikimori_id, :name_en]
  defstruct [
    :id,
    :shikimori_id,
    :sr_id,
    :poster,
    :name_en,
    :name_ru,
    :last_episode,
    :status,
    :kind,
    :main_genre,
    :age_rating,
    :rating,
    :rate,
    genres: [],
    watched: false,
  ]

  def poster_url(%__MODULE__{id: id}) do
    root = Application.fetch_env!(:todonime, :public)
    Storage.url("#{root}/anime/#{id}/poster/original")
  end

  def apply_rate(%__MODULE__{id: id} = anime, %Todonime.Rate{anime_id: anime_id, type: type}) do
    if id != anime_id do
      raise ArgumentError, message: "This rate for other anime."
    end
    %{anime | watched: type in ["completed", "rewatching"]}
  end

  def get_episodes!(%__MODULE__{id: id}) do
    Todonime.Mapper.Episode.get_for_anime!(id)
  end

  def get_genres!(%__MODULE__{id: id}) do
    Todonime.Mapper.Genre.get_by_anime!(id)
  end

  def with_genres!(anime) do
    %{anime | genres: get_genres!(anime)}
  end
end