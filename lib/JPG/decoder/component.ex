defmodule Metallurgy.JPG.Component do
  @moduledoc """
  Component specification
  """

  @enforce_keys [:h, :v, :c, :tq]
  defstruct [:h, :v, :c, :tq]

  @type t() :: %__MODULE__{
          h: integer(),
          v: integer(),
          c: integer(),
          tq: integer()
        }
end
