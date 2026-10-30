defmodule FrappeUILive.Components.FormsMoreTest do
  use FrappeUILive.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2, rendered_to_string: 1]

  alias FrappeUILive.Components.{
    Combobox,
    DatePicker,
    Duration,
    FileUploader,
    MultiSelect,
    OptionList,
    Password,
    RadioGroup,
    Rating,
    Slider,
    TimePicker
  }

  alias Phoenix.LiveView.Socket

  describe "Password" do
    test "nunca reenvia o valor ao HTML e alterna o tipo por JS" do
      assigns = %{f: form_field(:senha, "segredo123")}
      html = rendered_to_string(~H|<Password.password field={@f} />|)
      refute html =~ "segredo123"
      assert html_attr(html, "input", "type") == "password"
      assert html_attr(html, "button", "phx-click") =~ "toggle_attr"
      assert html_attr(html, "button", "phx-click") =~ "#f_senha"
    end

    test "sem id nem field viola o contrato" do
      assigns = %{}

      assert_raise ArgumentError, ~r/password id inválido/, fn ->
        rendered_to_string(~H|<Password.password name="x" />|)
      end
    end

    test "erro marca inválido" do
      assigns = %{f: form_field(:senha, "", [{"curta", []}])}

      assert html_attr(
               rendered_to_string(~H|<Password.password field={@f} />|),
               "input",
               "aria-invalid"
             ) == "true"
    end
  end

  describe "RadioGroup" do
    test "marca a opção do valor (texto ou número) e usa o name do campo" do
      assigns = %{f: form_field(:plano, "2")}

      html =
        rendered_to_string(
          ~H|<RadioGroup.radio_group field={@f} options={[{"Básico", 1}, {"Pro", 2}]} label="Plano" />|
        )

      assert has?(html, "input[type=radio][value='2'][checked]")
      refute has?(html, "input[type=radio][value='1'][checked]")
      assert html_attr(html, "input", "name") == "f[plano]"
      assert text(html, "legend") == "Plano"
    end

    test "choice/2 e orientação" do
      assert RadioGroup.choice("a", "a") == {"a", "a", true}
      assert RadioGroup.choice({"Um", 1}, "2") == {"Um", "1", false}
      assigns = %{}

      html =
        rendered_to_string(
          ~H|<RadioGroup.radio_group name="x" options={["a"]} orientation={:horizontal} />|
        )

      assert html =~ "flex-row"

      assert_raise ArgumentError, ~r/radio_group orientation/, fn ->
        rendered_to_string(
          ~H|<RadioGroup.radio_group name="x" options={["a"]} orientation={:diagonal} />|
        )
      end
    end
  end

  describe "Slider e Rating" do
    test "slider: limites, valor e saída" do
      assigns = %{}

      html =
        rendered_to_string(
          ~H|<Slider.slider name="v" value={30} min={10} max={50} step={5} show_value />|
        )

      assert has?(html, "input[type=range][min='10'][max='50'][step='5'][value='30']")
      assert text(html, "output") == "30"

      assert_raise ArgumentError, ~r/min deve ser menor/, fn ->
        rendered_to_string(~H|<Slider.slider name="v" min={5} max={5} />|)
      end

      assert_raise ArgumentError, ~r/step/, fn ->
        rendered_to_string(~H|<Slider.slider name="v" step={0} />|)
      end
    end

    test "rating: estrelas cheias até o valor, vindo do servidor" do
      assigns = %{f: form_field(:nota, "3")}
      html = rendered_to_string(~H|<Rating.rating field={@f} />|)
      assert Enum.count(query(html, "input[type=radio]")) == 5
      assert has?(html, "input[value='3'][checked]")
      assert Enum.count(query(html, ".lucide-star-filled")) == 3
      assert Enum.count(query(html, ".lucide-star")) == 2
    end

    test "rating: current/2 normaliza e readonly desabilita; max fora da faixa viola" do
      assert Rating.current("4", 5) == 4
      assert Rating.current(9, 5) == 0
      assert Rating.current("x", 5) == 0
      assert Rating.current(nil, 5) == 0
      assigns = %{}

      assert has?(
               rendered_to_string(~H|<Rating.rating name="n" value={2} readonly />|),
               "input[disabled]"
             )

      assert_raise ArgumentError, ~r/rating: max/, fn ->
        rendered_to_string(~H|<Rating.rating name="n" max={0} />|)
      end
    end
  end

  describe "Duration e TimePicker" do
    test "duration mostra segundos como texto e aceita digitado (costura com Ecto.Duration)" do
      assigns = %{f: form_field(:tempo, 5400)}
      html = rendered_to_string(~H|<Duration.duration field={@f} />|)
      assert html_attr(html, "input", "value") == "1h 30m"
      assert html_attr(html, "input", "placeholder") == "1h 30m"

      assigns = %{f: form_field(:tempo, "1h30")}

      assert html_attr(rendered_to_string(~H|<Duration.duration field={@f} />|), "input", "value") ==
               "1h30"

      # o texto exibido volta a ser o mesmo valor pelo tipo do domínio
      assert FrappeUILive.Ecto.Duration.cast("1h 30m") == {:ok, 5400}
    end

    test "time_picker usa input time com step" do
      assigns = %{}
      html = rendered_to_string(~H|<TimePicker.time_picker name="h" value="08:30" step={1} />|)
      assert has?(html, "input[type=time][step='1'][value='08:30']")

      assert_raise ArgumentError, ~r/step/, fn ->
        rendered_to_string(~H|<TimePicker.time_picker name="h" step={0} />|)
      end
    end
  end

  describe "OptionList, Combobox e MultiSelect" do
    @opts [{"Maçã", "a"}, {"Banana", "b"}, "Uva"]

    test "normalize/1" do
      assert OptionList.normalize({"Um", 1}) == {"Um", "1"}
      assert OptionList.normalize("x") == {"x", "x"}
    end

    test "combobox: radios nativos, selecionado no gatilho e filtro por rótulo minúsculo" do
      assigns = %{f: form_field(:fruta, "b"), o: @opts}
      html = rendered_to_string(~H|<Combobox.combobox field={@f} options={@o} />|)
      assert Enum.count(query(html, "input[type=radio]")) == 3
      assert has?(html, "input[type=radio][value='b'][checked]")
      assert html_attr(html, "[popovertarget]", "popovertarget") == "f_fruta-panel"
      assert text(html, "button[aria-haspopup=listbox]") =~ "Banana"
      assert html_attr(html, "li[data-option-label='maçã']", "data-option-label") == "maçã"
      assert html_attr(html, "#f_fruta", "phx-hook") =~ "OptionFilter"
      assert html_attr(html, "#f_fruta", "data-remote") == "false"
    end

    test "combobox sem valor mostra o placeholder" do
      assigns = %{o: @opts}

      html =
        rendered_to_string(
          ~H|<Combobox.combobox id="c" name="x" options={@o} placeholder="Escolha…" />|
        )

      assert text(html, "button[aria-haspopup=listbox]") =~ "Escolha…"
      refute has?(html, "input[checked]")
    end

    test "busca remota liga phx-keyup e desliga o filtro local" do
      assigns = %{o: @opts}

      html =
        rendered_to_string(
          ~H|<Combobox.combobox id="c" name="x" options={@o} on_search="buscar" />|
        )

      assert html_attr(html, "input[type=search]", "phx-keyup") == "buscar"
      assert html_attr(html, "#c", "data-remote") == "true"
    end

    test "multi_select: checkboxes name[], hidden vazio, selos e '+n'" do
      assigns = %{f: form_field(:frutas, ["a", "b"]), o: @opts}
      html = rendered_to_string(~H|<MultiSelect.multi_select field={@f} options={@o} />|)
      assert has?(html, "input[type=hidden][value='']")
      assert html_attr(html, "input[type=checkbox]", "name") == "f[frutas][]"
      assert Enum.count(query(html, "input[type=checkbox][checked]")) == 2
      assert html =~ "Maçã" and html =~ "Banana"

      many = Enum.map(1..6, &{"Op #{&1}", "#{&1}"})
      assigns = %{f: form_field(:frutas, ~w(1 2 3 4 5)), o: many}
      html = rendered_to_string(~H|<MultiSelect.multi_select field={@f} options={@o} />|)
      assert html =~ "+2"
    end

    test "id inválido (vai para CSS) viola o contrato" do
      assigns = %{o: @opts}

      assert_raise ArgumentError, ~r/combobox id/, fn ->
        rendered_to_string(~H|<Combobox.combobox id="a; b" name="x" options={@o} />|)
      end
    end
  end

  describe "DatePicker (LiveComponent)" do
    defp initial(extra \\ []) do
      {:ok, socket} =
        DatePicker.update(
          Map.new([id: "d", value: "2026-03-09", today: ~D[2026-03-15]] ++ extra),
          %Socket{}
        )

      socket
    end

    test "renderiza o valor ISO no hidden, o texto formatado e 42 dias" do
      html =
        render_component(DatePicker,
          id: "d",
          name: "n",
          value: "2026-03-09",
          today: ~D[2026-03-15]
        )

      assert html_attr(html, "input[type=hidden]", "value") == "2026-03-09"
      assert html_attr(html, "input[type=hidden]", "name") == "n"
      assert text(html, "button[aria-haspopup=dialog]") =~ "09/03/2026"
      assert text(html, "[aria-live=polite]") == "Março 2026"
      assert Enum.count(query(html, "button[data-date]")) == 42
      assert html_attr(html, "button[data-date='2026-03-09']", "aria-pressed") == "true"
      assert html_attr(html, "button[data-date='2026-03-09']", "phx-click") =~ "set_attr"
      assert html_attr(html, "button[data-date='2026-03-09']", "popovertargetaction") == "hide"
    end

    test "usa o field (name, erro, valor)" do
      html =
        render_component(DatePicker,
          id: "d",
          field: form_field(:nasc, "2026-03-09", [{"inválida", []}]),
          today: ~D[2026-03-15]
        )

      assert html_attr(html, "input[type=hidden]", "name") == "f[nasc]"
      assert html_attr(html, "button[aria-haspopup=dialog]", "aria-invalid") == "true"
    end

    test "sem valor mostra o placeholder e abre no mês de hoje" do
      html =
        render_component(DatePicker,
          id: "d",
          name: "n",
          today: ~D[2026-07-04],
          placeholder: "Quando?"
        )

      assert text(html, "button[aria-haspopup=dialog]") =~ "Quando?"
      assert text(html, "[aria-live=polite]") == "Julho 2026"
    end

    test "navegar meses, escolher e limpar (estado do componente)" do
      socket = initial()
      assert socket.assigns.month == ~D[2026-03-01]

      {:noreply, next} = DatePicker.handle_event("next", %{}, socket)
      assert next.assigns.month == ~D[2026-04-01]
      {:noreply, prev} = DatePicker.handle_event("prev", %{}, next)
      assert prev.assigns.month == ~D[2026-03-01]

      {:noreply, picked} = DatePicker.handle_event("pick", %{"date" => "2026-03-20"}, socket)
      assert picked.assigns.selected == ~D[2026-03-20] and picked.assigns.value == "2026-03-20"

      {:noreply, cleared} = DatePicker.handle_event("clear", %{}, picked)
      assert cleared.assigns.selected == nil
    end

    test "datas forjadas (inválida ou fora de min/max) são ignoradas" do
      socket = initial(min: "2026-03-05", max: "2026-03-25")
      {:noreply, same} = DatePicker.handle_event("pick", %{"date" => "lixo"}, socket)
      assert same.assigns.selected == ~D[2026-03-09]
      {:noreply, same} = DatePicker.handle_event("pick", %{"date" => "2026-04-01"}, socket)
      assert same.assigns.selected == ~D[2026-03-09]
      {:noreply, same} = DatePicker.handle_event("pick", %{"date" => "2026-03-01"}, socket)
      assert same.assigns.selected == ~D[2026-03-09]
    end

    test "dias fora de min/max ficam desabilitados" do
      html =
        render_component(DatePicker,
          id: "d",
          name: "n",
          value: "2026-03-09",
          min: "2026-03-05",
          max: "2026-03-25",
          today: ~D[2026-03-15]
        )

      assert has?(html, "button[data-date='2026-03-01'][disabled]")
      refute has?(html, "button[data-date='2026-03-10'][disabled]")
    end

    test "o valor do field vence a cada atualização (formulário é a fonte da verdade)" do
      {:ok, socket} =
        DatePicker.update(
          %{id: "d", field: form_field(:nasc, "2026-03-09"), today: ~D[2026-03-15]},
          %Socket{}
        )

      assert socket.assigns.selected == ~D[2026-03-09]

      {:ok, socket} =
        DatePicker.update(
          %{id: "d", field: form_field(:nasc, "2026-05-02"), today: ~D[2026-03-15]},
          socket
        )

      assert socket.assigns.selected == ~D[2026-05-02]
      assert socket.assigns.month == ~D[2026-05-01]
    end

    test "id inválido viola o contrato" do
      assert_raise ArgumentError, ~r/date_picker id/, fn ->
        render_component(DatePicker, id: "x y", name: "n")
      end
    end
  end

  test "FileUploader renderiza área, arquivo com progresso, cancelar e erros" do
    socket = Phoenix.LiveView.allow_upload(%Socket{}, :docs, accept: ~w(.png), max_entries: 1)
    upload = socket.assigns.uploads.docs

    entry = %Phoenix.LiveView.UploadEntry{
      ref: "0",
      client_name: "foto.png",
      client_size: 10,
      client_type: "image/png",
      progress: 40,
      valid?: true,
      uuid: "u1",
      upload_ref: upload.ref
    }

    upload = %{
      upload
      | entries: [entry],
        errors: [{upload.ref, :too_many_files}, {"0", :too_large}]
    }

    assigns = %{upload: upload}

    html =
      rendered_to_string(~H"""
      <FileUploader.file_uploader upload={@upload} on_cancel="cancelar" label="Envie">
        <:hint>Só PNG</:hint>
      </FileUploader.file_uploader>
      """)

    assert html_attr(html, "label[phx-drop-target]", "phx-drop-target") == upload.ref
    assert has?(html, "input[type=file]")
    assert html =~ "Envie" and html =~ "Só PNG" and html =~ "foto.png"
    assert html_attr(html, "[role=progressbar]", "aria-valuenow") == "40"
    assert html_attr(html, "button[phx-value-ref]", "phx-click") == "cancelar"
    assert html =~ "demais" and html =~ "maior que o permitido"
  end

  test "FileUploader.error_message/1 traduz os erros do LiveView" do
    assert FileUploader.error_message(:too_large) =~ "maior"
    assert FileUploader.error_message(:not_accepted) =~ "não aceito"
    assert FileUploader.error_message(:too_many_files) =~ "demais"
    assert FileUploader.error_message(:external_client_failure) =~ "Falha"
    assert FileUploader.error_message(:outro) =~ ":outro"
  end
end
