defmodule FrappeUIPhx.Components.Calendar do
  @moduledoc """
  Calendário mensal com eventos (visão de agenda). O mês exibido e o dia
  selecionado são assigns do servidor; navegar e escolher são eventos
  (`on_prev`, `on_next`, `on_today`, `on_select` com `%{"date" => "2026-03-09"}`).

  Para *escolher uma data em formulário*, use `date_picker`. Experimental.
  """
  use Phoenix.Component

  alias FrappeUIPhx.Texts

  alias FrappeUIPhx.Calendar, as: Dates
  alias FrappeUIPhx.Components.{Badge, Icon}

  @themes ~w(gray blue green amber red violet)a
  @max_events 2

  attr :id, :string, required: true
  attr :month, :any, default: nil, doc: "`Date` ou ISO de qualquer dia do mês (padrão: hoje)"
  attr :events, :list, default: [], doc: "[%{date: Date | ISO, title: String, theme: atom}]"
  attr :selected, :any, default: nil
  attr :today, :any, default: nil, doc: "sobrescreve \"hoje\" (testes)"
  attr :on_prev, :string, default: nil
  attr :on_next, :string, default: nil
  attr :on_today, :string, default: nil
  attr :on_select, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def calendar(assigns) do
    today = Dates.to_date(assigns.today) || Date.utc_today()
    month = Dates.first_of_month(Dates.to_date(assigns.month) || today)

    assigns =
      assigns
      |> assign(:today_date, today)
      |> assign(:month_date, month)
      |> assign(:selected_date, Dates.to_date(assigns.selected))
      |> assign(:weeks, Dates.weeks(month))
      |> assign(:by_day, events_by_day(assigns.events))
      |> assign(:max_events, @max_events)

    ~H"""
    <div id={@id} class={["border-outline-gray-2 bg-surface-base rounded-6 border", @class]} {@rest}>
      <div class="border-outline-gray-2 flex items-center justify-between border-b px-3 py-2">
        <span class="fui-text-lg-semibold text-ink-gray-9" aria-live="polite">{Dates.label(
          @month_date
        )}</span>
        <div class="flex items-center gap-1">
          <button
            :if={@on_today}
            type="button"
            phx-click={@on_today}
            class="fui-text-sm text-ink-gray-7 hover:bg-surface-gray-2 rounded-4 px-2 py-1"
          >{Texts.t(:today)}</button>
          <button
            type="button"
            aria-label={Texts.t(:prev_month)}
            phx-click={@on_prev}
            class="hover:bg-surface-gray-2 rounded-4 p-1.5"
          ><Icon.icon name="chevron-left" class="size-4" /></button>
          <button
            type="button"
            aria-label={Texts.t(:next_month)}
            phx-click={@on_next}
            class="hover:bg-surface-gray-2 rounded-4 p-1.5"
          ><Icon.icon name="chevron-right" class="size-4" /></button>
        </div>
      </div>

      <div
        class="fui-text-xs text-ink-gray-5 border-outline-gray-2 grid grid-cols-7 border-b text-center"
        role="row"
      >
        <span :for={day <- Dates.weekdays()} class="py-1.5">{day}</span>
      </div>

      <div class="grid grid-cols-7" role="grid">
        <%= for week <- @weeks, date <- week do %>
          <% iso = Date.to_iso8601(date) %>
          <% day_events = Map.get(@by_day, date, []) %>
          <div
            data-day={iso}
            aria-selected={@selected_date == date && "true"}
            class={[
              "border-outline-gray-1 min-h-20 border-r border-b p-1",
              date.month != @month_date.month && "bg-surface-gray-1"
            ]}
          >
            <button
              type="button"
              phx-click={@on_select}
              phx-value-date={iso}
              class={[
                "fui-text-sm size-6 rounded-full text-center",
                date.month == @month_date.month && "text-ink-gray-8",
                date.month != @month_date.month && "text-ink-gray-4",
                @selected_date == date && "bg-surface-gray-10 text-ink-base",
                @selected_date != date && date == @today_date && "border-outline-gray-4 border",
                @selected_date != date && "hover:bg-surface-gray-3"
              ]}
            >
              {date.day}
            </button>
            <div class="mt-1 space-y-0.5">
              <Badge.badge
                :for={event <- Enum.take(day_events, @max_events)}
                data-event
                theme={theme(event)}
                size={:sm}
                label={event.title}
                class="w-full truncate"
              />
              <p
                :if={length(day_events) > @max_events}
                class="fui-text-xs text-ink-gray-5 px-1"
                data-more
              >
                +{length(day_events) - @max_events}
              </p>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc "Agrupa eventos por dia (função pura); eventos com data inválida são descartados."
  @spec events_by_day([map()]) :: %{Date.t() => [map()]}
  def events_by_day(events) do
    events
    |> Enum.flat_map(fn event ->
      case Dates.to_date(event[:date]) do
        %Date{} = date -> [{date, event}]
        nil -> []
      end
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  defp theme(event), do: if(event[:theme] in @themes, do: event[:theme], else: :blue)
end
