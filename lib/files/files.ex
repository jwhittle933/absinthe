defmodule Absinthe.Files do
  def get_files(opts) do
    [path: path, ext: ext] = opts
    Path.wildcard("#{path}*#{ext}")
  end
end
