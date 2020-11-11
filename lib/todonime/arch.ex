defmodule Todonime.Arch do
  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :anime_id,
    :name,
    :start,
    :end,
    :type
  ]
end