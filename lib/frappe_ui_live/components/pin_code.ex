defmodule FrappeUILive.Components.PinCode do
  @moduledoc """
  Código de verificação / PIN: uma caixa por caractere, com avanço automático,
  Backspace que volta, setas, colar o código inteiro e preenchimento por SMS
  (`autocomplete="one-time-code"`).

  O valor é **um único campo** (`name` do `field`, ou `name` avulso) com o código
  completo; as caixas não têm `name`, então nada parcial é enviado. Aceita
  `field={@form[:codigo]}` (valor e erros do changeset) e funciona dentro de um
  `phx-change`/`phx-submit`. Com `on_complete="evento"` o servidor recebe
  `%{"id" => id, "value" => código}` assim que todas as caixas são preenchidas.

      <.pin_code id="otp" field={@form[:codigo]} length={6} on_complete="verificar" />

  `type`: `:numeric` (padrão, teclado numérico) ou `:alphanumeric`. `mask` esconde
  os caracteres (como senha). O que o navegador envia continua sendo entrada de
  usuário: valide o código no servidor (`sanitize/2` aplica a mesma regra do cliente).
  """
  use Phoenix.Component

  alias FrappeUILive.Components.InputStyle
  alias FrappeUILive.{Contract, Field, Texts}

  @types ~w(numeric alphanumeric)a
  @lengths 3..12

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any

  attr :length, :integer,
    default: 6,
    doc: "quantidade de caracteres (#{inspect(@lengths)})"

  attr :type, :atom, default: :numeric, values: @types
  attr :mask, :boolean, default: false, doc: "esconde os caracteres, como uma senha"

  attr :on_complete, :string,
    default: nil,
    doc: "evento enviado ao servidor com o código quando todas as caixas estão preenchidas"

  attr :variant, :atom, default: :subtle, values: InputStyle.variants()
  attr :size, :atom, default: :md, values: InputStyle.sizes()
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(autofocus form)

  def pin_code(assigns) do
    Contract.require!(assigns.length, @lengths, "pin_code length")
    Contract.require!(assigns.type, @types, "pin_code type")
    Contract.require!(assigns.variant, InputStyle.variants(), "pin_code variant")
    Contract.require!(assigns.size, InputStyle.sizes(), "pin_code size")
    assigns = Field.assign_field(assigns)
    Field.require_id!(assigns, "pin_code")

    chars = cells(assigns.value, assigns.length, assigns.type)

    assigns =
      assigns
      |> assign(:chars, Enum.with_index(chars))
      |> assign(:joined, Enum.join(chars))
      |> assign(:cell_class, [
        InputStyle.classes(assigns.variant, assigns.size,
          invalid: assigns.errors != [],
          disabled: assigns.disabled,
          class: "w-10 px-0 text-center"
        )
      ])

    ~H"""
    <div
      id={@id}
      phx-hook=".PinCode"
      role="group"
      aria-label={Texts.t(:pin_code)}
      data-length={@length}
      data-type={@type}
      data-on-complete={@on_complete}
      class={["flex gap-2", @class]}
      {@rest}
    >
      <input type="hidden" id={"#{@id}-value"} name={@name} value={@joined} data-pin-value />
      <input
        :for={{char, index} <- @chars}
        type={if @mask, do: "password", else: "text"}
        value={char}
        maxlength={if index == 0, do: @length, else: 1}
        inputmode={if @type == :numeric, do: "numeric", else: "text"}
        autocomplete={if index == 0, do: "one-time-code", else: "off"}
        autocapitalize="off"
        spellcheck="false"
        disabled={@disabled}
        aria-label={Texts.t(:pin_digit, n: index + 1, total: @length)}
        aria-invalid={@errors != [] && "true"}
        class={@cell_class}
        data-pin-cell
      />
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".PinCode">
      // Regra de caracteres aceitos: espelho de FrappeUILive.Components.PinCode.sanitize/2.
      const REJECT = {numeric: /[^0-9]/g, alphanumeric: /[^A-Za-z0-9]/g}

      export default {
        mounted() {
          this.hidden = this.el.querySelector("[data-pin-value]")
          this.el.addEventListener("input", (event) => this.onInput(event), true)
          this.el.addEventListener("keydown", (event) => this.onKeydown(event))
          this.el.addEventListener("paste", (event) => this.onPaste(event))
          this.el.addEventListener("focusin", (event) => {
            if (event.target.matches("[data-pin-cell]")) event.target.select()
          })
        },
        cells() { return Array.from(this.el.querySelectorAll("[data-pin-cell]")) },
        clean(text) { return text.replace(REJECT[this.el.dataset.type] || REJECT.numeric, "") },
        // Espalha `text` a partir da caixa `from`; foca a próxima vazia (ou a última).
        fill(text, from) {
          const cells = this.cells()
          const chars = Array.from(this.clean(text)).slice(0, cells.length - from)
          chars.forEach((char, i) => { cells[from + i].value = char })
          const next = Math.min(from + chars.length, cells.length - 1)
          cells[next].focus()
          this.sync()
        },
        onInput(event) {
          if (event.target === this.hidden) return
          // As caixas não têm name: o phx-change só enxerga o campo oculto.
          event.stopPropagation()
          const cells = this.cells()
          const index = cells.indexOf(event.target)
          if (index < 0) return
          const text = event.target.value
          event.target.value = ""
          this.fill(text, index)
        },
        onKeydown(event) {
          const cells = this.cells()
          const index = cells.indexOf(event.target)
          if (index < 0) return
          if (event.key === "Backspace" && event.target.value === "" && index > 0) {
            event.preventDefault()
            cells[index - 1].value = ""
            cells[index - 1].focus()
            this.sync()
          } else if (event.key === "ArrowLeft" && index > 0) {
            event.preventDefault()
            cells[index - 1].focus()
          } else if (event.key === "ArrowRight" && index < cells.length - 1) {
            event.preventDefault()
            cells[index + 1].focus()
          }
        },
        onPaste(event) {
          const index = this.cells().indexOf(event.target)
          if (index < 0) return
          event.preventDefault()
          this.fill(event.clipboardData.getData("text"), 0)
        },
        sync() {
          const value = this.cells().map((cell) => cell.value).join("")
          this.hidden.value = value
          this.hidden.dispatchEvent(new Event("input", {bubbles: true}))
          const event = this.el.dataset.onComplete
          if (event && value.length === this.cells().length) {
            this.pushEvent(event, {id: this.el.id, value: value})
          }
        }
      }
    </script>
    """
  end

  @doc """
  Mantém só os caracteres aceitos pelo `type` (`:numeric` ou `:alphanumeric`).
  Mesma regra do hook no cliente; use no servidor para validar o código recebido.
  """
  @spec sanitize(term(), :numeric | :alphanumeric) :: String.t()
  def sanitize(value, type \\ :numeric)
  def sanitize(value, :numeric) when is_binary(value), do: String.replace(value, ~r/[^0-9]/, "")

  def sanitize(value, :alphanumeric) when is_binary(value),
    do: String.replace(value, ~r/[^A-Za-z0-9]/, "")

  def sanitize(value, type) when is_integer(value),
    do: value |> Integer.to_string() |> sanitize(type)

  def sanitize(_value, _type), do: ""

  @doc """
  Caracteres por caixa: o valor limpo, cortado em `length` e completado com `""`.
  """
  @spec cells(term(), pos_integer(), :numeric | :alphanumeric) :: [String.t()]
  def cells(value, length, type) do
    chars = value |> sanitize(type) |> String.graphemes() |> Enum.take(length)
    chars ++ List.duplicate("", length - Kernel.length(chars))
  end
end
