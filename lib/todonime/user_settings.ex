defmodule Todonime.UserSettings do
  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :user_id,
    :preferred_video_kind
  ]
end