defmodule FrappeUILive.FieldTest do
  use FrappeUILive.Case, async: true

  alias FrappeUILive.{ErrorTranslator.Default, Field}

  defp base(extra), do: Map.merge(%{__changed__: nil, id: nil, field: nil}, Map.new(extra))

  test "deriva id, name e value do FormField" do
    out = Field.assign_field(base(field: form_field(:nome, "Ana")))
    assert out.id == "f_nome"
    assert out.name == "f[nome]"
    assert out.value == "Ana"
    assert out.errors == []
  end

  test "id e value avulsos têm precedência sobre o field" do
    out = Field.assign_field(base(field: form_field(:nome, "Ana"), id: "meu-id", value: "Bia"))
    assert out.id == "meu-id"
    assert out.value == "Bia"
  end

  test "erros só aparecem quando o campo foi usado" do
    erro = {"não pode ser vazio", []}

    assert Field.assign_field(base(field: form_field(:nome, nil, [erro], true))).errors == [
             "não pode ser vazio"
           ]

    assert Field.assign_field(base(field: form_field(:nome, nil, [erro], false))).errors == []
  end

  test "multiple acrescenta [] ao name" do
    out = Field.assign_field(base(field: form_field(:tags)), multiple: true)
    assert out.name == "f[tags][]"
  end

  test "sem field mantém name e value avulsos e erros fornecidos" do
    out = Field.assign_field(base(name: "x", value: 1, errors: ["e"]))
    assert {out.name, out.value, out.errors} == {"x", 1, ["e"]}
  end

  test "sem field nem name/value, ambos ficam nil (sem KeyError no template)" do
    out = Field.assign_field(base([]))
    assert {out.name, out.value, out.errors} == {nil, nil, []}
  end

  test "errors/1 traduz com interpolação" do
    f = form_field(:nome, "x", [{"deve ter %{count} letras", count: 3}])
    assert Field.errors(f) == ["deve ter 3 letras"]
  end

  test "Default.translate/1 interpola valores não textuais com inspect" do
    assert Default.translate({"tipo %{type}", type: {:array, :string}}) ==
             "tipo {:array, :string}"
  end
end
