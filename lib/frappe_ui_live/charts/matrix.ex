defmodule FrappeUILive.Charts.Matrix do
  @moduledoc "Mapas de calor: matriz linhas × colunas e calendário (estilo contribuições)."
  use Phoenix.Component

  alias FrappeUILive.Calendar
  alias FrappeUILive.Charts.{Frame, Scale}
  alias FrappeUILive.Contract

  @cell 28
  @label_w 72
  @top 22

  attr :rows, :list, required: true, doc: "rótulos das linhas"
  attr :cols, :list, required: true, doc: "rótulos das colunas"
  attr :values, :list, required: true, doc: "matriz: uma lista de números por linha"
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def heatmap_chart(assigns) do
    Contract.ensure!(
      length(assigns.values) == length(assigns.rows) and
        Enum.all?(
          assigns.values,
          &(length(&1) == length(assigns.cols) and Enum.all?(&1, fn v -> is_number(v) end))
        ),
      "heatmap_chart: values deve ser uma matriz #{length(assigns.rows)}×#{length(assigns.cols)} de números"
    )

    state = Frame.state(assigns.loading, assigns.error, assigns.rows == [] or assigns.cols == [])
    cells = cells(assigns.rows, assigns.cols, assigns.values)
    width = @label_w + length(assigns.cols) * @cell
    height = @top + length(assigns.rows) * @cell

    assigns =
      assigns
      |> assign(
        state: state,
        cells: cells,
        width: width,
        height: height,
        cell: @cell,
        label_w: @label_w,
        top: @top
      )

    ~H"""
    <div class={@class} {@rest}>
      <Frame.chart_frame state={@state} error={@error}>
        <svg viewBox={"0 0 #{@width} #{@height}"} class="w-full" role="img" aria-label="Mapa de calor">
          <g font-size="11" style="fill: var(--ink-gray-5)">
            <text
              :for={{col, i} <- Enum.with_index(@cols)}
              x={@label_w + i * @cell + @cell / 2}
              y="14"
              text-anchor="middle"
            >
              {col}
            </text>
            <text
              :for={{row, j} <- Enum.with_index(@rows)}
              x={@label_w - 8}
              y={@top + j * @cell + @cell / 2 + 4}
              text-anchor="end"
            >
              {row}
            </text>
          </g>
          <rect
            :for={cell <- @cells}
            data-cell
            x={cell.x}
            y={cell.y}
            width={@cell - 2}
            height={@cell - 2}
            rx="3"
            style={"fill: var(--surface-blue-7); fill-opacity: #{cell.opacity}"}
          >
            <title>{cell.row} · {cell.col}: {cell.value}</title>
          </rect>
        </svg>
      </Frame.chart_frame>
    </div>
    """
  end

  @doc "Células com posição e opacidade proporcional ao valor máximo (função pura)."
  @spec cells([term()], [term()], [[number()]]) :: [map()]
  def cells(rows, cols, values) do
    max = values |> List.flatten() |> Enum.max(fn -> 0 end) |> max(1)

    for {row, j} <- Enum.with_index(rows), {col, i} <- Enum.with_index(cols) do
      value = values |> Enum.at(j) |> Enum.at(i)

      %{
        row: row,
        col: col,
        value: value,
        x: @label_w + i * @cell,
        y: @top + j * @cell,
        opacity: opacity(value, max)
      }
    end
  end

  defp opacity(value, max), do: Float.round(0.08 + 0.92 * min(value / max, 1), 2)

  attr :data, :map, required: true, doc: "%{Date => número}"
  attr :weeks, :integer, default: 26
  attr :end_date, :any, default: nil, doc: "último dia exibido (padrão: hoje)"
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def calendar_heatmap_chart(assigns) do
    Contract.ensure!(
      assigns.weeks in 1..53,
      "calendar_heatmap_chart: weeks deve estar entre 1 e 53"
    )

    end_date = Calendar.to_date(assigns.end_date) || Date.utc_today()
    state = Frame.state(assigns.loading, assigns.error, map_size(assigns.data) == 0)
    days = calendar_days(assigns.data, end_date, assigns.weeks)

    assigns = assigns |> assign(state: state, days: days, width: assigns.weeks * 14 + 4)

    ~H"""
    <div class={@class} {@rest}>
      <Frame.chart_frame state={@state} error={@error} height={110}>
        <svg
          viewBox={"0 0 #{@width} 100"}
          class="w-full"
          role="img"
          aria-label="Calendário de atividade"
        >
          <rect
            :for={day <- @days}
            data-day={day.iso}
            x={day.week * 14 + 2}
            y={day.weekday * 14 + 2}
            width="11"
            height="11"
            rx="2"
            style={"fill: var(--surface-green-7); fill-opacity: #{day.opacity}"}
          >
            <title>{day.iso}: {day.value}</title>
          </rect>
        </svg>
      </Frame.chart_frame>
    </div>
    """
  end

  @doc "Dias do calendário (função pura): coluna da semana, linha do dia e opacidade."
  @spec calendar_days(%{Date.t() => number()}, Date.t(), pos_integer()) :: [map()]
  def calendar_days(data, end_date, weeks) do
    last_sunday = Date.add(end_date, -(Date.day_of_week(end_date, :sunday) - 1))
    start = Date.add(last_sunday, -(weeks - 1) * 7)
    max = data |> Map.values() |> Enum.max(fn -> 0 end) |> max(1)

    for week <- 0..(weeks - 1),
        weekday <- 0..6,
        date = Date.add(start, week * 7 + weekday),
        Date.compare(date, end_date) != :gt do
      value = Map.get(data, date, 0)

      %{
        iso: Date.to_iso8601(date),
        week: week,
        weekday: weekday,
        value: value,
        opacity: if(value == 0, do: 0.08, else: opacity(value, max))
      }
    end
  end

  # reexport usado nos testes de escala
  @doc false
  def n(value), do: Scale.n(value)
end
