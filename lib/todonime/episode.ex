defmodule Todonime.Episode do
  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :number,
    :anime_id,
    :name,
    watched: false
  ]

  def apply_rate(
    %__MODULE__{anime_id: etalon_anime_id, number: current} = episode,
    %Todonime.Rate{anime_id: rate_anime_id, episodes: watched}
  ) do
    if etalon_anime_id != rate_anime_id do
      raise ArgumentError, message: "This rate for other anime."
    end
    %{episode | watched: current <= watched}
  end

  def get_arch(%__MODULE__{anime_id: anime_id, number: number}) do
    Todonime.Mapper.Arch.get_by_episode(anime_id, number)
  end

  def get_arch!(%__MODULE__{anime_id: anime_id, number: number}) do
    Todonime.Mapper.Arch.get_by_episode!(anime_id, number)
  end
end