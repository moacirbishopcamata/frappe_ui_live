defmodule FrappeUILive.Charts.Sankey do
  @moduledoc """
  Diagrama de Sankey: `links` é `[%{source, target, value}]`; os nós e as colunas
  (profundidade) são derivados dos links. Ciclos não são suportados e falham alto.
  """
  use Phoenix.Component

  alias FrappeUILive.Charts.{Frame, Scale}

  @width 600
  @node_w 12
  @gap 10
  @top 8

  attr :links, :list, required: true
  attr :height, :integer, default: 280
  attr :loading, :boolean, default: false
  attr :error, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  def sankey_chart(assigns) do
    links = Enum.filter(assigns.links, &(is_number(&1.value) and &1.value > 0))
    state = Frame.state(assigns.loading, assigns.error, links == [])
    layout = if links == [], do: %{nodes: [], links: []}, else: layout(links, assigns.height)

    assigns =
      assigns
      |> assign(:state, state)
      |> assign(:layout, layout)
      |> assign(:width, @width)
      |> assign(:node_w, @node_w)

    ~H"""
    <div class={@class} {@rest}>
      <Frame.chart_frame state={@state} error={@error} height={@height}>
        <svg
          viewBox={"0 0 #{@width} #{@height}"}
          class="w-full"
          role="img"
          aria-label="Diagrama de Sankey"
        >
          <path
            :for={link <- @layout.links}
            data-link
            d={link.path}
            fill="none"
            stroke-opacity="0.3"
            stroke-width={Scale.n(link.width)}
            style={"stroke: #{link.color}"}
            class="hover:stroke-opacity-60"
          >
            <title>{link.source} → {link.target}: {link.value}</title>
          </path>
          <g :for={node <- @layout.nodes} data-node={node.id}>
            <rect
              x={Scale.n(node.x)}
              y={Scale.n(node.y)}
              width={Scale.n(@node_w)}
              height={Scale.n(max(node.h, 1))}
              rx="2"
              style={"fill: #{node.color}"}
            >
              <title>{node.id}: {node.value}</title>
            </rect>
            <text
              x={Scale.n(if node.column == 0, do: node.x + @node_w + 6, else: node.x - 6)}
              y={Scale.n(node.y + node.h / 2 + 4)}
              text-anchor={if node.column == 0, do: "start", else: "end"}
              font-size="11"
              style="fill: var(--ink-gray-7)"
            >
              {node.id}
            </text>
          </g>
        </svg>
      </Frame.chart_frame>
    </div>
    """
  end

  @doc "Calcula nós e ribbons (função pura). Levanta `ArgumentError` se houver ciclo."
  @spec layout([map()], pos_integer()) :: %{nodes: [map()], links: [map()]}
  def layout(links, height) do
    ids = links |> Enum.flat_map(&[&1.source, &1.target]) |> Enum.uniq()
    depth = depths(ids, links)
    columns = depth |> Map.values() |> Enum.max()

    value = fn id ->
      inflow = for l <- links, l.target == id, reduce: 0, do: (acc -> acc + l.value)
      outflow = for l <- links, l.source == id, reduce: 0, do: (acc -> acc + l.value)
      max(inflow, outflow)
    end

    by_column = Enum.group_by(ids, &Map.fetch!(depth, &1))

    scale =
      by_column
      |> Enum.map(fn {_c, nodes} ->
        total = nodes |> Enum.map(value) |> Enum.sum()
        (height - @top * 2 - @gap * (length(nodes) - 1)) / total
      end)
      |> Enum.min()

    x_of = fn column -> if columns == 0, do: 0, else: column * (@width - @node_w) / columns end

    nodes =
      for {column, group} <- by_column, reduce: [] do
        acc ->
          {placed, _y} =
            group
            |> Enum.sort()
            |> Enum.map_reduce(@top, fn id, y ->
              h = value.(id) * scale

              {%{
                 id: id,
                 column: column,
                 x: x_of.(column),
                 y: y,
                 h: h,
                 value: value.(id),
                 color: nil
               }, y + h + @gap}
            end)

          acc ++ placed
      end

    nodes =
      nodes
      |> Enum.sort_by(& &1.id)
      |> Enum.with_index()
      |> Enum.map(fn {n, i} -> %{n | color: Scale.color(i)} end)

    index = Map.new(nodes, &{&1.id, &1})

    {ribbons, _out, _in} =
      Enum.reduce(links, {[], %{}, %{}}, fn link, {acc, out_off, in_off} ->
        src = Map.fetch!(index, link.source)
        dst = Map.fetch!(index, link.target)
        w = link.value * scale
        sy = src.y + Map.get(out_off, link.source, 0) + w / 2
        ty = dst.y + Map.get(in_off, link.target, 0) + w / 2
        x0 = src.x + @node_w
        x1 = dst.x
        mid = (x0 + x1) / 2

        ribbon = %{
          source: link.source,
          target: link.target,
          value: link.value,
          width: w,
          color: src.color,
          path:
            "M#{Scale.n(x0)},#{Scale.n(sy)} C#{Scale.n(mid)},#{Scale.n(sy)} #{Scale.n(mid)},#{Scale.n(ty)} #{Scale.n(x1)},#{Scale.n(ty)}"
        }

        {[ribbon | acc], Map.update(out_off, link.source, w, &(&1 + w)),
         Map.update(in_off, link.target, w, &(&1 + w))}
      end)

    %{nodes: nodes, links: Enum.reverse(ribbons)}
  end

  # Coluna de cada nó = maior caminho desde uma fonte; relaxamento limitado ao nº de nós (ciclo estoura).
  defp depths(ids, links) do
    initial = Map.new(ids, &{&1, 0})

    result =
      Enum.reduce_while(1..(length(ids) + 1), initial, fn _round, depth ->
        next =
          Enum.reduce(links, depth, fn l, acc ->
            Map.update!(acc, l.target, &max(&1, Map.fetch!(acc, l.source) + 1))
          end)

        if next == depth, do: {:halt, {:ok, next}}, else: {:cont, next}
      end)

    case result do
      {:ok, depth} ->
        depth

      _not_converged ->
        raise ArgumentError, "sankey_chart: os links formam um ciclo"
    end
  end
end
