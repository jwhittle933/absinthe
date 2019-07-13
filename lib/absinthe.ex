defmodule Absinthe do
  @moduledoc """
  Documentation for Absinthe

  Entry point for application
  """

  alias Absinthe.CLI
  alias Absinthe.Files

  @doc """
  Absinthe Main
  """
  def main(args) do
    opts = CLI.parse(args)
    Files.get_file_list(opts) |> Files.parse_files(opts)

    IO.inspect(opts)
  end
end
