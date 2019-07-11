defmodule Absinthe do
  @moduledoc """
  Documentation for Pngconverter.
  """

  alias Absinthe.CLI

  @doc """
  Hello world.

  ## Examples

      iex> Pngconverter.hello()
      :world
  """
  def main(args) do
    opts = CLI.parse(args)
    IO.inspect(opts)
    files = get_files(opts)
    IO.inspect(files)
  end

  defp get_files(opts) do
    [path: path, ext: ext] = opts
    Path.wildcard("#{path}*#{ext}")
  end
end
