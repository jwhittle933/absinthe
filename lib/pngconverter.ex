defmodule Pngconverter do
  @moduledoc """
  Documentation for Pngconverter.
  """

  alias Pngconverter.CLI

  @doc """
  Hello world.

  ## Examples

      iex> Pngconverter.hello()
      :world
  """
  def main(args) do
    opts = CLI.parse(args)
    IO.inspect(opts)
    get_files(opts)
  end

  defp get_files(opts) do
    [path: path, ext: ext] = opts
    wc = "#{path}*#{ext}"
    IO.puts(wc)
    files = Path.wildcard(wc)
    IO.inspect(files)
  end
end
