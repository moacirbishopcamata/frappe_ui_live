defmodule Showcase.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Showcase.PubSub},
      ShowcaseWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Showcase.Supervisor)
  end
end
