defmodule Absinthe.Reader do
  @moduledoc """
  Reader method for reading bytes from parsed files
  """
  alias __MODULE__

  defmodule NotBinary do
    @moduledoc """
    Exception raised when a non-binary argument is passed to new_reader
    """
    defexception [:message]
  end

  defstruct [:s, :i, :prev_rune]

  @type t() :: %__MODULE__{
          s: [iodata()],
          i: integer(),
          prev_rune: integer()
        }

  @doc """
  new_reader method for creating Reader. Throws NotBinary exception when parameter is not binary
  """
  @spec new_reader(iodata()) :: Reader.t()
  def new_reader(bin) when is_binary(bin) do
    %Reader{
      s: bin,
      i: 0,
      prev_rune: -1
    }
  end

  def new_reader(_) do
    raise(NotBinary, message: "binary error: argument passed to new_reader must be binary iodata")
  end

  @doc """
  read method for reading iodata
  """
  @spec read(Reader.t(), iodata()) :: integer()
  def read(reader, bin) when is_binary(bin) do
    :ok
  end

  def read(_, _) do
    raise(NotBinary, message: "binary error: argument passed to read must binary iodata")
  end
end
