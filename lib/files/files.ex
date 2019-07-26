defmodule Metallurgy.Files do
  @moduledoc """
  Metallurgy file parser module
  """
  alias Metallurgy.PNG

  @png_signature <<137::size(8), 80::size(8), 78::size(8), 71::size(8), 13::size(8), 10::size(8),
                   26::size(8), 10::size(8)>>
  @jpg_signature <<255::size(8), 216::size(8)>>

  @doc """
  parse_files module function
  """
  def parse_files(files, opts) do
    with true <- Enum.count(files) > 0 do
      Enum.each(files, &show_binary/1)
    else
      false -> IO.puts("No files")
    end
  end

  def type(<<@png_signature, rest::binary>>), do: :png
  def type(<<@jpg_signature, rest::binary>>), do: :jpg
  def type(_), do: :unknown

  @doc """
  get_files

  Takes opts returned from cli parser
  and returns all files that match the provided
  pattern
  """
  def get_file_list([{:path, path}, {:ext, ext}, {:out, _}]) do
    str_l = String.length(path)

    with true <- path |> String.slice(Range.new(str_l - 1, str_l)) == "/" do
      IO.puts("#{path}*#{ext}")
      Path.wildcard("#{path}*#{ext}")
    else
      _ ->
        path = path <> "/"
        Path.wildcard("#{path}*#{ext}")
    end
  end

  @doc """
  get_ext

  Returns file extension at a given path
  """
  def get_ext(path) do
    Path.extname(path)
  end

  @doc """
  Returns the file name from a string path
  """
  @spec file_name(String.t()) :: String.t()
  def file_name(path) when is_binary(path) do
    path |> String.split("/") |> Enum.reverse() |> List.first()
  end

  def file_name(_), do: {:error, "Path is not a string"}

  @doc """
  valid_mime?

  Compares provided file at path with a group
  of chosen mimes. Returns true if pattern matches.
  """
  def valid_mime?(path) do
    ~w(.jpg .jpeg .gif .png .JPG) |> Enum.member?(get_ext(path))
  end

  def show_binary(file) do
    file |> File.read!() |> PNG.decode(file) |> IO.inspect()
  end

  def open_and_read(file) do
    r_file = file |> Path.absname() |> File.open!()
    io_data = r_file |> IO.binread(:line)

    with :ok <- File.close(r_file) do
      io_data
    end
  end

  def write_to_new_file(io_data, file, [{:path, _}, {:ext, ext}, {:out, out}] = opts) do
    with true <- File.dir?(out) do
      new_out = [out, Path.basename(file, ext)] |> Path.join()
      IO.puts(new_out <> ".jpg")
      File.write(new_out <> ".jpg", io_data)
    else
      false ->
        File.mkdir(out)
        write_to_new_file(io_data, file, opts)
    end
  end
end
