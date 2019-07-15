defmodule Absinthe.JPG.Context do
  @moduledoc """
  Context module for all JPG types and methods.

  To import all JPG submodles: use Absinthe.JPG.Context
  To import one module: use Absinthe.JPG.Context, :module_macro
  """

  def component do
    quote do
      import Absinthe.JPG.Component
    end
  end

  def decoder do
    quote do
      import Absinthe.JPG.Decoder
    end
  end

  def constants do
    quote do
      import Absinthe.JPG.Constants
    end
  end

  defmacro __using__(which) when is_atom(which) do
    quote do
      apply(__MODULE__, which, [])
    end
  end

  defmacro __using__(_) do
    quote do
      import Absinthe.JPG.Component
      import Absinthe.JPG.Decoder
      import Absinthe.JPG.Constants
    end
  end
end
