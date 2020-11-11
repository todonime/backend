defmodule Todonime.Genre do
  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :name
  ]
end