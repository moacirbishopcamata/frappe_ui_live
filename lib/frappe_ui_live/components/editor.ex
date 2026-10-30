defmodule FrappeUILive.Components.Editor do
  @moduledoc """
  Editor de texto rico (negrito, itálico, título, listas, código, link) que
  guarda **Markdown** num `<input type=hidden>`, então participa do formulário e
  do `phx-change` como qualquer campo.

  Por segurança o valor nunca é HTML: o cliente converte o DOM para Markdown e o
  servidor renderiza o conteúdo inicial por `FrappeUILive.Markdown.to_html/1`
  (texto escapado, só links `http(s)`/`mailto:`/relativos). Para exibir o texto
  salvo, use o mesmo `to_html/1`.

  Limites: usa `document.execCommand` (suporte amplo, mas API legada); sem
  tabelas/imagens nesta versão.
  """
  use Phoenix.Component

  alias FrappeUILive.Components.Icon
  alias FrappeUILive.{Field, Markdown}

  @commands [
    {"bold", "bold", "Negrito"},
    {"italic", "italic", "Itálico"},
    {"heading", "heading-2", "Título"},
    {"ul", "list", "Lista"},
    {"ol", "list-ordered", "Lista numerada"},
    {"code", "code", "Código"},
    {"link", "link", "Link"}
  ]

  attr :field, Phoenix.HTML.FormField, default: nil
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :placeholder, :string, default: "Escreva aqui…"
  attr :errors, :list, default: []
  attr :disabled, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(form)

  def editor(assigns) do
    assigns = Field.assign_field(assigns)
    markdown = to_string(assigns.value || "")

    assigns =
      assigns
      |> assign(:markdown, markdown)
      |> assign(:html, Phoenix.HTML.raw(Markdown.to_html(markdown)))
      |> assign(:commands, @commands)

    ~H"""
    <div
      id={@id}
      phx-hook=".Editor"
      data-disabled={to_string(@disabled)}
      class={[
        "bg-surface-base rounded-5 border",
        @errors == [] && "border-outline-gray-2 focus-within:border-outline-gray-4",
        @errors != [] && "border-outline-red-3",
        @class
      ]}
    >
      <div
        role="toolbar"
        aria-label="Formatação"
        class="border-outline-gray-2 flex gap-0.5 border-b p-1"
      >
        <button
          :for={{command, icon, label} <- @commands}
          type="button"
          data-command={command}
          title={label}
          aria-label={label}
          disabled={@disabled}
          class="text-ink-gray-6 hover:bg-surface-gray-3 hover:text-ink-gray-9 rounded-3 p-1.5 disabled:opacity-50"
        >
          <Icon.icon name={icon} class="size-4" />
        </button>
      </div>

      <input type="hidden" name={@name} value={@markdown} data-markdown {@rest} />
      <%!-- o servidor pode redefinir o valor: o hook copia este template para a área editável --%>
      <template data-html>{@html}</template>
      <div
        id={"#{@id}-area"}
        phx-update="ignore"
        data-editable
        contenteditable={to_string(!@disabled)}
        role="textbox"
        aria-multiline="true"
        aria-invalid={@errors != [] && "true"}
        data-placeholder={@placeholder}
        class="fui-text-p-base text-ink-gray-8 min-h-32 px-3 py-2 focus:outline-none [&_a]:text-ink-blue-link [&_a]:underline [&_code]:bg-surface-gray-2 [&_code]:rounded-3 [&_code]:px-1 [&_h2]:text-lg [&_h2]:font-semibold [&_ol]:list-decimal [&_ol]:pl-5 [&_p]:my-1 [&_ul]:list-disc [&_ul]:pl-5"
      >
        {@html}
      </div>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".Editor">
      // <md-converter>
      function domToMarkdown(root) {
        const inline = (node) => {
          if (node.nodeType === 3) return node.textContent
          if (node.nodeType !== 1) return ""
          const inner = Array.from(node.childNodes).map(inline).join("")
          switch (node.nodeName) {
            case "B": case "STRONG": return inner ? "**" + inner + "**" : ""
            case "I": case "EM": return inner ? "_" + inner + "_" : ""
            case "CODE": return inner ? "`" + inner + "`" : ""
            case "BR": return "\n"
            case "A": {
              const href = node.getAttribute("href") || ""
              return /^(https?:\/\/|mailto:|\/(?!\/))/i.test(href) ? "[" + inner + "](" + href + ")" : inner
            }
            default: return inner
          }
        }
        const blocks = []
        const walk = (node) => {
          if (node.nodeType === 3) { if (node.textContent.trim()) blocks.push(node.textContent.trim()); return }
          if (node.nodeType !== 1) return
          switch (node.nodeName) {
            case "H1": case "H2": case "H3": case "H4": case "H5": case "H6":
              blocks.push("## " + inline(node).trim()); break
            case "UL":
              blocks.push(Array.from(node.childNodes).filter((c) => c.nodeName === "LI").map((li) => "- " + inline(li).trim()).join("\n")); break
            case "OL":
              blocks.push(Array.from(node.childNodes).filter((c) => c.nodeName === "LI").map((li, i) => (i + 1) + ". " + inline(li).trim()).join("\n")); break
            case "P": case "DIV": {
              const hasBlock = Array.from(node.childNodes).some((c) => ["P", "DIV", "UL", "OL", "H1", "H2", "H3"].includes(c.nodeName))
              if (hasBlock) Array.from(node.childNodes).forEach(walk)
              else if (inline(node).trim()) blocks.push(inline(node).trim())
              break
            }
            default:
              if (inline(node).trim()) blocks.push(inline(node).trim())
          }
        }
        Array.from(root.childNodes).forEach(walk)
        return blocks.join("\n\n")
      }
      // </md-converter>

      const SAFE_URL = /^(https?:\/\/|mailto:|\/(?!\/))/i

      export default {
        mounted() {
          this.area = this.el.querySelector("[data-editable]")
          this.hidden = this.el.querySelector("input[data-markdown]")
          this.last = this.hidden.value

          this.area.addEventListener("input", () => this.emit())
          // cola só texto puro: nada de HTML externo entra no editor
          this.area.addEventListener("paste", (event) => {
            event.preventDefault()
            const text = (event.clipboardData || window.clipboardData).getData("text/plain")
            document.execCommand("insertText", false, text)
          })

          this.el.querySelectorAll("[data-command]").forEach((button) => {
            button.addEventListener("mousedown", (event) => event.preventDefault()) // mantém a seleção
            button.addEventListener("click", () => this.run(button.dataset.command))
          })
        },
        updated() {
          // o servidor redefiniu o valor (ex.: reset do formulário): sincroniza a área editável
          if (this.hidden.value !== this.last) {
            this.area.innerHTML = this.el.querySelector("template[data-html]").innerHTML
            this.last = this.hidden.value
          }
        },
        emit() {
          this.last = domToMarkdown(this.area)
          this.hidden.value = this.last
          this.hidden.dispatchEvent(new Event("input", {bubbles: true}))
        },
        run(command) {
          this.area.focus()
          switch (command) {
            case "bold": document.execCommand("bold"); break
            case "italic": document.execCommand("italic"); break
            case "heading": document.execCommand("formatBlock", false, "h2"); break
            case "ul": document.execCommand("insertUnorderedList"); break
            case "ol": document.execCommand("insertOrderedList"); break
            case "code": {
              const text = window.getSelection().toString()
              if (text) document.execCommand("insertText", false, "`" + text + "`")
              break
            }
            case "link": {
              const url = window.prompt("Endereço do link (https://…)")
              if (url && SAFE_URL.test(url)) document.execCommand("createLink", false, url)
              break
            }
          }
          this.emit()
        }
      }
    </script>
    """
  end
end
