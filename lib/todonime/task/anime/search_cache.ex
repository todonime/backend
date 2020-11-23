defmodule Todonime.Task.Anime.SearchCache do
  def run do
    public = Application.fetch_env!(:todonime, :public)
    db_path = Application.fetch_env!(:todonime, :database)

    "echo \".mode csv
      SELECT id, name_en, name_ru FROM animes;\" | sqlite3 '#{db_path}' > '#{public}/anime/search.csv'"
    |> String.to_charlist
    |> :os.cmd

    :ok
  end
end