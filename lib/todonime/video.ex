defmodule Todonime.Video do
  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :vendor_id,
    :anime_id,
    :episode_id,
    :video_id,
    :author_id,
    :uploader_id,
    :kind,
    :lang,
    :url
  ]

  def get_anime!(%__MODULE__{anime_id: anime_id}) do
    Todonime.Mapper.Anime.get!(anime_id)
  end

  def get_uploader!(%__MODULE__{uploader_id: nil}), do: nil
  def get_uploader!(%__MODULE__{uploader_id: uploader_id}) do
    Todonime.Mapper.User.get!(uploader_id)
  end

  def get_episode!(%__MODULE__{episode_id: episode_id}) do
    Todonime.Mapper.Episode.get!(episode_id)
  end
end