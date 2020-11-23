defmodule Todonime.Mapper.Anime do
  use Todonime.Mapper, table: "animes"

  def list(opts \\ [page: 1, size: 1]) do
    size = case Keyword.get(opts, :size) do
      size when is_binary(size) -> String.to_integer(size)
      size when is_integer(size) -> size
    end
    page = case Keyword.get(opts, :page) do
      page when is_binary(page) -> String.to_integer(page)
      page when is_integer(page) -> page
    end

    limit = if size != nil do
      "LIMIT #{size} OFFSET #{size * (page - 1)}"
    else
      ""
    end

    case Sqlitex.Server.query(:db, "SELECT * FROM animes #{limit}") do
      {:ok, animes} -> 
        animes = Enum.map(animes, fn anime ->
          anime
          |> prepare
          |> Todonime.Anime.with_genres!
        end)
        {:ok, animes}
      {:error, details} -> {:error, details}
    end
  end

  def list!(opts \\ [page: 1, size: nil]) do
    case list(opts) do
      {:ok, animes} -> animes
      {:error, {_, message}} -> raise Todonime.Exception.SqlException, message: "SQLException: #{message}"
    end
  end

  def get_for_user(user_id, opts \\ [page: 1, size: nil]) do
    size = case Keyword.get(opts, :size) do
      size when is_binary(size) -> String.to_integer(size)
      size when is_integer(size) -> size
    end
    page = case Keyword.get(opts, :page) do
      page when is_binary(page) -> String.to_integer(page)
      page when is_integer(page) -> page
    end

    limit = if size != nil do
      "LIMIT #{size} OFFSET #{size * (page - 1)}"
    else
      ""
    end
    case Sqlitex.Server.query(:db,
      "SELECT
        animes.*,
        rates.id AS rate_id,
        rates.anime_id AS rate_anime_id,
        rates.user_id AS rate_user_id,
        rates.episodes AS rate_episodes,
        rates.type AS rate_type,
        rates.created_at AS rate_created_at,
        rates.updated_at AS rate_updated_at
      FROM rates
      JOIN animes ON animes.id = rates.anime_id
      WHERE rates.user_id = #{user_id}
      ORDER BY updated_at DESC
      #{limit}",
      into: %{}
    ) do
      {:ok, animes} -> 
        Enum.map(animes, fn anime_and_rate ->
          rate = %Todonime.Rate{
            id: anime_and_rate.rate_id,
            anime_id: anime_and_rate.rate_anime_id,
            user_id: anime_and_rate.rate_user_id,
            type: anime_and_rate.rate_type,
            episodes: anime_and_rate.rate_episodes,
            created_at: anime_and_rate.rate_created_at,
            updated_at: anime_and_rate.rate_updated_at
          }

          Map.take(anime_and_rate, [
            :id,
            :shikimori_id,
            :sr_id,
            :name_en,
            :name_ru,
            :last_episode,
            :status,
            :kind,
            :main_genre,
            :age_rating,
            :rating,
            :poster
          ])
          |> prepare()
          |> Todonime.Anime.with_genres!
          |> Todonime.Anime.apply_rate(rate)
          |> (&%{&1 | rate: rate}).()
        end)
        |> (&{:ok, &1}).()
      {:error, details} -> {:error, details}
    end
  end

  def get_for_user!(user_id, opts) do
    case get_for_user(user_id, opts) do
      {:ok, animes} -> animes
      {:error, {_, message}} -> raise Todonime.Exception.SqlException, message: "SQLException: #{message}"
    end
  end

  defp prepare(anime), do:
    struct(Todonime.Anime, anime)
    |> (&Map.put(&1, :rating, (if &1.rating != nil, do: &1.rating / 100, else: nil))).()
    |> (&Map.put(&1, :poster, Todonime.Anime.poster_url(&1))).()
end