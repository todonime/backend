defmodule Todonime.Rate do
  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :anime_id,
    :user_id,
    :type,
    :episodes,
    :created_at,
    :updated_at
  ]
end