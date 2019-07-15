defmodule Absinthe.JPG.Bytes do
  @moduledoc false

  defstruct [:buf, :i, :j, :n_unreadable]

  @type t() :: %__MODULE__{
    buf: [iodata()],
    i: integer(),
    j: integer(),
    n_unreadable: integer()
  }
end
