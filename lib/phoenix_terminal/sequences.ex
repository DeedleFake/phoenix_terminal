defmodule PhoenixTerminal.Sequences do
  def escape(data) do
    data
    |> String.splitter("\e[")
    |> Stream.flat_map(&parse/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp parse(data) do
    {parameters, data} = parse_parameters(data)
    {intermediate, data} = parse_intermediate(data)
    data = parse_final(data)

    if length(parameters) == 0 and length(intermediate) == 0 do
      [:reset, data]
    else
      Stream.concat([parameters, intermediate, [data]])
    end
  end

  defp parse_parameters(data) do
    {parameters, data} = cut_prefix_by(data, &(&1 in 0x30..0x3F))
    {[], data}
  end

  defp parse_intermediate(data) do
    {intermediate, data} = cut_prefix_by(data, &(&1 in 0x20..0x2F))
    {[], data}
  end

  defp parse_final(<<c, data::binary>>) when c in 0x40..0x7E, do: data
  defp parse_final(data), do: data

  defp cut_prefix_by(string, f, result \\ [])
  defp cut_prefix_by("", _f, result), do: {result |> Enum.reverse() |> List.to_string(), ""}

  defp cut_prefix_by(<<c, string::binary>>, f, result) do
    if f.(c) do
      cut_prefix_by(string, f, [c | result])
    else
      result =
        result
        |> Enum.reverse()
        |> List.to_string()

      {result, <<c, string::binary>>}
    end
  end
end
