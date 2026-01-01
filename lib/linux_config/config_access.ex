defmodule LinuxConfig.ConfigAccess do
  @moduledoc """
  Handles reading and writing key=value config files.
  """

  # Defines where we store the files.
  # We use the priv directory so it works in development and release.
  def path(filename), do: Path.join(:code.priv_dir(:linux_config), filename)

  @doc "Reads a file and converts it into a map of key/values"
  def read_config(filename) do
    path(filename)
    |> File.read!()
    |> String.split("\n", trim: true)
    # Filter out comments
    |> Enum.reject(&String.starts_with?(&1, "#"))
    |> Map.new(fn line ->
      [key, value] = String.split(line, "=", parts: 2)
      value = String.trim(value)

      # Attempt to infer type (Boolean or String)
      parsed_value =
        case value do
          "true" -> true
          "false" -> false
          _ -> value
        end

      {String.trim(key), parsed_value}
    end)
  end

  @doc "Writes the map back to the file as key=value"
  def save_config(filename, params) do
    content =
      params
      # Ignore internal Phoenix form fields like _target
      |> Enum.reject(fn {k, _v} -> String.starts_with?(k, "_") end)
      |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
      |> Enum.join("\n")

    File.write!(path(filename), content)
  end
end
