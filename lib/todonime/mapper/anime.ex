defmodule Todonime.Mapper.Anime do
  use Todonime.Mapper, table: "animes"

  defp prepare(anime), do:
    struct(Todonime.Anime, anime)
    |> (&Map.put(&1, :rating, (if &1.rating != nil, do: &1.rating / 100, else: nil))).()
    |> (&Map.put(&1, :poster, Todonime.Anime.poster_url(&1))).()
end