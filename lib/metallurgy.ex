defmodule Metallurgy do
  @moduledoc """
  Documentation for Metallurgy

  Entry point for application
  """

  alias Metallurgy.CLI
  alias Metallurgy.Files
  alias Metallurgy.PNG

  @doc """
  Metallurgy Main
  """
  def main(args) do
    opts = CLI.parse(args)
    files = opts |> Files.get_file_list()
    # files |> List.first() |> Files.show_binary() |> IO.inspect()
    Enum.each(files, &Files.show_binary/1)
    # files |> Files.parse_files(opts) |> IO.inspect
  end
end
