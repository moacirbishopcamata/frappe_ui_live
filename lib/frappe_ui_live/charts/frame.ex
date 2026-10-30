defmodule FrappeUILive.Charts.Frame do
  @moduledoc """
  Moldura comum dos gráficos com os estados `:loading`, `:empty` e `:error`
  (visualmente distintos); no estado `:ready` mostra o gráfico.
  """
  use Phoenix.Component

  alias FrappeUILive.Texts

  alias FrappeUILive.Components.{Alert, Skeleton}

  @doc "Estado a partir dos atributos de um gráfico (erro vence carregamento, que vence vazio)."
  @spec state(boolean(), String.t() | nil, boolean()) :: :ready | :loading | :empty | :error
  def state(_loading, error, _empty?) when is_binary(error) and error != "", do: :error
  def state(true, _error, _empty?), do: :loading
  def state(_loading, _error, true), do: :empty
  def state(_loading, _error, _empty?), do: :ready

  attr :state, :atom, required: true, values: ~w(ready loading empty error)a
  attr :error, :string, default: nil
  attr :empty_text, :string, default: nil
  attr :height, :integer, default: 240
  slot :inner_block, required: true

  def chart_frame(assigns) do
    assigns = assign(assigns, :empty_text, assigns.empty_text || Texts.t(:chart_empty))

    ~H"""
    <div :if={@state == :ready}>{render_slot(@inner_block)}</div>
    <div :if={@state == :loading} data-chart-state="loading" aria-busy="true">
      <Skeleton.skeleton class="w-full" style={"height: #{@height}px"} />
    </div>
    <div
      :if={@state == :empty}
      data-chart-state="empty"
      class="border-outline-gray-2 text-ink-gray-5 fui-text-base flex items-center justify-center rounded-5 border border-dashed"
      style={"height: #{@height}px"}
    >
      {@empty_text}
    </div>
    <Alert.alert :if={@state == :error} theme={:red} title={Texts.t(:chart_error_title)}>
      {@error}
    </Alert.alert>
    """
  end
end
