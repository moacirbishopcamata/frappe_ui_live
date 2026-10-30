defmodule FrappeUILive.Components.ThemeSwitcher do
  @moduledoc """
  Alternador claro/escuro. Cada opção é um link `?theme=…` tratado por
  `FrappeUILive.Plug.Theme`, que persiste a escolha em sessão e cookie; o tema
  atual (`current`) vem do servidor (`@frappe_ui_theme`). Experimental.
  """
  use Phoenix.Component

  alias FrappeUILive.Texts

  alias FrappeUILive.Components.Icon
  alias FrappeUILive.Contract
  alias FrappeUILive.Plug.Theme

  @icons %{"light" => "sun", "dark" => "moon"}
  @labels %{"light" => :theme_light, "dark" => :theme_dark}

  attr :current, :string, required: true, doc: "tema ativo: \"light\" ou \"dark\""
  attr :param, :string, default: "theme", doc: "nome do parâmetro lido pelo Plug"
  attr :class, :any, default: nil
  attr :rest, :global

  def theme_switcher(assigns) do
    Contract.require!(assigns.current, Theme.themes(), "theme_switcher current")
    assigns = assigns |> assign(:themes, Theme.themes()) |> assign(:icons, @icons)

    ~H"""
    <div
      role="group"
      aria-label={Texts.t(:theme)}
      class={["bg-surface-gray-2 inline-flex gap-0.5 rounded-5 p-0.5", @class]}
      {@rest}
    >
      <.link
        :for={theme <- @themes}
        href={href(@param, theme)}
        aria-pressed={to_string(theme == @current)}
        title={label(theme)}
        class={[
          "fui-text-base focus-visible:focus-ring inline-flex items-center gap-1.5 rounded-4 px-2.5 py-1",
          theme == @current && "bg-surface-base text-ink-gray-9 shadow-elevation-sm",
          theme != @current && "text-ink-gray-6 hover:text-ink-gray-8"
        ]}
      >
        <Icon.icon name={Map.fetch!(@icons, theme)} class="size-4" />{label(theme)}
      </.link>
    </div>
    """
  end

  @doc "Link relativo que aplica o tema (`\"?theme=dark\"`)."
  @spec href(String.t(), String.t()) :: String.t()
  def href(param, theme), do: "?#{URI.encode_www_form(param)}=#{theme}"

  defp label(theme), do: Texts.t(Map.fetch!(@labels, theme))
end
