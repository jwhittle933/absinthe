defmodule Absinthe.Files do
  def parse_files(files) do
    with true <- Enum.count(files) > 0 do
      Enum.each(files, fn file ->
        {:ok, info} = File.stat(file)
        IO.inspect(info)
      end)
    else
      false -> IO.puts("No files")
    end
  end

  def get_files(opts) do
    [path: path, ext: ext] = opts
    Path.wildcard("#{path}*#{ext}")
  end
end
