defmodule Todonime.Vendor do
  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :domain,
    :template,
    :last_episode_id,
  ]
end