defmodule Todonime.Task.Backup do
  require Logger

  def run do
    backups = "#{Application.fetch_env!(:todonime, :storage)}/backups"
    db_path = Application.fetch_env!(:todonime, :database)

    cdate = Timex.local
    cmd = "sqlite3 '#{db_path}' .dump | gzip > '#{backups}/#{cdate.year}-#{cdate.month}-#{cdate.day}.sql.gz'"

    Logger.info "[BACKUP] #{cmd}"
    
    :os.cmd(String.to_charlist(cmd))

    :ok
  end

  defp clean_old!(path) do
    File.ls!(path)
    |> Enum.filter(fn file ->
      %File.Stat{ctime: {{year, month, day}, _}} = File.stat! "#{path}/#{file}"
      case Date.new(year, month, day) do
        {:ok, cdate} -> Date.diff(cdate, Date.utc_today) > 30
        err -> raise "Invalid date."
      end
    end)
    |> Enum.map(fn filename ->
      File.rm!("#{path}/#{filename}")
      "#{path}/#{filename}"
    end)
  end
end