defmodule FrappeUIPhx.Components.CodeEditor do
  @moduledoc """
  Editor de código: `<textarea>` monoespaçado com numeração de linhas, tecla Tab
  que indenta e rótulo da linguagem. É um campo de formulário comum (`name`,
  `phx-change`, `field`).

  Limite desta versão: **sem realce de sintaxe** (isso exigiria CodeMirror e seu
  conjunto de dependências JS); o atributo `language` só rotula e vai em
  `data-language` para quem quiser plugar um realçador.
  """
  use Phoenix.Component

  alias FrappeUIPhx.{Contract, Field}

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :language, :string, default: "text", doc: "rótulo (ex.: \"json\", \"elixir\")"
  attr :rows, :integer, default: 10
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(form required placeholder)

  def code_editor(assigns) do
    Contract.ensure!(
      Regex.match?(~r/\A[\w+#.-]{1,24}\z/, assigns.language),
      "code_editor: language inválida: #{inspect(assigns.language)}"
    )

    Contract.ensure!(assigns.rows in 1..200, "code_editor: rows deve estar entre 1 e 200")
    assigns = assigns |> Field.assign_field() |> Field.require_id!("code_editor")
    text = to_string(assigns.value || "")
    assigns = assigns |> assign(:text, text) |> assign(:lines, line_count(text))

    ~H"""
    <div
      id={@id && "#{@id}-wrapper"}
      phx-hook=".CodeEditor"
      data-language={@language}
      class={[
        "bg-surface-gray-1 rounded-5 border font-mono",
        @errors == [] && "border-outline-gray-2 focus-within:border-outline-gray-4",
        @errors != [] && "border-outline-red-3",
        @class
      ]}
    >
      <div class="border-outline-gray-2 text-ink-gray-5 fui-text-xs flex items-center justify-between border-b px-3 py-1">
        <span>{@language}</span>
        <span data-line-count>{@lines} {if @lines == 1, do: "linha", else: "linhas"}</span>
      </div>
      <div class="flex">
        <pre
          data-gutter
          aria-hidden="true"
          class="text-ink-gray-4 fui-text-sm select-none px-2 py-2 text-right leading-5"
        >{gutter(@lines)}</pre>
        <textarea
          id={@id}
          name={@name}
          rows={@rows}
          disabled={@disabled}
          spellcheck="false"
          autocapitalize="off"
          aria-invalid={@errors != [] && "true"}
          class="text-ink-gray-8 fui-text-sm min-w-0 flex-1 resize-y bg-transparent px-2 py-2 leading-5 whitespace-pre focus:outline-none"
          {@rest}
        >{Phoenix.HTML.Form.normalize_value("textarea", @text)}</textarea>
      </div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".CodeEditor">
      export default {
        mounted() {
          this.area = this.el.querySelector("textarea")
          this.gutter = this.el.querySelector("[data-gutter]")
          this.count = this.el.querySelector("[data-line-count]")
          this.area.addEventListener("input", () => this.refresh())
          this.area.addEventListener("scroll", () => { this.gutter.style.transform = "translateY(" + -this.area.scrollTop + "px)" })
          this.area.addEventListener("keydown", (event) => {
            if (event.key !== "Tab" || event.shiftKey) return
            event.preventDefault() // Tab indenta em vez de sair do campo
            document.execCommand("insertText", false, "  ")
          })
        },
        updated() {
          this.refresh()
        },
        refresh() {
          const lines = this.area.value.split("\n").length
          this.gutter.textContent = Array.from({length: lines}, (_, i) => i + 1).join("\n")
          this.count.textContent = lines + (lines === 1 ? " linha" : " linhas")
        }
      }
    </script>
    """
  end

  @doc "Quantidade de linhas do texto (mínimo 1)."
  @spec line_count(String.t()) :: pos_integer()
  def line_count(""), do: 1
  def line_count(text), do: text |> String.split("\n") |> length()

  @doc "Numeração das linhas, uma por linha."
  @spec gutter(pos_integer()) :: String.t()
  def gutter(lines), do: Enum.map_join(1..lines, "\n", &Integer.to_string/1)
end
