if Code.ensure_loaded?(Ecto.Type) do
  defmodule FrappeUILive.Ecto.Duration do
    @moduledoc """
    `Ecto.Type` para o campo Duration do Frappe UI: guarda **segundos** (inteiro
    não negativo) e aceita no `cast` o que um usuário digita:

        1h 30m   |   90m   |   45s   |   1:30   |   1:30:15   |   5400

        field :tempo, FrappeUILive.Ecto.Duration

    `humanize/1` faz o caminho inverso para exibir no campo.
    """
    use Ecto.Type

    @impl true
    def type, do: :integer

    @impl true
    def cast(seconds) when is_integer(seconds) and seconds >= 0, do: {:ok, seconds}
    def cast(seconds) when is_integer(seconds), do: :error
    def cast(nil), do: {:ok, nil}
    def cast(""), do: {:ok, nil}
    def cast(text) when is_binary(text), do: text |> String.trim() |> parse()
    def cast(_), do: :error

    @impl true
    def load(seconds) when is_integer(seconds), do: {:ok, seconds}
    def load(nil), do: {:ok, nil}
    def load(_), do: :error

    @impl true
    def dump(seconds) when is_integer(seconds) and seconds >= 0, do: {:ok, seconds}
    def dump(nil), do: {:ok, nil}
    def dump(_), do: :error

    @doc "Segundos como `\"1h 30m 15s\"` (`\"0s\"` para zero)."
    @spec humanize(non_neg_integer() | nil) :: String.t()
    def humanize(nil), do: ""
    def humanize(0), do: "0s"

    def humanize(seconds) when is_integer(seconds) and seconds > 0 do
      [{div(seconds, 3600), "h"}, {div(rem(seconds, 3600), 60), "m"}, {rem(seconds, 60), "s"}]
      |> Enum.reject(fn {value, _} -> value == 0 end)
      |> Enum.map_join(" ", fn {value, unit} -> "#{value}#{unit}" end)
    end

    defp parse(""), do: {:ok, nil}

    defp parse(text) do
      cond do
        Regex.match?(~r/\A\d+\z/, text) -> {:ok, String.to_integer(text)}
        Regex.match?(~r/\A\d+:\d{1,2}(:\d{1,2})?\z/, text) -> parse_clock(text)
        true -> parse_units(text)
      end
    end

    defp parse_clock(text) do
      case text |> String.split(":") |> Enum.map(&String.to_integer/1) do
        [h, m] when m < 60 -> {:ok, h * 3600 + m * 60}
        [h, m, s] when m < 60 and s < 60 -> {:ok, h * 3600 + m * 60 + s}
        _ -> :error
      end
    end

    defp parse_units(text) do
      parts = Regex.scan(~r/(\d+)\s*([hms])/i, text)
      rebuilt = parts |> Enum.map(fn [full | _] -> full end) |> Enum.join("")

      if parts != [] and String.replace(text, ~r/\s+/, "") == String.replace(rebuilt, ~r/\s+/, "") do
        {:ok,
         Enum.reduce(parts, 0, fn [_, n, unit], acc ->
           acc + String.to_integer(n) * multiplier(String.downcase(unit))
         end)}
      else
        :error
      end
    end

    defp multiplier("h"), do: 3600
    defp multiplier("m"), do: 60
    defp multiplier("s"), do: 1
  end
end
