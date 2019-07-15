defmodule Absinthe.JPG do
  alias __MODULE__
  use Absinthe.JPG.Context

  @moduledoc """
  Reference: http://www.fileformat.info/format/jpeg/egff.htm
  Reference: https://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/JPEG.html
  Reference: https://www.impulseadventure.com/photo/jpeg-huffman-coding.html

  JPG Header: <<255, 216, 255, 224, 0, 16, 74, 70, 73, 70, 0, 1, 1, 0>>

  Base16: <<0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00>>
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
  @type t() :: %__MODULE__{
          length: binary(),
          identifier: binary(),
          version: binary(),
          units: binary(),
          xdensity: binary(),
          ydensity: binary(),
          xthumbnail: binary(),
          ythumbnail: binary(),
          content: binary()
        }
  defstruct [
    :length,
    :identifier,
    :version,
    :units,
    :xdensity,
    :ydensity,
    :xthumbnail,
    :ythumbnail,
    :content
  ]

  def decode(
        <<0xFF, 0xD8, 0xFF, 0xE0, length::binary-size(2), id::binary-size(5),
          version::binary-size(2), units::binary-size(1), xdensity::binary-size(1),
          ydensity::binary-size(1), xthumb::binary-size(3), ythumb::binary-size(3), rest::binary>>
      ) do
    IO.puts("Found JFIF data stream")

    %JPG{
      length: length,
      identifier: id,
      version: version,
      units: units,
      xdensity: xdensity,
      ydensity: ydensity,
      xthumbnail: xthumb,
      ythumbnail: ythumb,
      content: rest
    }
  end

  def decode(<<_soi::binary-size(3), raw::binary>>) do
    %JPG{
      content: raw
    }
  end

  @spec fill(Decoder.t()) :: Decoder.t() | {:error, String.t()}
  def fill(decoder) do
    with true <- decoder.bytes.i == decoder.bytes.j do
      with true <- decoder.bytes.j > 2 do
        new_val_index = decoder.bytes.j - 2
        {:ok, new_val} = decoder.bytes.buf |> Enum.fetch(new_val_index)
        decoder.bytes |> List.replace_at(new_val_index, new_val)

        # implement byte Reader for decoder struct, read buffer bytes, append to decoder.bytes.j, and return decoder
      else
        _ ->
          :error
      end
    else
      _ ->
        {:error, "jpeg: fill called when unread bytes exist"}
    end
  end
end
