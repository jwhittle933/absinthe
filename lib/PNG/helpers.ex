defmodule Metallurgy.PNG.Helpers do
  @moduledoc """
  PNG Helpers
  """

  @doc """
  Return color format

  Reference: http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html
  chunk types:
  0: Each pixel is a grayscale sample.
  2: Each pixel is an R,G,B triple.
  3: Each pixel is a palette index; a PLTE chunk must appear.
  4: Each pixel is a grayscale sample, followed by an alpha sample.
  6: Each pixel is an R,G,B triple, followed by an alpha sample.

  """
  def color_format(0), do: :grayscale
  def color_format(2), do: :rgb
  def color_format(3), do: :palette
  def color_format(4), do: :grayscale_alpha
  def color_format(6), do: :rgb_alpha

  @doc """
  Return bytes per row
  """
  def bytes_per_row(:grayscale, 1, width), do: div(width + 7, 8)
  def bytes_per_row(:grayscale, 2, width), do: div(width + 3, 4)
  def bytes_per_row(:grayscale, 4, width), do: div(width + 1, 2)
  def bytes_per_row(:grayscale, 8, width), do: width
  def bytes_per_row(:grayscale, 16, width), do: width * 2
  def bytes_per_row(:rgb, 8, width), do: width * 3
  def bytes_per_row(:rgb, 16, width), do: width * 6
  def bytes_per_row(:palette, 1, width), do: div(width + 7, 8)
  def bytes_per_row(:palette, 2, width), do: div(width + 3, 4)
  def bytes_per_row(:palette, 4, width), do: div(width + 1, 2)
  def bytes_per_row(:palette, 8, width), do: width
  def bytes_per_row(:grayscale_alpha, 8, width), do: width * 2
  def bytes_per_row(:grayscale_alpha, 16, width), do: width * 4
  def bytes_per_row(:rgb_alpha, 8, width), do: width * 2
  def bytes_per_row(:rgb_alpha, 16, width), do: width * 4

  @doc """
  Searches on iTXt, tEXt and zTXt chunks for text field description

  Each of the text chunks contains as its first field a keyword that indicates the type of information represented by the text string. The following keywords are predefined and should be used where appropriate:

  Title            Short (one line) title or caption for image
  Author           Name of image's creator
  Description      Description of image (possibly long)
  Copyright        Copyright notice
  Creation Time    Time of original image creation
  Software         Software used to create the image
  Disclaimer       Legal disclaimer
  Warning          Warning of nature of content
  Source           Device used to create the image
  Comment          Miscellaneous comment; conversion from GIF comment
  """
  def text_type(<<?T, ?i, ?t, ?l, ?e, _::binary>>), do: :title
  def text_type(<<?A, ?u, ?t, ?h, ?o, ?r, _::binary>>), do: :author
  def text_type(<<?D, ?e, ?s, ?c, ?r, ?i, ?p, ?t, ?i, ?o, ?n, _::binary>>), do: :description
  def text_type(<<?C, ?o, ?p, ?y, ?r, ?i, ?g, ?h, ?t, _::binary>>), do: :copyright
  def text_type(<<?C, ?r, ?e, ?a, ?t, ?i, ?o, ?n, _::binary>>), do: :creation_time
  def text_type(<<?S, ?o, ?f, ?t, ?w, ?a, ?r, ?e, _::binary>>), do: :software
  def text_type(<<?D, ?i, ?s, ?c, ?l, ?a, ?i, ?m, ?e, ?r, _::binary>>), do: :disclaimer
  def text_type(<<?W, ?a, ?r, ?n, ?i, ?n, ?g, _::binary>>), do: :warning
  def text_type(<<?S, ?o, ?u, ?r, ?c, ?e, _::binary>>), do: :source
  def text_type(<<?C, ?o, ?m, ?m, ?e, ?n, ?t, _::binary>>), do: :comment
  def text_type(<<?X, ?M, ?L, _::binary>>), do: :xml
  def text_type(<<_::binary>>), do: :unknown

  def show_text(<<_null_sep, raw::binary>>) do
    with true <- String.valid?(raw) do
      Enum.join(for <<text::utf8 <- raw>>, do: <<text::utf8>>)
    else
      _ ->
        raw
    end
  end
end
