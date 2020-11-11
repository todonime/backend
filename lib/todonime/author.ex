defmodule Todonime.Author do
  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :regex
  ]
end