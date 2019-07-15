defmodule Absinthe.Files.PNG do
  alias __MODULE__

  @moduledoc """
  <<0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A>> are the first 8 bytes in the PNG signature
  """

  defstruct [:width, :height, :bit_depth, :color_type, :compression, :filter, :interlace, :chunks]

  def decode(
        <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, length::size(32), "IHDR",
          width::size(32), height::size(32), bit_depth, color_type, compression_method,
          filter_method, interlace_method, crc::size(32), chunks::binary>>
      ) do
    png = %PNG{
      width: width,
      height: height,
      bit_depth: bit_depth,
      color_type: color_type,
      compression: compression_method,
      filter: filter_method,
      interlace: interlace_method,
      chunks: []
    }

    decode_chunks(chunks, png)
  end

  defp decode_chunks(
         <<length::size(32), chunk_type::size(32), chunk_data::binary-size(length), crc::size(32),
           chunks::binary>>,
         png
       ) do
    chunk = %{length: length, chunk_type: chunk_type, data: chunk_data, crc: crc}
    png = %{png | chunks: [chunk | png.chunks]}

    parse_png_chunks(chunks, png)
  end

  defp decode_chunks(<<>>, png) do
    %{png | chunks: Enum.reverse(png.chunks)}
  end

  def png_header(), do: <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
end
