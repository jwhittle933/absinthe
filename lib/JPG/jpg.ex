defmodule Metallurgy.JPG do
  alias __MODULE__
  alias Metallurgy.JPG.Decoder
  alias Metallurgy.JPG.Component
  alias Metallurgy.Builtin
  use Bitwise, only_operators: true
  use Metallurgy.JPG.Constants

  @moduledoc """
  Reference: http://www.fileformat.info/format/jpeg/egff.htm
  Reference: https://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/JPEG.html
  Reference: https://www.impulseadventure.com/photo/jpeg-huffman-coding.html
  Reference: https://www.onlinehexeditor.com/#

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

  @jpg_signature <<255::size(8), 216::size(8)>>

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
          soi: iodata(),
          app0: iodata(),
          length: iodata(),
          identifier: iodata(),
          version: iodata(),
          units: iodata(),
          xdensity: iodata(),
          ydensity: iodata(),
          xthumbnail: iodata(),
          ythumbnail: iodata(),
          stream: iodata()
        }
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
    :ythumbnail,
    :stream
  ]

  defmodule ExceptionUnreadBytesError do
    @moduledoc """
    Error raised when fill() called with unread bytes
    """
    defexception [:message]
  end

  defmodule ExceptionMissingFF00 do
    @moduledoc """
    Error raised when missing <<0xFF, 0x00>>
    """
    defexception [:message]
  end

  defmodule ExceptionFormatError do
    @moduledoc """
    Error when multiple SOF markers are detected
    """
    defexception [:message]
  end

  defmodule ExceptionUnsupportedError do
    @moduledoc """
    Error raised number of components exceeds the normal amount
    """
    defexception [:message]
  end

  defmodule ExceptionRepeatedComponent do
    @moduledoc """
    Error raised when components are repeated in decoder.comp
    """
    defexception [:message]
  end

  @doc """
  decode method that matches on JFIF data.
  """
  @spec decode(iodata()) :: Decoder.t()
  def decode(<<0xFF, 0xD8, 0xFF, 0xE0, length::size(16), "JFIF", stream::binary>>) do
    IO.puts("Found JFIF data stream")

    %JPG{
      length: length,
      stream: stream
    }
  end

  @doc """
  decode method for adobe jpegs
  """
  def decode(<<0xFF, 0xD8, 0xFF, 0xE0, length::size(16), "Adobe", stream::binary>> = jpg) do
    IO.puts("Found Adobe data stream")
  end

  @doc """
  decode method for jpeg downloaded from Facebook
  """
  def decode(<<0xFF, 0xD8, 0xFF, 0xE2, 0x1C, "ICC_PROFILE", stream::binary>> = jpg) do
    IO.puts("Found jpeg downloaded from Facebook data stream")

    %JPG{
      stream: stream
    }
  end

  @doc """
  decode method for matching raw jpeg stream
  """
  def decode(<<soi::binary-size(3), raw::binary>> = jpg) do
    %JPG{
      soi: soi,
      stream: raw
    }
  end

  @doc """
  fallback decode for mislabeled files
  """
  def decode(_), do: raise(ExceptionFormatError, message: "Unknown file format. Not a jpeg.")
end
