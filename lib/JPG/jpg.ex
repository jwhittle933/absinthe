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

  A port of the Golang image/jpeg package.

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

  @doc """
  fill fills up the decoder.bytes.buf buffer from the underlying reader. It
  should only be called when there are no unread bytes in decoder.bytes
  """
  @spec fill(Decoder.t()) :: Decoder.t() | no_return()
  def fill(%Decoder{bytes: %Decoder.Bytes{i: i, j: j}}) when i != j do
    raise(ExceptionUnreadBytesError, message: "jpeg: fill called when uread bytes exist")
  end

  def fill(%Decoder{bytes: %{j: j}} = decoder) when j > 2 do
    val_index_0 = decoder.bytes.j - 2
    val_index_1 = decoder.bytes.j - 1

    {:ok, new_val_0} = decoder.bytes.buf |> binary_part(val_index_0, 1)
    {:ok, new_val_1} = decoder.bytes.buf |> binary_part(val_index_1, 1)

    new_bytes_list =
      decoder.bytes.buf
      # |> :binary.bin_to_list()
      |> List.replace_at(val_index_0, new_val_0)
      |> List.replace_at(val_index_1, new_val_1)
      |> Enum.into(<<>>, fn byte -> <<byte::binary>> end)

    decoder = %Decoder{
      decoder
      | bytes: %Decoder.Bytes{decoder.bytes | buf: new_bytes_list, i: 2, j: 2}
    }

    decoder |> fill
  end

  def fill(decoder) do
    range = Range.new(decoder.bytes.j, Enum.count(decoder.bytes.buf) - 1)
    read_list = decoder.bytes.buf |> Enum.slice(range)

    # =======>>>>>>
    # implement byte Reader for decoder struct, read buffer bytes, append to decoder.bytes.j, and return decoder
    # ========>>>>>
  end

  @doc """
  read_byte_stuffed_byte is like read_byte but is for byte-stuffed Huffman data
  """
  @spec read_byte_stuffed_byte(Decoder.t()) :: {:ok, iodata(), Decoder.t()} | no_return
  def read_byte_stuffed_byte(%Decoder{bytes: %Decoder.Bytes{i: i, j: j}} = decoder)
      when i + 2 <= j do
    {:ok, x} = decoder.bytes.buf |> Enum.slice(Range.new(i, i + 1))

    decoder = %Decoder{
      decoder
      | bytes: %Decoder.Bytes{decoder.bytes | i: decoder.bytes.i + 1, n_unreadable: 1}
    }

    with true <- x != 0xFF do
      {:ok, x, decoder}
    else
      false ->
        with false <- {:ok, 0x00} = decoder.bytes.buf |> binary_part(decoder.bytes.i, 1) do
          raise(ExceptionMissingFF00, message: "missing <<0xFF, 0x00>> byte sequence")
        else
          _ ->
            decoder = %Decoder{
              decoder
              | bytes: %Decoder.Bytes{decoder.bytes | i: decoder.bytes.i + 1, n_unreadable: 2}
            }

            {:ok, 0xFF, decoder}
        end
    end
  end

  @spec read_byte_stuffed_byte(Decoder.t()) :: {:ok, iodata(), Decoder.t()} | no_return
  def read_byte_stuffed_byte(%Decoder{} = decoder) do
    {x, decoder} =
      %Decoder{decoder | bytes: %Decoder.Bytes{decoder.bytes | n_unreadable: 0}}
      |> read_byte

    decoder = %Decoder{decoder | bytes: %Decoder.Bytes{n_unreadable: 1}}

    with true <- x != 0xFF do
      {:ok, x, decoder}
    else
      _ ->
        {x, decoder} = decoder |> read_byte
        decoder = %Decoder{decoder | bytes: %Decoder.Bytes{n_unreadable: 2}}

        unless x == 0x00,
          do: raise(ExceptionMissingFF00, message: "missing <<0xFF, 0x00>> byte sequence")

        {:ok, 0xFF, decoder}
    end
  end

  @doc """
  unread_byte_stuff_byte undoes the most recent read_byte_stuffed_byte call,
  giving a byte of data back from decoder.bits to decoder.bytes. The Huffman
  look-up table requires at least 8 bits for look-up, which means the Huffman
  decoding can sometimes overshoot and read one or two too many bytes. Two-byte
  overshoot can happen when expecting to read a 0xFF 0x00 byte-stuffed byte.
  """
  @spec unread_byte_stuffed_byte(Decoder.t()) :: Decoder.t() | {:error, String.t()}
  def unread_byte_stuffed_byte(%Decoder{} = decoder) do
    with true <- decoder.bits.n >= 8 do
      a_shift_right = decoder.bits.a >>> 8
      new_n = decoder.bits.n - 8
      m_shift_right = decoder.bits.m >>> 8

      %Decoder{
        decoder
        | bits: %Decoder.Bits{decoder.bits | a: a_shift_right, m: m_shift_right, n: new_n},
          bytes: %Decoder.Bytes{
            decoder.bytes
            | i: decoder.bytes.i - decoder.bytes.n_unreadable,
              n_unreadable: 0
          }
      }
    else
      _ ->
        %Decoder{
          decoder
          | bytes: %Decoder.Bytes{
              decoder.bytes
              | i: decoder.bytes.i - decoder.bytes.n_unreadable,
                n_unreadable: 0
            }
        }
    end
  end

  @doc """
  read_byte returns the next byte, whether buffered or not buffered. It does
  not care about byte stuffing.
  """
  @spec read_byte(Decoder.t()) :: {integer(), Decoder.t()} | no_return
  def read_byte(%Decoder{bytes: %Decoder.Bytes{i: i, j: j}} = decoder) when i == j do
    decoder
    |> fill
    |> read_byte
  end

  @spec read_byte(Decoder.t()) :: {integer(), Decoder.t()} | no_return
  def read_byte(%Decoder{bytes: %Decoder.Bytes{buf: buf, i: i}} = decoder) do
    {binary_part(buf, i, 1),
     %Decoder{decoder | bytes: %{decoder.bytes | i: decoder.bytes.i + 1, n_unreadable: 0}}}
  end

  @doc """
  read_full reads exactly length n of decoder.bytes.buf
  """
  @spec read_full(Decoder.t(), [iodata()]) :: Decoder.t() | no_return
  def read_full(
        %Decoder{bytes: %Decoder.Bytes{n_unreadable: n_unreadable}, bits: %Decoder.Bits{n: n}} =
          decoder,
        bin_list
      )
      when n_unreadable != 0 and n >= 8 do
    decoder
    |> unread_byte_stuffed_byte()
    |> read_full(bin_list)
  end

  def read_full(%Decoder{bytes: %Decoder.Bytes{n_unreadable: n}} = decoder, bin_list)
      when n != 0 do
    %Decoder{decoder | bytes: %Decoder.Bytes{decoder.bytes | n_unreadable: 0}}
    |> read_full(bin_list)
  end

  def read_full(decoder, bin_list) do
    {decoder, _, _} = read_full_looper(decoder, bin_list)
    decoder
  end

  @doc """
  read_full_looper recursive helper func for read_full
  """
  defp read_full_looper(%Decoder{bytes: %Decoder.Bytes{i: i, j: j}} = decoder, dst) do
    src = decoder.bytes.buf |> Enum.slice(Range.new(i, j))
    {dst, n} = Builtin.copy(dst, src)
    dst = dst |> Enum.slice(Range.new(n, Enum.count(dst) - 1))
    decoder = %Decoder{decoder | bytes: %Decoder.Bytes{decoder.bytes | i: decoder.bytes.i + n}}

    with true <- dst == [] do
      {decoder, dst, src}
    else
      _ ->
        decoder
        |> fill
        |> read_full_looper(dst)
    end
  end

  @doc """
  ignore ignores the next n bytes
  """
  @spec ignore(Decoder.t(), integer()) :: Decoder.t() | no_return
  def ignore(
        %Decoder{bytes: %Decoder.Bytes{n_unreadable: n_unreadable}, bits: %Decoder.Bits{n: n}} =
          decoder,
        n
      )
      when n_unreadable != 0 and n >= 8 do
    decoder
    |> unread_byte_stuffed_byte
    |> ignore(n)
  end

  def ignore(%Decoder{bytes: %Decoder.Bytes{n_unreadable: n}} = decoder, n) when n != 0 do
    %Decoder{decoder | bytes: %Decoder.Bytes{decoder.bytes | n_unreadable: 0}}
    |> ignore(n)
  end

  def ignore(%Decoder{} = decoder, n) do
    decoder |> ignore_looper(n)
  end

  @doc """
  ignore_looper recursive helper for ignore
  """
  def ignore_looper(%Decoder{bytes: %Decoder.Bytes{j: j, i: i}} = decoder, n) do
    m =
      case j - i > n do
        true -> n
        false -> j - i
      end

    decoder = %Decoder{decoder | bytes: %Decoder.Bytes{decoder.bytes | i: decoder.bytes.i + m}}

    with true <- n == 0 do
      decoder
    else
      _ ->
        decoder
        |> fill
        |> ignore_looper(n)
    end
  end

  @doc """
  process_sof
  """
  @spec process_sof(Decoder.t(), integer()) :: Decoder.t() | no_return
  def process_sof(%Decoder{n_comp: n}, _) when n != 0,
    do: raise(ExceptionFormatError, message: "multiple SOF markers")

  def process_sof(%Decoder{tmp: tmp} = decoder, n) do
    sl = tmp |> Enum.slice(Range.new(0, n - 1))

    decoder =
      decoder
      |> determine_components(n)
      |> read_full(sl)

    unless decoder.tmp |> List.first() == 8,
      do:
        raise(ExceptionUnsupportedError, message: "Precision: only 8-bit precision is supported")

    # workaround, not Elixir way
    n_height = decoder.tmp |> List.first() |> Bitwise.bsl(8)
    n_height_add = decoder.tmp |> Enum.at(2)

    n_width = decoder.tmp |> Enum.at(3) |> Bitwise.bsl(8)
    n_width_add = decoder.tmp |> Enum.at(4)

    decoder =
      decoder
      |> (fn d -> %Decoder{d | height: n_height + n_height_add} end).()
      |> (fn d -> %Decoder{d | width: n_width + n_width_add} end).()

    unless Enum.at(decoder.tmp, 5) == decoder.n_comp,
      do: raise(ExceptionFormatError, message: "SOF has wrong length")

    decoder
    |> process_sof_looper(0)
  end

  @spec process_sof_looper(Decoder.t(), integer()) :: Decoder.t() | no_return
  defp process_sof_looper(%Decoder{n_comp: n_comp} = decoder, i) when n_comp >= i, do: decoder

  defp process_sof_looper(%Decoder{n_comp: n_comp, comp: comp, tmp: tmp} = decoder, i) do
    decoder =
      %Decoder{decoder | comp: %{decoder.comp | c: tmp |> Enum.at(9)}}
      |> check_comp_loop(i, 0)
      |> (fn d ->
            %Decoder{d | comp: d.comp |> List.replace_at(i, d.tmp |> Enum.at(8 + 3 * i))}
          end).()

    unless decoder.comp |> Enum.at(i) |> (fn x -> x.tq end).() <= Constants.max_tq(),
      do: raise(ExceptionFormatError, message: "Bad tq value")

    {h, v} =
      decoder
      |> check_luma_chroma(i)
      |> check_h_v(i)

    decoder
    |> (fn d ->
          %Decoder{
            d
            | comp: d.comp |> List.replace_at(i, %Component{(d.comp |> Enum.at(i)) | h: h, v: v})
          }
        end).()
  end

  @doc """
  If a jpeg has only one component, section A.2 says "this data is non-interleaved by definition" and
  section A.2.2 says "[in this case...] the order of data units within a scan shall be lef-to-right
  and top-to-bottom... regardless of the values of H_1 and V_1". Section 4.8.2 also says "[for non-interleaved
  data], the MCU is defined to be one data unit." Similarly, section A.1.1 explains that it is the ratio
  of H_i to max_j(H_j) that matters, and similarly for V. For grayscale images, H_1 is the maximum H_j
  for all components j, so that the ratio is always 1. The component's (h, v) is effectively always (1, 1):
  even if the nominal (h, v) is (2, 1), a 20x5 image is enclosed in three 8x8 MCU's, not two 16x8 MCU's

  For YCbCr images, we only support 4:4:4, 4:4:0, 4:2:2, 4:2:0, 4:1:1, or 4:1:0 chroma subsampling ratios.
  This implies that the (h, v) values for the Y component are either (1, 1), (1, 2), (2, 1), (2, 2), (4, 1),
  or (4, 2), and the Y component's values must be a multiple of the Cb and Cr component's values. We also assume
  that the two chroma components have the same subsampling ratio.

  For 4-component images (either CMYK or YCbCrK), we only support two hv vectors: <<0x11, 0x11, 0x11, 0x11>>
  and <<0x22, 0x11, 0x11, 0x22>>. Theoretically, 4-component jpeg images could mix and match hv values but
  in practice, those two combinations are the only ones in use, and it simplifies the apply_black code below
  if we can assume that:
   - for CMYK, the C and K channels have full samples, and if the M and Y channels subsample, they subsample
     both horizontally and vertically
   - for YCbCrK, the Y and K channels have full samples
  """
  @spec check_h_v({Decoder.t(), integer(), integer(), integer()}, integer()) ::
          {integer(), integer()} | no_return
  def check_h_v({%Decoder{n_comp: n_comp}, _, _, _}, _) when n_comp == 1, do: {1, 1}

  def check_h_v({%Decoder{n_comp: n_comp, comp: comp}, _, h, v}, i) when n_comp == 3 do
    (fn
       i when i == 0 ->
         unless v != 4,
           do: raise(ExceptionUnsupportedError, message: "unsupported subsampling ratio")

       i when i == 1 ->
         with true <-
                comp |> List.first() |> (fn x -> rem(x.h, x.h) == 0 || rem(x.v, x.v) == 0 end).() do
           raise(ExceptionUnsupportedError, message: "unsupported subsampling ratio")
         end

       i when i == 2 ->
         with true <- comp |> Enum.at(1) |> (fn x -> x.h != h || x.v != v end).() do
           raise(ExceptionUnsupportedError, messsage: "unsupported subsampling ratio")
         end
     end).(i)

    {h, v}
  end

  def check_h_v({%Decoder{n_comp: n_comp, comp: comp}, hv, h, v}, i) when n_comp === 4 do
    (fn
       i when i == 0 ->
         with true <- hv != 0x11 && hv != 0x22 do
           raise(ExceptionUnsupportedError, message: "unsupported subsampling ratio")
         end

       i when i == 1 or i == 2 ->
         with true <- hv != 0x11 do
           raise(ExceptionUnsupportedError, message: "unsupported subsampling ratio")
         end

       i when i == 3 ->
         with true <- comp |> Enum.at(0) |> (fn x -> x.h != h || x.v != v end).() do
           raise(ExceptionUnsupportedError, message: "unsupported subsampling ratio")
         end
     end).(i)

    {h, v}
  end

  @spec check_luma_chroma(Decoder.t(), integer()) :: {integer(), integer(), integer()} | no_return
  defp check_luma_chroma(%Decoder{tmp: tmp, n_comp: n_comp} = decoder, i) do
    hv = tmp |> Enum.at(7 + 3 * i)
    h = hv <<< 4
    v = hv &&& 0x0F

    (fn
       h, v when h < 1 or 4 > h or v < 1 or 4 < v ->
         raise(ExceptionFormatError, message: "luma/chroma subsampling invalid")

       h, v when h == 3 or v == 3 ->
         raise(ExceptionFormatError, message: "unsupported subsampline ratio")
     end).(h, v)

    {decoder, hv, h, v}
  end

  @spec check_comp_loop(Decoder.t(), integer(), integer()) :: Decoder.t() | no_return
  defp check_comp_loop(decoder, i, j) when i >= j, do: decoder

  defp check_comp_loop(%Decoder{comp: comp} = decoder, i, j) do
    compi_c = comp |> Enum.at(i) |> (fn x -> x.c end).()
    compj_c = comp |> Enum.at(j) |> (fn x -> x.c end).()

    unless compi_c != compj_c,
      do: raise(ExceptionRepeatedComponent, message: "Repeated component identifier")

    check_comp_loop(decoder, i, j + 1)
  end

  defp determine_components(decoder, n) do
    n
    |> case do
      9 ->
        # Grayscale image, 6 + 3 * 1
        %Decoder{decoder | n_comp: 1}

      15 ->
        # YCbCr or RGB image, 6 + 3 * 3
        %Decoder{decoder | n_comp: 3}

      18 ->
        # YCbCrK or CMYK image, 6 + 3 * 4
        %Decoder{decoder | n_comp: 4}

      _ ->
        raise(ExceptionUnsupportedError, message: "number of components")
    end
  end

  @doc """
  process_dqt
  """
  @spec process_dqt(Decoder.t(), integer()) :: Decoder.t() | no_return
  def process_dqt(%Decoder{} = decoder, n) do
    {decoder, n} =
      decoder
      |> process_dqt_loop(n)

    unless n == 0, do: raise(ExceptionFormatError, message: "DQT has wrong length")

    decoder
  end

  @spec process_dqt_loop(Decoder.t(), integer()) :: {Decoder.t(), integer()} | no_return
  def process_dqt_loop(decoder, n) when n > 0 do
    {x, decoder} = decoder |> read_byte
    tq = x &&& 0x0F

    unless tq <= @max_tq, do: raise(ExceptionFormatError, message: "bad tq value")

    shift_x = x >>> 4
    # read value from dqt_check_x: if {:stop, decoder}, return to caller and break iteration
    decoder
    |> dqt_check_x(shift_x, tq, n)
    |> process_dqt_loop(n - 1)
  end

  _ = """
  dqt_check_x checks on a bitshift right of x (x >>> 4), then performs actions on the decoder
  data. In the two cases being checked (x == 0, x ==1), a loop break must be enabled that tells
  process_dqt_loop to finish rather than re-iterating. Otherwise, continue iterating.
  """

  defp dqt_check_x(%Decoder{} = decoder, 0, _, n) when n < @block_size,
    do: decoder

  defp dqt_check_x(%Decoder{tmp: tmp} = decoder, 0, tq, n) do
    n = n - Constants.block_size()

    decoder
    |> read_full(tmp |> Enum.slice(Range.new(0, @block_size)))
    |> d_quant0_loop(tq, 0)
  end

  defp dqt_check_x(%Decoder{} = decoder, 1, _, n) when n < 2 * @block_size,
    do: decoder

  defp dqt_check_x(%Decoder{tmp: tmp} = decoder, 1, tq, n) do
    n = n - 2 * Constants.block_size()

    decoder
    |> read_full(tmp |> Enum.slice(Range.new(0, @block_size)))
    |> d_quant1_loop(tq, 0)
  end

  # Default
  defp dqt_check_x(_, _, _), do: raise(ExceptionFormatError, message: "bad Pq value")

  _ = """
  d_quant_loop iterates over decoder.quant, grabs tq, then i, and updates to decoder.tmp[2*i]<<8 | d.tmp[2*i+1]
  """

  defp d_quant0_loop(%Decoder{tmp: tmp, quant: quant} = decoder, tq, i) when i < length(quant) do
    with true <- i <= Enum.count(quant |> Enum.at(tq)) do
      new_tq_i = tmp |> Enum.at(i)
      new_quant_tq = quant |> Enum.at(tq) |> List.replace_at(i, new_tq_i)

      %Decoder{decoder | quant: decoder.quant |> List.replace_at(tq, new_quant_tq)}
      |> d_quant0_loop(tq, i + 1)
    else
      _ ->
        decoder
    end
  end

  defp d_quant1_loop(%Decoder{tmp: tmp, quant: quant} = decoder, tq, i) do
    with true <- i <= Enum.count(quant |> Enum.at(tq)) do
      new_tq_i = tmp |> Enum.at(2 * i) <<< 8 ||| tmp |> Enum.at(2 * i + 1)
      new_quant_tq = quant |> Enum.at(tq) |> List.replace_at(i, new_tq_i)

      %Decoder{decoder | quant: decoder.quant |> List.replace_at(tq, new_quant_tq)}
      |> d_quant1_loop(tq, i + 1)
    else
      _ ->
        decoder
    end
  end

  def process_dri(_, n) when n != 2,
    do: raise(ExceptionFormatError, message: "DRI has wrong length")

  def process_dri(%Decoder{tmp: tmp} = decoder, n) do
    decoder =
      decoder
      |> read_full(tmp |> Enum.slice(Range.new(0, 1)))

    # rethink functionality; make more Elixir-y
    new_ri = tmp |> List.first() |> (fn x -> x <<< 8 end).()
    new_ri = tmp |> (fn tmp -> tmp |> Enum.at(1) end).() |> (fn x -> x + new_ri end).()

    %Decoder{decoder | ri: new_ri}
  end

  def process_app0_marker(decoder, n) when n < 5, do: decoder |> ignore(n)

  def process_app0_marker(%Decoder{tmp: tmp} = decoder, n) do
    decoder =
      decoder
      |> read_full(tmp |> Enum.slice(Range.new(0, 4)))
      |> (fn d -> %Decoder{d | jfif: tmp |> is_jfif?} end).()

    with true <- n - 5 > 0 do
      decoder |> ignore(n - 5)
    else
      _ ->
        decoder
    end
  end

  _ = """
  check for JFIF binary pattern, <<74, 70, 73, 70>>

  ## Example

      iex> <<74, 70, 73, 70>>
      "JFIF"
  """

  defp is_jfif?(tmp) do
    tmp
    |> (fn tmp -> tmp |> List.first() == <<74>> end).()
    |> (fn prev, tmp -> prev && tmp |> Enum.at(1) == <<70>> end).(tmp)
    |> (fn prev, tmp -> prev && tmp |> Enum.at(2) == <<73>> end).(tmp)
    |> (fn prev, tmp -> prev && tmp |> Enum.at(3) == <<70>> end).(tmp)
  end

  def process_app14_marker(decoder, n) when n < 12, do: decoder |> ignore(n)

  def process_app14_marker(%Decoder{tmp: tmp} = decoder, n) do
    decoder =
      decoder
      |> read_full(tmp |> Enum.slice(Range.new(0, 11)))

    with true <- is_valid_adobe_tranform?(tmp) do
      decoder =
        decoder
        |> (fn d ->
              %Decoder{decoder | adobe_transform_valid: true, adobe_transform: tmp |> Enum.at(11)}
            end).()
        |> (fn d when n - 12 > 0 -> d |> ignore(n) end).()
    else
      false ->
        with true <- n - 12 > 0 do
          decoder |> ignore(n - 12)
        else
          _ ->
            decoder
        end
    end
  end

  _ = """
  check for Adobe binary pattern, <<65, 100, 111, 98, 101>>>

  ## Example

      iex> <<65, 100, 111, 98, 101>>
      "Adobe"
  """

  defp is_valid_adobe_tranform?(tmp) do
    tmp
    |> (fn tmp -> tmp |> List.first() == <<65>> end).()
    |> (fn prev, tmp -> prev && tmp |> Enum.at(1) == <<100>> end).(tmp)
    |> (fn prev, tmp -> prev && tmp |> Enum.at(2) == <<111>> end).(tmp)
    |> (fn prev, tmp -> prev && tmp |> Enum.at(3) == <<98>> end).(tmp)
    |> (fn prev, tmp -> prev && tmp |> Enum.at(4) == <<101>> end).(tmp)
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
  def decode(
        <<0xFF, 0xD8, 0xFF, 0xE2, 0x1C, "ICC_PROFILE", _::binary-size(7), "lcms",
          _::binary-size(4), "mntrRGB XYZ ", _::binary-size(10), ").acspAPPL", _::binary-size(35),
          "-lcms", _::binary-size(48), "desc", _::binary-size(7), "^cprt", _::binary-size(8),
          "wtpt", stream::binary>> = jpg
      ) do
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
