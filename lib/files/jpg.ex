defmodule Absinthe.Files.JPG do
  alias __MODULE__

  @moduledoc """
  Reference: http://www.fileformat.info/format/jpeg/egff.htm

  JPG Header: <<255, 216, 255, 224, 0, 16, 74, 70, 73, 70, 0, 1, 1, 0>>

  Base16: <<0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00 :: size(16)>>
  Trailer: <<0xFF, 0xD9>>

  The actual JPEG data file follows all APP0 markers.

  To identify a JFIF file or data stream, scan for the values 0xFF 0xD8 0xFF. This will identify the SOI marker,
  followed by another marker. In a proper JFIF file, the next byte will be 0xE0, indicating a JFIF APP0 marker
  segment. It is possible that one or more other marker segments may be erroneously written between the SOI and
  JFIF APP0 markers. The next two bytes (the APP0 segment length) vary in value, but are typically 0x00 0x10,
  and these are followed by the five byte 0x4A 0x46 0x49 0x46 0x00. If these values are found, the SOI marker
  (0xFF 0xD8) marks the beginning of the JFIF data strean. If only 0xFF 0xD8 0xFF values are found, but not the
  remaining data, then a "raw" JPEG data stream has been found. All JPEG and JFIF data streams end with EOI
  (end of image) marker values 0xFF 0xD9.

  There are many proprietary image file formats which contain JPEG data. Scanning for the JPEG SOI and reading
  until the EOI marker will usually allow you to extract the JPEG/JFIF data stream.
  """

  @doc """
  SOI is is the start of the image, always FF D8

  APP0 is the application marker, always FF E0

  Length is the size of the JFIF (APP0) segment, including the length field itself and any thumbnail data contained
  in the APP0 segment. The value of Length = 16 + 3 * XThumbnail * YThumbnail

  Identifier contains the values 4A 46 49 46 00 (JFIF)

  Version id's the version of JFIF spec, with the first byte containing the major revision number, the second
  containing the minor revision number.

  Units, Xdensity, and Ydensity id the unit of measurement used to describe the image res. 0x01 for dots / inch,
  0x02 for dots / centimeter, 0x00 for none.

  Xdensity and Ydensity are the horizontal and vertical resolution of the image data. If Units is 0x00, the Xdensity
  and Ydensity fields will contain the pixes aspect ratio (Xdensity:Ydensity).

  XThumbnail and YThumbnail give the dimensions of the thumbnail image included in the JFIF APP0 marker. If no thumbnail
  image is included in the marker, these fields contain 0. The thumbnail data itself consists of an array of
  XThumbnail * YThumbnail pixel values, where each pixel occupies 3 bytes and contians 24-bit RGB value (stored in the order
  R, G, B). No compression is performed on the thumbnail.

  """
  defstruct [
    :soi,
    :app0,
    :length,
    :identifier,
    :version,
    :units,
    :xdensity,
    :ydensity,
    :xthumbnail,
    :ythumbnail
  ]

  def read_jpg(path) do
    r_file = File.open!(path)
    r_file |> IO.binread(:line) |> Base.encode16()

    with :ok <- File.close(r_file) do
      IO.inspect(r_file)
    end
  end

  def parse_jpg(
        <<soi::size(16), app0::size(16), length::size(16), id::size(40), version::size(16), units,
          xdensity, ydensity, xthumb, ythumb, rest::binary>> = file
      ) do
    IO.puts("Found JFIF data stream")

    IO.inspect(soi, label: "soi")
    IO.inspect(app0, label: "app0")
    IO.inspect(length, label: "length")
    IO.inspect(id, label: "id")
    IO.inspect(version, label: "version")
    IO.inspect(units, label: "units")
    IO.inspect(xdensity, label: "xdensity")
    IO.inspect(ydensity, label: "ydensity")
    IO.inspect(xthumb, label: "xthumb")
    IO.inspect(ythumb, label: "ythumb")
    IO.inspect(rest, label: "rest")
  end

  def parse_jpg(<<soi::size(16), app0::size(16)>>) do
  end

  def is_jpg?(<<0xFF, 0xD8>>), do: true
  def is_jpg?(<<>>), do: false

  def is_raw?(
        <<0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00,
          _rest::binary>>
      ),
      do: false

  def is_raw?(<<>>), do: true
end
