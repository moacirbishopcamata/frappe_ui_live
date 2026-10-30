defmodule ShowcaseWeb.CatalogLive do
  @moduledoc """
  Mostruário navegável: índice por categoria, e por componente um *playground*
  (formulário gerado da especificação real + prévia ao vivo + trecho de uso) e a
  tabela de especificação (atributos e slots lidos do código).

  Todo o estado (valores do formulário, aba, tema) vive no servidor.
  """
  use Phoenix.LiveView
  use FrappeUILive

  alias FrappeUILive.{Foundations, Spec, Toast}
  alias FrappeUILive.Components, as: Catalog
  alias FrappeUILive.Components.Sortable
  alias ShowcaseWeb.{FoundationsView, Samples, Snippet}

  @tabs ~w(playground spec)

  @impl true
  def mount(_params, _session, socket) do
    specs = Spec.all()

    {:ok,
     socket
     |> assign(:specs, Map.new(specs, &{Atom.to_string(&1.id), &1}))
     |> assign(:groups, groups(specs))
     |> assign(spec: nil, foundation: nil, tab: "playground", page_title: "Componentes")
     |> assign(attrs: %{}, params: %{}, form: to_form(%{}, as: :pg))
     |> assign(demo: Samples.demo_state(), saved_at: nil)
     |> allow_upload(:demo,
       accept: ~w(.png .jpg .jpeg .pdf),
       max_entries: 2,
       max_file_size: 2_000_000
     )}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, %{assigns: %{live_action: :foundation}} = socket) do
    case Enum.find(Foundations.sections(), &(Atom.to_string(&1.id) == id)) do
      nil ->
        {:noreply,
         socket |> put_flash(:error, "Fundamento desconhecido: #{id}") |> push_navigate(to: "/")}

      section ->
        {:noreply, assign(socket, spec: nil, foundation: section, page_title: section.title)}
    end
  end

  def handle_params(%{"id" => id} = params, _uri, socket) do
    case Map.fetch(socket.assigns.specs, id) do
      {:ok, spec} ->
        {:noreply, socket |> assign(:foundation, nil) |> show(spec, tab(params))}

      :error ->
        {:noreply,
         socket |> put_flash(:error, "Componente desconhecido: #{id}") |> push_navigate(to: "/")}
    end
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, spec: nil, foundation: nil, page_title: "Componentes")}
  end

  @impl true
  def handle_event("playground", %{"pg" => pg}, socket) do
    {:noreply, put_attrs(socket, Spec.cast(socket.assigns.spec, pg), pg)}
  end

  def handle_event("reset", _params, socket), do: {:noreply, reset(socket, socket.assigns.spec)}

  def handle_event("pg_tab", %{"tab" => tab}, socket) do
    attrs = Map.put(socket.assigns.attrs, :active, tab)
    {:noreply, put_attrs(socket, attrs, to_params(attrs))}
  end

  def handle_event("toast", %{"kind" => kind}, socket) do
    case Enum.find(Toast.kinds(), &(Atom.to_string(&1) == kind)) do
      nil -> {:noreply, socket}
      kind -> {:noreply, Toast.put_toast(socket, kind, "Toast #{kind} enviado pelo servidor")}
    end
  end

  def handle_event("saved", _params, socket) do
    {:noreply, assign(socket, :saved_at, System.unique_integer([:positive, :monotonic]))}
  end

  def handle_event("sel", %{"id" => id}, socket) do
    with {:ok, id} <- known_id(socket.assigns.demo.rows, id) do
      selected = socket.assigns.demo.selected
      selected = if id in selected, do: List.delete(selected, id), else: selected ++ [id]
      {:noreply, update(socket, :demo, &%{&1 | selected: selected})}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("reorder", %{"id" => id, "to" => to, "position" => position}, socket) do
    {:noreply,
     update(
       socket,
       :demo,
       &%{&1 | rows: Sortable.move(&1.rows, fn r -> r.id end, id, to, position)}
     )}
  end

  def handle_event("reorder_items", %{"id" => id, "to" => to, "position" => position}, socket) do
    {:noreply,
     update(
       socket,
       :demo,
       &%{&1 | items: Sortable.move(&1.items, fn r -> r.id end, id, to, position)}
     )}
  end

  def handle_event("tog", %{"id" => id}, socket) do
    case Integer.parse(id) do
      {id, ""} ->
        expanded = socket.assigns.demo.expanded
        expanded = if id in expanded, do: List.delete(expanded, id), else: expanded ++ [id]
        {:noreply, update(socket, :demo, &%{&1 | expanded: expanded})}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("tsel", %{"id" => id}, socket) do
    case Integer.parse(id) do
      {id, ""} -> {:noreply, update(socket, :demo, &%{&1 | tree_selected: id})}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("validate-upload", _params, socket), do: {:noreply, socket}
  def handle_event("noop", _params, socket), do: {:noreply, socket}

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :demo, ref)}
  end

  def handle_event("cal_prev", _params, socket), do: {:noreply, shift_month(socket, -1)}
  def handle_event("cal_next", _params, socket), do: {:noreply, shift_month(socket, 1)}

  def handle_event("cal_today", _params, socket) do
    {:noreply, update(socket, :demo, &%{&1 | month: Date.utc_today(), day: Date.utc_today()})}
  end

  def handle_event("cal_select", %{"date" => iso}, socket) do
    case FrappeUILive.Calendar.to_date(iso) do
      %Date{} = date -> {:noreply, update(socket, :demo, &%{&1 | day: date})}
      nil -> {:noreply, socket}
    end
  end

  def handle_event("lv_toggle", %{"group" => group}, socket) do
    known = socket.assigns.demo.rows |> Enum.map(& &1.papel) |> Enum.uniq()

    if group in known do
      collapsed = socket.assigns.demo.collapsed

      collapsed =
        if group in collapsed, do: List.delete(collapsed, group), else: collapsed ++ [group]

      {:noreply, update(socket, :demo, &%{&1 | collapsed: collapsed})}
    else
      {:noreply, socket}
    end
  end

  def handle_event("step_go", %{"step" => step}, socket) do
    case Integer.parse(step) do
      {n, ""} when n in 0..3 ->
        attrs = Map.put(socket.assigns.attrs, :current, n)
        {:noreply, put_attrs(socket, attrs, to_params(attrs))}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("demo", _params, socket) do
    {:noreply, Toast.put_toast(socket, :info, "Evento recebido no servidor")}
  end

  # Evento desconhecido ou malformado (cliente forjado): ignora, nunca derruba o LiveView.
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  # ---- estado ----------------------------------------------------------------

  defp tab(%{"tab" => tab}) when tab in @tabs, do: tab
  defp tab(_), do: "playground"

  defp show(socket, spec, tab) do
    current = socket.assigns.spec

    socket = if current && current.id == spec.id, do: socket, else: reset(socket, spec)
    assign(socket, spec: spec, tab: tab, page_title: spec.title)
  end

  defp reset(socket, spec) do
    attrs = spec |> Spec.defaults() |> Map.merge(Samples.initial(spec.id))
    put_attrs(assign(socket, :spec, spec), attrs, to_params(attrs))
  end

  defp put_attrs(socket, attrs, params) do
    assign(socket, attrs: attrs, params: params, form: to_form(params, as: :pg))
  end

  defp shift_month(socket, delta) do
    update(socket, :demo, &%{&1 | month: FrappeUILive.Calendar.shift_month(&1.month, delta)})
  end

  defp known_id(rows, id) do
    with {int, ""} <- Integer.parse(id), true <- Enum.any?(rows, &(&1.id == int)) do
      {:ok, int}
    else
      _ -> :error
    end
  end

  defp to_params(attrs),
    do: Map.new(attrs, fn {key, value} -> {Atom.to_string(key), param(value)} end)

  defp param(nil), do: ""
  defp param(value) when is_binary(value), do: value
  defp param(value), do: to_string(value)

  defp groups(specs) do
    for {category, title} <- Catalog.categories() do
      {category, title, Enum.filter(specs, &(&1.category == category))}
    end
  end

  # ---- visão -----------------------------------------------------------------

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex min-h-screen">
      <aside class="border-outline-gray-2 bg-surface-sidebar w-60 shrink-0 border-r px-3 py-4">
        <.link patch="/" class="fui-text-lg-semibold text-ink-gray-9 mb-4 block px-2">
          Frappe UI Live
        </.link>
        <nav aria-label="Fundamentos" class="mb-4">
          <p class="fui-text-xs-medium text-ink-gray-5 mb-1 px-2 uppercase">Fundamentos</p>
          <.link
            :for={section <- Foundations.sections()}
            id={"nav-foundation-#{section.id}"}
            patch={"/f/#{section.id}"}
            aria-current={@foundation && @foundation.id == section.id && "page"}
            class={[
              "fui-text-base block rounded-4 px-2 py-1",
              @foundation && @foundation.id == section.id && "bg-surface-gray-3 text-ink-gray-9",
              !(@foundation && @foundation.id == section.id) &&
                "text-ink-gray-7 hover:bg-surface-gray-2"
            ]}
          >
            {section.title}
          </.link>
        </nav>
        <nav :for={{category, title, entries} <- @groups} aria-label={title} class="mb-4">
          <p class="fui-text-xs-medium text-ink-gray-5 mb-1 px-2 uppercase">{title}</p>
          <.link
            :for={entry <- entries}
            id={"nav-#{entry.id}"}
            patch={"/c/#{entry.id}"}
            data-category={category}
            aria-current={@spec && @spec.id == entry.id && "page"}
            class={[
              "fui-text-base block rounded-4 px-2 py-1",
              @spec && @spec.id == entry.id && "bg-surface-gray-3 text-ink-gray-9",
              !(@spec && @spec.id == entry.id) && "text-ink-gray-7 hover:bg-surface-gray-2"
            ]}
          >
            {entry.title}
          </.link>
        </nav>
      </aside>

      <main class="min-w-0 flex-1">
        <div class="border-outline-gray-2 flex items-center justify-end border-b px-5 py-2">
          <.button
            id="theme-toggle"
            href={"?theme=#{if @frappe_ui_theme == "dark", do: "light", else: "dark"}"}
            icon_left={if @frappe_ui_theme == "dark", do: "sun", else: "moon"}
            label={if @frappe_ui_theme == "dark", do: "Tema claro", else: "Tema escuro"}
          />
        </div>

        <.index :if={!@spec and !@foundation} groups={@groups} />
        <.foundation_page :if={@foundation} section={@foundation} />
        <.detail
          :if={@spec}
          spec={@spec}
          tab={@tab}
          form={@form}
          attrs={@attrs}
          extras={extras(assigns)}
          groups={@groups}
        />
      </main>
    </div>

    <.toast_container flash={@flash} />
    """
  end

  attr :section, :map, required: true

  defp foundation_page(assigns) do
    ~H"""
    <.page_header title={@section.title} subtitle={@section.summary}>
      <:breadcrumbs>
        <.breadcrumbs>
          <:item label="Fundamentos" patch="/" />
          <:item label={@section.title} />
        </.breadcrumbs>
      </:breadcrumbs>
    </.page_header>
    <div class="p-5"><FoundationsView.section id={@section.id} /></div>
    """
  end

  attr :groups, :list, required: true

  defp index(assigns) do
    assigns = assign(assigns, :foundations, Foundations.sections())

    ~H"""
    <.page_header
      title="Componentes"
      subtitle="Escolha um componente para ver o playground e a especificação."
    />
    <div class="space-y-8 p-5">
      <section id="index-foundations">
        <h2 class="fui-text-lg-semibold text-ink-gray-9 mb-3">Fundamentos</h2>
        <div class="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
          <.link
            :for={section <- @foundations}
            patch={"/f/#{section.id}"}
            id={"card-foundation-#{section.id}"}
            class="border-outline-gray-2 bg-surface-base hover:bg-surface-gray-1 rounded-6 border p-4 transition-colors"
          >
            <p class="fui-text-base-medium text-ink-gray-9">{section.title}</p>
            <p class="fui-text-p-sm text-ink-gray-5 mt-1 line-clamp-2">{section.summary}</p>
          </.link>
        </div>
      </section>
      <section :for={{_category, title, entries} <- @groups}>
        <h2 class="fui-text-lg-semibold text-ink-gray-9 mb-3">{title}</h2>
        <div class="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
          <.link
            :for={entry <- entries}
            patch={"/c/#{entry.id}"}
            id={"card-#{entry.id}"}
            class="border-outline-gray-2 bg-surface-base hover:bg-surface-gray-1 rounded-6 border p-4 transition-colors"
          >
            <p class="fui-text-base-medium text-ink-gray-9">{entry.title}</p>
            <p class="fui-text-p-sm text-ink-gray-5 mt-1 line-clamp-2">{summary(entry.doc)}</p>
            <p class="fui-text-xs text-ink-gray-4 mt-2">
              {length(Enum.filter(entry.attrs, & &1.editable))} atributos editáveis · {length(
                entry.slots
              )} slots
            </p>
          </.link>
        </div>
      </section>
    </div>
    """
  end

  attr :spec, :map, required: true
  attr :tab, :string, required: true
  attr :form, :any, required: true
  attr :attrs, :map, required: true
  attr :extras, :map, required: true
  attr :groups, :list, required: true

  defp detail(assigns) do
    assigns =
      assign(assigns, :category_title, category_title(assigns.groups, assigns.spec.category))

    ~H"""
    <.page_header title={@spec.title} subtitle={@spec.module |> inspect()}>
      <:breadcrumbs>
        <.breadcrumbs>
          <:item label="Componentes" patch="/" />
          <:item label={@category_title} />
          <:item label={@spec.title} />
        </.breadcrumbs>
      </:breadcrumbs>
    </.page_header>

    <div class="p-5">
      <.tabs id="views" active={@tab}>
        <:tab id="playground" label="Playground" patch={"/c/#{@spec.id}?tab=playground"} />
        <:tab id="spec" label="Especificação" patch={"/c/#{@spec.id}?tab=spec"} />

        <.playground
          :if={@tab == "playground"}
          spec={@spec}
          form={@form}
          attrs={@attrs}
          extras={@extras}
        />
        <.specification :if={@tab == "spec"} spec={@spec} />
      </.tabs>
    </div>
    """
  end

  attr :spec, :map, required: true
  attr :form, :any, required: true
  attr :attrs, :map, required: true
  attr :extras, :map, required: true

  defp playground(assigns) do
    assigns =
      assigns
      |> assign(:preview, Samples.render(assigns.spec, assigns.attrs, assigns.extras))
      |> assign(:snippet, Snippet.build(assigns.spec, assigns.attrs))

    ~H"""
    <div class="grid gap-6 lg:grid-cols-[18rem_minmax(0,1fr)]">
      <.form for={@form} id="playground-form" phx-change="playground" class="space-y-3">
        <p class="fui-text-sm text-ink-gray-5">
          Os campos abaixo vêm dos <code>attr</code> reais do componente.
        </p>
        <.playground_field :for={attr <- Spec.editable(@spec)} attr={attr} field={@form[attr.name]} />
        <.button
          type="button"
          id="playground-reset"
          label="Reiniciar"
          icon_left="rotate-ccw"
          phx-click="reset"
        />
      </.form>

      <div class="min-w-0 space-y-4">
        <div id="preview" class="border-outline-gray-2 bg-surface-base rounded-6 min-h-32 border p-6">
          <%= case @preview do %>
            <% {:ok, html} -> %>
              {html}
            <% {:live, rendered} -> %>
              {rendered}
            <% {:error, message} -> %>
              <.alert theme={:red} title="Contrato violado (falha alto, não renderiza errado)">
                {message}
              </.alert>
          <% end %>
        </div>
        <div>
          <p class="fui-text-sm-medium text-ink-gray-6 mb-1">Uso</p>
          <pre
            id="snippet"
            class="bg-surface-gray-2 text-ink-gray-8 rounded-5 overflow-x-auto p-3 fui-text-sm"
          ><code>{@snippet}</code></pre>
        </div>
      </div>
    </div>
    """
  end

  attr :attr, :map, required: true
  attr :field, Phoenix.HTML.FormField, required: true

  defp playground_field(assigns) do
    ~H"""
    <.form_control
      field={@field}
      label={Atom.to_string(@attr.name)}
      description={@attr.doc}
      required={@attr.required}
      {field_props(@attr)}
    />
    """
  end

  defp field_props(%{type: :boolean}), do: [type: "checkbox"]
  defp field_props(%{type: :integer}), do: [type: "number"]

  defp field_props(%{type: :atom, values: values}) when is_list(values),
    do: [type: "select", options: Enum.map(values, &{Atom.to_string(&1), Atom.to_string(&1)})]

  defp field_props(_), do: [type: "text"]

  attr :spec, :map, required: true

  defp specification(assigns) do
    ~H"""
    <div class="space-y-6">
      <pre id="moduledoc" class="fui-text-p-base text-ink-gray-7 whitespace-pre-wrap font-sans">{String.trim(@spec.doc)}</pre>

      <section>
        <h2 class="fui-text-lg-semibold text-ink-gray-9 mb-2">Atributos</h2>
        <div class="border-outline-gray-2 overflow-x-auto rounded-5 border">
          <table id="attrs-table" class="fui-text-sm w-full text-left">
            <thead class="bg-surface-gray-1 text-ink-gray-6">
              <tr>
                <th class="px-3 py-2">Nome</th>
                <th class="px-3 py-2">Tipo</th>
                <th class="px-3 py-2">Obrigatório</th>
                <th class="px-3 py-2">Padrão</th>
                <th class="px-3 py-2">Valores</th>
                <th class="px-3 py-2">Descrição</th>
              </tr>
            </thead>
            <tbody>
              <tr
                :for={attr <- @spec.attrs}
                class="border-outline-gray-1 border-t"
                data-attr={attr.name}
              >
                <td class="fui-text-sm-medium text-ink-gray-9 px-3 py-2">{attr.name}</td>
                <td class="px-3 py-2"><.badge label={type_label(attr.type)} /></td>
                <td class="px-3 py-2">{if attr.required, do: "sim", else: "não"}</td>
                <td class="px-3 py-2"><code>{inspect_default(attr.default)}</code></td>
                <td class="px-3 py-2">{values_label(attr.values)}</td>
                <td class="text-ink-gray-6 px-3 py-2">{attr.doc}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <section :if={@spec.slots != []}>
        <h2 class="fui-text-lg-semibold text-ink-gray-9 mb-2">Slots</h2>
        <ul id="slots-list" class="space-y-2">
          <li
            :for={slot <- @spec.slots}
            class="border-outline-gray-2 rounded-5 border p-3"
            data-slot={slot.name}
          >
            <p class="fui-text-base-medium text-ink-gray-9">
              :{slot.name} <.badge :if={slot.required} theme={:amber} label="obrigatório" />
            </p>
            <p :if={slot.doc} class="fui-text-sm text-ink-gray-6">{slot.doc}</p>
            <p :if={slot.attrs != []} class="fui-text-sm text-ink-gray-5 mt-1">
              atributos: {Enum.map_join(slot.attrs, ", ", &"#{&1.name}#{if &1.required, do: "*"}")}
            </p>
          </li>
        </ul>
      </section>
    </div>
    """
  end

  # Estado do servidor que as amostras exibem (upload, "salvo", listas/árvore).
  defp extras(assigns) do
    %{
      upload: assigns.uploads.demo,
      saved_at: assigns.saved_at,
      demo: assigns.demo,
      theme: assigns[:frappe_ui_theme]
    }
  end

  # ---- apresentação (puro) -----------------------------------------------------

  @doc false
  def summary(doc) do
    doc |> String.trim() |> String.split("\n\n") |> List.first() |> Kernel.||("")
  end

  defp category_title(groups, category) do
    Enum.find_value(groups, "", fn {id, title, _} -> id == category && title end)
  end

  defp type_label({:struct, module}), do: inspect(module)
  defp type_label(type) when is_atom(type), do: Atom.to_string(type)
  defp type_label(type), do: inspect(type)

  defp inspect_default(nil), do: "—"
  defp inspect_default(value), do: inspect(value)

  defp values_label(nil), do: ""
  defp values_label(values), do: Enum.map_join(values, " | ", &inspect/1)
end
