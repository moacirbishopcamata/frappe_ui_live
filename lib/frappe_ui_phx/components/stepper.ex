defmodule FrappeUIPhx.Components.Stepper do
  @moduledoc """
  Indicador de etapas. A etapa atual (`current`, índice a partir de 0; igual ao
  número de etapas = tudo concluído) é um assign do servidor, e o estado de cada
  etapa (`:done | :current | :upcoming`) é derivado dele. Com `on_go`, as etapas
  concluídas viram botões que voltam para elas (`%{"step" => índice}`). Experimental.
  """
  use Phoenix.Component

  alias FrappeUIPhx.Texts

  alias FrappeUIPhx.Components.Icon
  alias FrappeUIPhx.Contract

  @orientations ~w(horizontal vertical)a

  attr :current, :integer, required: true
  attr :orientation, :atom, default: :horizontal, values: @orientations
  attr :on_go, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  slot :step, required: true do
    attr :label, :string, required: true
    attr :description, :string
  end

  def stepper(assigns) do
    Contract.require!(assigns.orientation, @orientations, "stepper orientation")
    total = length(assigns.step)

    Contract.ensure!(
      is_integer(assigns.current) and assigns.current in 0..total,
      "stepper: current deve estar entre 0 e #{total}"
    )

    assigns = assign(assigns, :steps, Enum.with_index(assigns.step))

    ~H"""
    <ol
      class={[
        "flex",
        @orientation == :horizontal && "items-start gap-2",
        @orientation == :vertical && "flex-col gap-4",
        @class
      ]}
      {@rest}
    >
      <li
        :for={{step, index} <- @steps}
        data-step={index}
        data-state={state(index, @current)}
        aria-current={state(index, @current) == :current && "step"}
        class={["flex gap-3", @orientation == :horizontal && "min-w-0 flex-1 flex-col"]}
      >
        <div class="flex items-center gap-2">
          <.marker index={index} state={state(index, @current)} on_go={@on_go} label={step.label} />
          <span
            :if={@orientation == :horizontal and index < length(@step) - 1}
            class={[
              "h-px flex-1",
              index < @current && "bg-surface-gray-10",
              index >= @current && "bg-surface-gray-3"
            ]}
          ></span>
        </div>
        <div class="min-w-0">
          <p class={[
            "fui-text-base-medium",
            state(index, @current) == :upcoming && "text-ink-gray-5",
            state(index, @current) != :upcoming && "text-ink-gray-9"
          ]}>
            {step.label}
          </p>
          <p :if={step[:description]} class="fui-text-sm text-ink-gray-5">{step[:description]}</p>
        </div>
      </li>
    </ol>
    """
  end

  attr :index, :integer, required: true
  attr :state, :atom, required: true
  attr :on_go, :string, default: nil
  attr :label, :string, required: true

  defp marker(assigns) do
    ~H"""
    <button
      :if={@state == :done and @on_go}
      type="button"
      phx-click={@on_go}
      phx-value-step={@index}
      aria-label={Texts.t(:go_back_to, label: @label)}
      class={marker_class(:done)}
    >
      <Icon.icon name="check" class="size-4" />
    </button>
    <span :if={@state == :done and !@on_go} class={marker_class(:done)}><Icon.icon
      name="check"
      class="size-4"
    /></span>
    <span :if={@state != :done} class={marker_class(@state)}>{@index + 1}</span>
    """
  end

  defp marker_class(:done),
    do:
      "bg-surface-gray-10 text-ink-base fui-text-sm inline-flex size-7 shrink-0 items-center justify-center rounded-full"

  defp marker_class(:current),
    do:
      "border-surface-gray-10 text-ink-gray-9 fui-text-sm-medium inline-flex size-7 shrink-0 items-center justify-center rounded-full border-2"

  defp marker_class(:upcoming),
    do:
      "border-outline-gray-3 text-ink-gray-5 fui-text-sm inline-flex size-7 shrink-0 items-center justify-center rounded-full border"

  @doc "Estado da etapa `index` dado `current`."
  @spec state(non_neg_integer(), non_neg_integer()) :: :done | :current | :upcoming
  def state(index, current) when index < current, do: :done
  def state(index, current) when index == current, do: :current
  def state(_index, _current), do: :upcoming
end
