defmodule FrappeUILive.Components.DatePicker do
  @moduledoc """
  Seletor de data com calendário (LiveComponent: o mês exibido é estado próprio).

      <.live_component module={FrappeUILive.Components.DatePicker} id="nascimento" field={@form[:nascimento]} />

  O valor viaja num `<input type=hidden>` (formato ISO). Ao escolher um dia, o
  cliente atualiza o hidden e dispara `input`, então o `phx-change` do
  formulário recebe a mudança como em qualquer outro campo; o servidor também
  recebe `pick` para manter a seleção coerente. Datas forjadas (fora de
  `min`/`max` ou inválidas) são ignoradas.
  """
  use Phoenix.LiveComponent

  alias FrappeUILive.Calendar
  alias FrappeUILive.Texts
  alias FrappeUILive.Components.{Anchor, Icon}
  alias FrappeUILive.Field
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :name, :string, default: nil
  attr :value, :any, default: nil, doc: "data ISO (`2026-03-09`) ou `Date`"
  attr :min, :any, default: nil, doc: "primeira data permitida"
  attr :max, :any, default: nil, doc: "última data permitida"
  attr :placeholder, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global

  @doc "Função-componente que monta o LiveComponent (`<.date_picker id=... field=... />`)."
  def date_picker(assigns) do
    passthrough =
      assigns
      |> Map.take([:id, :field, :name, :value, :min, :max, :placeholder, :disabled, :rest])
      |> Map.reject(fn {k, v} -> is_nil(v) or (k == :rest and v == %{}) end)

    assigns = assign(assigns, :passthrough, passthrough)

    ~H"""
    <.live_component module={__MODULE__} {@passthrough} />
    """
  end

  @impl true
  def mount(socket), do: {:ok, assign(socket, :today, Date.utc_today())}

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, Map.drop(assigns, [:field]))
    socket = assign_field(socket, assigns[:field])

    min = Calendar.to_date(socket.assigns[:min])
    max = Calendar.to_date(socket.assigns[:max])
    selected = Calendar.to_date(socket.assigns[:value])

    month =
      cond do
        socket.assigns[:month] && selected == socket.assigns[:selected] -> socket.assigns.month
        selected -> Calendar.first_of_month(selected)
        true -> Calendar.first_of_month(socket.assigns[:month] || socket.assigns.today)
      end

    {:ok,
     socket
     |> assign(min: min, max: max, selected: selected, month: month)
     |> assign_new(:placeholder, fn -> Texts.t(:select_date) end)
     |> assign_new(:disabled, fn -> false end)
     |> assign_new(:rest, fn -> %{} end)}
  end

  # Com `field`, o valor do formulário é a fonte da verdade a cada atualização.
  defp assign_field(socket, %Phoenix.HTML.FormField{} = field) do
    socket
    |> assign(:name, field.name)
    |> assign(:errors, Field.errors(field))
    |> assign(:value, field.value)
  end

  defp assign_field(socket, nil) do
    socket
    |> assign_new(:name, fn -> nil end)
    |> assign_new(:errors, fn -> [] end)
    |> assign_new(:value, fn -> nil end)
  end

  @impl true
  def handle_event("prev", _params, socket), do: {:noreply, shift(socket, -1)}
  def handle_event("next", _params, socket), do: {:noreply, shift(socket, 1)}

  def handle_event("pick", %{"date" => iso}, socket) do
    case Calendar.to_date(iso) do
      %Date{} = date ->
        if Calendar.within?(date, socket.assigns.min, socket.assigns.max),
          do: {:noreply, assign(socket, selected: date, value: iso)},
          else: {:noreply, socket}

      nil ->
        {:noreply, socket}
    end
  end

  # Evento forjado ou malformado (sem a chave esperada): ignora, não derruba o componente.
  def handle_event("pick", _params, socket), do: {:noreply, socket}

  def handle_event("clear", _params, socket),
    do: {:noreply, assign(socket, selected: nil, value: nil)}

  defp shift(socket, delta),
    do: assign(socket, :month, Calendar.shift_month(socket.assigns.month, delta))

  @impl true
  def render(assigns) do
    Anchor.valid_id!(assigns.id, "date_picker")
    panel = "#{assigns.id}-panel"

    assigns =
      assign(assigns,
        panel: panel,
        weeks: Calendar.weeks(assigns.month),
        value_id: "#{assigns.id}-value"
      )

    ~H"""
    <div class="relative inline-block w-full" id={@id} {@rest}>
      <input
        type="hidden"
        id={@value_id}
        name={@name}
        value={@selected && Date.to_iso8601(@selected)}
      />
      <button
        type="button"
        popovertarget={@panel}
        style={Anchor.trigger_style(@id)}
        disabled={@disabled}
        aria-haspopup="dialog"
        aria-invalid={@errors != [] && "true"}
        class={[
          "bg-surface-gray-2 fui-text-base hover:bg-surface-gray-3 flex h-7 w-full items-center justify-between rounded-4 border border-transparent px-2 text-left transition-colors disabled:cursor-not-allowed disabled:opacity-60",
          @errors != [] && "border-outline-red-3"
        ]}
      >
        <span class={[@selected && "text-ink-gray-8", !@selected && "text-ink-gray-4"]}>
          {if @selected, do: Calendar.format(@selected), else: @placeholder}
        </span>
        <Icon.icon name="calendar" class="text-ink-gray-5 size-4" />
      </button>

      <div
        id={@panel}
        popover
        style={Anchor.panel_style(@id)}
        class={[Anchor.panel_classes(), "w-64 border p-3"]}
      >
        <div class="mb-2 flex items-center justify-between">
          <button
            type="button"
            aria-label={Texts.t(:prev_month)}
            phx-click="prev"
            phx-target={@myself}
            class="hover:bg-surface-gray-3 rounded-4 p-1"
          >
            <Icon.icon name="chevron-left" class="size-4" />
          </button>
          <span class="fui-text-base-medium text-ink-gray-9" aria-live="polite">{Calendar.label(
            @month
          )}</span>
          <button
            type="button"
            aria-label={Texts.t(:next_month)}
            phx-click="next"
            phx-target={@myself}
            class="hover:bg-surface-gray-3 rounded-4 p-1"
          >
            <Icon.icon name="chevron-right" class="size-4" />
          </button>
        </div>

        <div class="fui-text-xs text-ink-gray-5 mb-1 grid grid-cols-7 text-center">
          <span :for={day <- Calendar.weekdays()}>{day}</span>
        </div>

        <div class="grid grid-cols-7 gap-0.5" role="grid">
          <%= for week <- @weeks, date <- week do %>
            <% iso = Date.to_iso8601(date) %>
            <button
              type="button"
              data-date={iso}
              disabled={!Calendar.within?(date, @min, @max)}
              aria-pressed={@selected == date && "true"}
              popovertarget={@panel}
              popovertargetaction="hide"
              phx-click={pick(@value_id, iso, @myself)}
              class={[
                "fui-text-sm size-8 rounded-4 text-center disabled:cursor-not-allowed disabled:opacity-30",
                @selected == date && "bg-surface-gray-10 text-ink-base",
                @selected != date && date.month == @month.month &&
                  "text-ink-gray-8 hover:bg-surface-gray-3",
                @selected != date && date.month != @month.month &&
                  "text-ink-gray-4 hover:bg-surface-gray-2",
                @selected != date && date == @today && "border-outline-gray-4 border"
              ]}
            >
              {date.day}
            </button>
          <% end %>
        </div>

        <button
          :if={@selected}
          type="button"
          phx-click="clear"
          phx-target={@myself}
          class="fui-text-sm text-ink-gray-5 hover:text-ink-gray-8 mt-2"
        >
          {Texts.t(:clear)}
        </button>
      </div>
    </div>
    """
  end

  # Atualiza o hidden no cliente e dispara `input` (o form recebe o phx-change) antes do push.
  defp pick(value_id, iso, target) do
    JS.set_attribute({"value", iso}, to: "##{value_id}")
    |> JS.dispatch("input", to: "##{value_id}")
    |> JS.push("pick", value: %{date: iso}, target: target)
  end
end
