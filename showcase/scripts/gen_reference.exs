# Gera ../docs/componentes.md (referência de atributos e slots) a partir do código real.
# Uso, dentro de showcase/: `mix run scripts/gen_reference.exs`
#
# A fonte é `Showcase.Spec` (lê `attr`/`slot` declarados e o @moduledoc), então a
# referência nunca diverge dos componentes. Não edite o arquivo gerado à mão.

alias FrappeUIPhx.Components, as: Catalog
alias Showcase.Spec

cell = fn text ->
  (text || "")
  |> to_string()
  |> String.replace("\n", " ")
  |> String.replace("|", "\\|")
  |> String.trim()
end

type = fn
  {:struct, module} -> inspect(module)
  type when is_atom(type) -> Atom.to_string(type)
  type -> inspect(type)
end

default = fn
  nil -> "—"
  value -> "`" <> cell.(inspect(value, limit: 6, printable_limit: 40)) <> "`"
end

values = fn
  nil -> ""
  list when length(list) > 12 -> "#{length(list)} valores (veja a documentação do módulo)"
  list -> list |> Enum.map_join(", ", &("`" <> cell.(inspect(&1)) <> "`"))
end

summary = fn doc ->
  doc |> String.trim() |> String.split("\n\n") |> List.first() |> Kernel.||("") |> String.replace("\n", " ")
end

component = fn spec ->
  attrs = Enum.reject(spec.attrs, &(&1.name == :rest))
  has_rest? = Enum.any?(spec.attrs, &(&1.name == :rest))

  attr_table =
    if attrs == [] do
      "_Sem atributos próprios._\n"
    else
      rows =
        for a <- attrs do
          "| `#{a.name}` | #{cell.(type.(a.type))} | #{if a.required, do: "sim", else: "não"} | #{default.(a.default)} | #{values.(a.values)} | #{cell.(a.doc)} |"
        end

      Enum.join(
        ["| Atributo | Tipo | Obrigatório | Padrão | Valores | Descrição |", "|---|---|---|---|---|---|" | rows],
        "\n"
      ) <> "\n"
    end

  slot_part =
    if spec.slots == [] do
      ""
    else
      items =
        for s <- spec.slots do
          attrs =
            case s.attrs do
              [] -> ""
              list -> " — atributos: " <> Enum.map_join(list, ", ", &"`#{&1.name}#{if &1.required, do: "*"}`")
            end

          "- `:#{s.name}`#{if s.required, do: " (obrigatório)"}#{if s.doc, do: ": " <> cell.(s.doc)}#{attrs}"
        end

      "\n**Slots**\n\n" <> Enum.join(items, "\n") <> "\n"
    end

  """
  ### #{spec.title}

  `#{inspect(spec.module)}.#{spec.fun}/1` — #{summary.(spec.doc)}

  #{attr_table}#{if has_rest?, do: "\nAceita atributos HTML globais (`class`, `id`, `data-*`, `phx-*`...).\n", else: ""}#{slot_part}
  """
end

body =
  for {category, title} <- Catalog.categories() do
    specs = Spec.all() |> Enum.filter(&(&1.category == category))
    "## #{title}\n\n" <> Enum.map_join(specs, "\n", component)
  end

toc =
  for {_category, title} <- Catalog.categories() do
    "- [#{title}](##{title |> String.downcase() |> String.replace(~r/[^\p{L}\p{N} -]/u, "") |> String.replace(" ", "-")})"
  end

content =
  """
  # Referência de componentes

  > Gerado do código por `showcase/scripts/gen_reference.exs` (`cd showcase && mix run scripts/gen_reference.exs`).
  > Não edite à mão: atributos, tipos, padrões e slots vêm dos `attr`/`slot` reais.
  > Para ver cada componente funcionando, rode o mostruário (veja o [README](../README.md)).

  #{Enum.join(toc, "\n")}

  """ <> Enum.join(body, "\n")

File.mkdir_p!("../docs")
File.write!("../docs/componentes.md", String.replace(content, ~r/\n{3,}/, "\n\n"))
IO.puts("docs/componentes.md: #{length(Spec.all())} componentes")
