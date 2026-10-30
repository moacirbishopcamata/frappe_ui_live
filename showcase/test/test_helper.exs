# Os testes de :assets exigem `mix assets.build` (CSS/JS gerados); sem eles, são pulados.
assets_built? =
  File.exists?("priv/static/assets/js/app.js") and File.exists?("priv/static/assets/css/app.css")

ExUnit.start(exclude: if(assets_built?, do: [], else: [:assets]))
