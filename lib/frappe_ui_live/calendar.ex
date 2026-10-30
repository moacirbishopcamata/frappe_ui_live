defmodule FrappeUILive.Calendar do
  @moduledoc "Aritmética de calendário pura usada pelo DatePicker (semana começando no domingo)."

  @months ~w(Janeiro Fevereiro Março Abril Maio Junho Julho Agosto Setembro Outubro Novembro Dezembro)
  @weekdays ~w(D S T Q Q S S)

  @doc "Nomes dos meses (pt-BR)."
  def months, do: @months

  @doc "Iniciais dos dias da semana, domingo primeiro."
  def weekdays, do: @weekdays

  @doc "Primeiro dia do mês de `date`."
  @spec first_of_month(Date.t()) :: Date.t()
  def first_of_month(%Date{year: y, month: m}), do: Date.new!(y, m, 1)

  @doc "Desloca `date` em `delta` meses, sempre devolvendo o dia 1."
  @spec shift_month(Date.t(), integer()) :: Date.t()
  def shift_month(%Date{} = date, delta) when is_integer(delta) do
    date |> first_of_month() |> Date.shift(month: delta)
  end

  @doc "\"Março 2026\"."
  @spec label(Date.t()) :: String.t()
  def label(%Date{year: y, month: m}), do: "#{Enum.at(@months, m - 1)} #{y}"

  @doc "Seis semanas de sete dias (42 datas) que cobrem o mês de `date`."
  @spec weeks(Date.t()) :: [[Date.t()]]
  def weeks(%Date{} = date) do
    first = first_of_month(date)
    offset = rem(Date.day_of_week(first, :sunday) - 1, 7)
    start = Date.add(first, -offset)
    for week <- 0..5, do: for(day <- 0..6, do: Date.add(start, week * 7 + day))
  end

  @doc "Converte texto ISO (`2026-03-09`), `Date` ou nil em `Date | nil` (inválido vira nil)."
  @spec to_date(term()) :: Date.t() | nil
  def to_date(%Date{} = date), do: date

  def to_date(text) when is_binary(text) do
    case Date.from_iso8601(text) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  def to_date(_), do: nil

  @doc "`dd/mm/aaaa`."
  @spec format(Date.t()) :: String.t()
  def format(%Date{year: y, month: m, day: d}) do
    "#{pad(d)}/#{pad(m)}/#{y}"
  end

  @doc "A data está dentro de `min..max` (limites opcionais, inclusivos)?"
  @spec within?(Date.t(), Date.t() | nil, Date.t() | nil) :: boolean()
  def within?(date, min, max) do
    (is_nil(min) or Date.compare(date, min) != :lt) and
      (is_nil(max) or Date.compare(date, max) != :gt)
  end

  defp pad(n), do: n |> Integer.to_string() |> String.pad_leading(2, "0")
end
