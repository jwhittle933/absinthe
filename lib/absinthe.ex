defmodule Absinthe do
  @moduledoc """
  Documentation for Pngconverter.
  """

  alias Absinthe.CLI
  alias Absinthe.Files

  @doc """
  Hello world.

  ## Examples

      iex> Pngconverter.hello()
      :world
  """
  def main(args) do
    opts = CLI.parse(args)
    IO.inspect(opts)
    files = Files.get_files(opts)
    IO.inspect(files)
  end
end
