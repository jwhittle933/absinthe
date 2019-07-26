defmodule Metallurgy.PNG do
  alias __MODULE__
  alias Metallurgy.PNG.Helpers
  alias Metallurgy.Files

  @moduledoc """
  Reference: http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html
  Reference: http://erlang.org/doc/man/zlib.html
  <<0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A>> are the first 8 bytes in the PNG signature

  chunk types:
  0: Each pixel is a grayscale sample.
  2: Each pixel is an R,G,B triple.
  3: Each pixel is a palette index; a PLTE chunk must appear.
  4: Each pixel is a grayscale sample, followed by an alpha sample.
  6: Each pixel is an R,G,B triple, followed by an alpha sample.

  A valid PNG image must contain an IHDR chunk, one or more IDAT chunks, and an IEND chunk.

  The IDAT chunk contains the actual image data.
  The IEND chunk must appear LAST. It marks the end of the PNG datastream. The chunk's data field is empty.
  """

  @png_signature <<137::size(8), ?P, ?N, ?G, 13::size(8), 10::size(8), 26::size(8), 10::size(8)>>

  # Required
  @ihdr <<?I, ?H, ?D, ?R>>
  @plte <<?P, ?L, ?T, ?E>>
  @idat <<?I, ?D, ?A, ?T>>
  @iend <<?I, ?E, ?N, ?D>>
  # Ancilliary
  @bkgd <<?b, ?K, ?G, ?D>>
  @phys <<?p, ?H, ?Y, ?s>>
  @sbit <<?s, ?B, ?I, ?T>>
  @itxt <<?i, ?T, ?X, ?t>>
  @text <<?t, ?E, ?X, ?t>>
  @gama <<?g, ?A, ?M, ?A>>
  @time <<?t, ?I, ?M, ?E>>
  @trns <<?t, ?R, ?N, ?S>>
  @req_headers [@ihdr, @plte, @idat, @iend]
  @anc_headers [@bkgd, @phys, @sbit, @itxt, @text, @gama, @time, @trns]

  defstruct [
    :name,
    :width,
    :height,
    :bit_depth,
    :color_type,
    :compression,
    :filter,
    :interlace,
    :chunks,
    :idat,
    :bytes_per_row
  ]

  def decode(
        <<@png_signature, length::size(32), "IHDR", width::size(32), height::size(32), bit_depth,
          color_type, compression_method, filter_method, interlace_method, crc::size(32),
          chunks::binary>>,
        file_path
      ) do
    png = %PNG{
      name: file_path |> Files.file_name(),
      width: width,
      height: height,
      bit_depth: bit_depth,
      color_type: Helpers.color_format(color_type),
      bytes_per_row: Helpers.bytes_per_row(Helpers.color_format(color_type), bit_depth, width),
      compression: compression_method,
      filter: filter_method,
      interlace: interlace_method,
      chunks: []
    }

    decode_chunks(png, chunks)
  end

  def decode(<<_::binary>>, _file_path), do: {:error, "Not a png"}

  defp decode_chunks(
         png,
         <<length::size(32), chunk_type::binary-size(4), chunk_data::binary-size(length),
           crc::binary-size(4), chunks::binary>>
       )
       when chunk_type in @anc_headers do
    chunk = %{
      length: length,
      chunk_type: chunk_type,
      data: Helpers.show_text(chunk_data),
      crc: crc,
      text_type: Helpers.text_type(chunk_data)
    }

    %PNG{png | chunks: [chunk | png.chunks]}
    |> decode_chunks(chunks)
  end

  defp decode_chunks(
         png,
         <<length::size(32), @idat, chunk_data::binary-size(length), crc::binary-size(4),
           chunks::binary>>
       ) do
    chunk = %{length: length, chunk_type: "IDAT", data: chunk_data, crc: crc}

    %PNG{png | chunks: [chunk | png.chunks]}
    |> append_idat(chunk)
    |> decode_chunks(chunks)
  end

  defp decode_chunks(
         png,
         <<length::size(32), chunk_type::binary-size(4), chunk_data::binary-size(length),
           crc::binary-size(4), chunks::binary>>
       ) do
    chunk = %{length: length, chunk_type: chunk_type, data: chunk_data, crc: crc}

    %PNG{png | chunks: [chunk | png.chunks]}
    |> decode_chunks(chunks)
  end

  defp decode_chunks(png, <<>>) do
    %{png | chunks: Enum.reverse(png.chunks)}
  end

  def png_header(), do: <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>

  def decompress(%PNG{idat: idat} = png) do
    zlib_stream = :zlib.open()
    :ok = :zlib.inflateInit(zlib_stream)

    decompress =
      zlib_stream
      |> :zlib.inflate(idat)
      |> IO.iodata_to_binary()

    :ok = :zlib.inflateEnd(zlib_stream)
    :ok = :zlib.close(zlib_stream)

    %PNG{png | idat: decompress}
  end

  def compress(%PNG{idat: idat} = png) do
    zlib_stream = :zlib.open()
    :ok = :zlib.deflateInit(zlib_stream)

    compressed =
      zlib_stream
      |> :zlib.deflate(idat, :finish)

    :ok = :zlib.deflateEnd(zlib_stream)
    :ok = :zlib.close(zlib_stream)

    %PNG{png | idat: :binary.list_to_bin(compressed)}
  end

  defp append_idat(%PNG{idat: nil} = png, %{data: data}), do: %PNG{png | idat: data}
  defp append_idat(%PNG{idat: _} = png, %{data: <<0>>}), do: png
  defp append_idat(%PNG{idat: idat} = png, %{data: data}), do: %PNG{png | idat: idat <> data}
end
