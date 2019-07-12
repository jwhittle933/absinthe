defmodule Absinthe.Files.JPG do
  @doc """
  JPG Header: <<255, 216, 255, 224, 0, 16, 74, 70, 73, 70, 0, 1, 1, 0>>

  Base16: <<0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00 :: size(16)>>
  """

  def parse_jpg(path) do
    r_file = File.open!(path)
    r_file |> IO.binread(:line) |> Base.encode16()

    with :ok <- File.close(r_file) do
      IO.inspect(r_file)
    end
  end
end
