defmodule FrappeUIPhx.EctoIntegrationTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias FrappeUIPhx.Ecto.{Duration, Options, Rating, StringList}

  defmodule Tarefa do
    use Ecto.Schema

    embedded_schema do
      field(:status, Ecto.Enum, values: [:aberta, :em_andamento, :concluida])
      field(:tempo, FrappeUIPhx.Ecto.Duration)
      field(:nota, FrappeUIPhx.Ecto.Rating, max: 5)
      field(:tags, FrappeUIPhx.Ecto.StringList)
    end

    def changeset(tarefa, attrs),
      do: Changeset.cast(tarefa, attrs, [:status, :tempo, :nota, :tags])
  end

  describe "Duration" do
    test "cast aceita o que o usuário digita" do
      for {entrada, segundos} <- [
            {"1h 30m", 5400},
            {"1h30m", 5400},
            {"90m", 5400},
            {"45s", 45},
            {"1:30", 5400},
            {"1:30:15", 5415},
            {"5400", 5400},
            {5400, 5400},
            {"2H 5M 1S", 7501}
          ] do
        assert Duration.cast(entrada) == {:ok, segundos}, "entrada #{inspect(entrada)}"
      end
    end

    test "cast rejeita lixo e valores negativos" do
      for ruim <- ["abc", "1x", "1:75", "1h xyz", -5, :atom, 1.5] do
        assert Duration.cast(ruim) == :error, "entrada #{inspect(ruim)}"
      end
    end

    test "vazio vira nil" do
      assert Duration.cast("") == {:ok, nil}
      assert Duration.cast(nil) == {:ok, nil}
    end

    test "dump/load preservam inteiros e barram o resto" do
      assert Duration.dump(10) == {:ok, 10}
      assert Duration.dump(nil) == {:ok, nil}
      assert Duration.dump(-1) == :error
      assert Duration.load(10) == {:ok, 10}
      assert Duration.load(nil) == {:ok, nil}
      assert Duration.load("x") == :error
      assert Duration.type() == :integer
    end

    test "humanize é o inverso do cast (ida e volta)" do
      for segundos <- [0, 1, 59, 60, 61, 3600, 5415, 86_399] do
        assert {:ok, ^segundos} = segundos |> Duration.humanize() |> Duration.cast()
      end

      assert Duration.humanize(nil) == ""
      assert Duration.humanize(5400) == "1h 30m"
    end
  end

  describe "Rating" do
    test "valida a faixa 0..max pelo changeset, inclusive vindo de string de formulário" do
      assert %Changeset{valid?: true, changes: %{nota: 4}} =
               Tarefa.changeset(%Tarefa{}, %{"nota" => "4"})

      assert %Changeset{valid?: false} = Tarefa.changeset(%Tarefa{}, %{"nota" => "6"})
      assert %Changeset{valid?: false} = Tarefa.changeset(%Tarefa{}, %{"nota" => "x"})
      assert %Changeset{valid?: true} = Tarefa.changeset(%Tarefa{}, %{"nota" => ""})
    end

    test "max configurável e precondição de max positivo" do
      assert Rating.init(max: 10) == %{max: 10}
      assert_raise ArgumentError, ~r/max/, fn -> Rating.init(max: 0) end
    end

    test "dump barra fora da faixa e aceita nil" do
      assert Rating.dump(3, nil, %{max: 5}) == {:ok, 3}
      assert Rating.dump(9, nil, %{max: 5}) == :error
      assert Rating.dump(nil, nil, %{max: 5}) == {:ok, nil}
      assert Rating.load(3, nil, %{max: 5}) == {:ok, 3}
      assert Rating.type(%{max: 5}) == :integer
    end
  end

  describe "StringList" do
    test "cast de string separada por vírgula e de lista, sem vazios nem repetidos" do
      assert StringList.cast("a, b,, a , c") == {:ok, ["a", "b", "c"]}
      assert StringList.cast([" x ", "", "x", "y"]) == {:ok, ["x", "y"]}
      assert StringList.cast(nil) == {:ok, []}
      assert StringList.cast([1, 2]) == :error
      assert StringList.cast(5) == :error
    end

    test "dump/load" do
      assert StringList.type() == {:array, :string}
      assert StringList.dump(["a"]) == {:ok, ["a"]}
      assert StringList.dump("a") == :error
      assert StringList.load(["a"]) == {:ok, ["a"]}
      assert StringList.load(nil) == {:ok, []}
      assert StringList.load(1) == :error
    end
  end

  describe "changeset completo (costura Ecto -> FormField -> componente)" do
    test "erro de cast chega ao campo quando o usuário enviou o valor" do
      {:error, cs} =
        %Tarefa{} |> Tarefa.changeset(%{"tempo" => "abc"}) |> Changeset.apply_action(:insert)

      form = Phoenix.Component.to_form(cs, as: :tarefa)
      assert [{"is invalid", _}] = form[:tempo].errors
      assert FrappeUIPhx.Field.errors(form[:tempo]) == ["is invalid"]
    end

    test "erro de campo que o usuário ainda não tocou fica escondido" do
      {:error, cs} =
        %Tarefa{}
        |> Tarefa.changeset(%{})
        |> Changeset.validate_required([:tempo])
        |> Changeset.apply_action(:insert)

      form = Phoenix.Component.to_form(cs, as: :tarefa)
      assert [{"can't be blank", _}] = form[:tempo].errors
      assert FrappeUIPhx.Field.errors(form[:tempo]) == []
    end

    test "valores válidos atravessam o changeset com os tipos do domínio" do
      cs =
        Tarefa.changeset(%Tarefa{}, %{
          "tempo" => "1h 30m",
          "tags" => "x, y",
          "status" => "em_andamento"
        })

      assert cs.valid?
      assert %{tempo: 5400, tags: ["x", "y"], status: :em_andamento} = Changeset.apply_changes(cs)
    end
  end

  describe "Options.from_enum/2" do
    test "gera {rótulo, valor} a partir do Ecto.Enum" do
      assert Options.from_enum(Tarefa, :status) ==
               [
                 {"Aberta", "aberta"},
                 {"Em andamento", "em_andamento"},
                 {"Concluida", "concluida"}
               ]
    end

    test "campo que não é Ecto.Enum viola o contrato" do
      assert_raise ArgumentError, ~r/não é um Ecto.Enum/, fn ->
        Options.from_enum(Tarefa, :nota)
      end
    end

    test "humanize/1" do
      assert Options.humanize(:a_b) == "A b"
    end
  end
end
