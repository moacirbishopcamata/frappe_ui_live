defmodule ShowcaseWeb.Layouts do
  @moduledoc "Layout raiz: `data-theme` vem do `FrappeUIPhx.Plug.Theme`."
  use Phoenix.Component

  def root(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="pt-BR" data-theme={assigns[:frappe_ui_theme] || "light"}>
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Plug.CSRFProtection.get_csrf_token()} />
        <.live_title default="Frappe UI Phx" suffix=" · Mostruário">
          {assigns[:page_title]}
        </.live_title>
        <link phx-track-static rel="stylesheet" href="/assets/css/app.css" />
        <script defer phx-track-static type="text/javascript" src="/assets/js/app.js">
        </script>
      </head>
      <body>
        {@inner_content}
      </body>
    </html>
    """
  end
end
