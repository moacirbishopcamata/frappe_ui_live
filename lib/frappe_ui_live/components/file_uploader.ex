defmodule FrappeUILive.Components.FileUploader do
  @moduledoc """
  Área de envio sobre `allow_upload/3` do LiveView: arrastar-e-soltar, lista de
  arquivos com progresso, cancelamento e erros em português. Quem decide o que
  fazer com o arquivo (`consume_uploaded_entries/3`) é o servidor.

      def mount(_, _, socket), do: {:ok, allow_upload(socket, :docs, accept: ~w(.pdf), max_entries: 2)}

      <.file_uploader upload={@uploads.docs} on_cancel="cancel-upload" />
  """
  use Phoenix.Component

  alias FrappeUILive.Components.{ErrorMessage, Icon, Progress}

  attr :upload, Phoenix.LiveView.UploadConfig, required: true
  attr :label, :string, default: "Arraste arquivos ou clique para enviar"
  attr :on_cancel, :string, default: "cancel-upload", doc: "evento do servidor; recebe `ref`"
  attr :class, :any, default: nil
  slot :hint

  def file_uploader(assigns) do
    ~H"""
    <div class={@class}>
      <label
        phx-drop-target={@upload.ref}
        class="border-outline-gray-3 bg-surface-gray-1 hover:bg-surface-gray-2 rounded-6 focus-within:focus-ring flex cursor-pointer flex-col items-center gap-1.5 border border-dashed px-4 py-6 text-center transition-colors"
      >
        <Icon.icon name="cloud-upload" class="text-ink-gray-5 size-6" />
        <span class="fui-text-base-medium text-ink-gray-8">{@label}</span>
        <span :if={@hint != []} class="fui-text-sm text-ink-gray-5">{render_slot(@hint)}</span>
        <.live_file_input upload={@upload} class="sr-only" />
      </label>

      <ErrorMessage.error_message
        message={Enum.map(upload_errors(@upload), &error_message/1)}
        class="mt-2"
      />

      <ul :if={@upload.entries != []} class="mt-3 space-y-2">
        <li
          :for={entry <- @upload.entries}
          :key={entry.ref}
          class="border-outline-gray-2 rounded-5 border p-2.5"
        >
          <div class="flex items-center gap-2">
            <Icon.icon name="file-text" class="text-ink-gray-5 size-4 shrink-0" />
            <span class="fui-text-base text-ink-gray-8 min-w-0 flex-1 truncate">{entry.client_name}</span>
            <button
              type="button"
              phx-click={@on_cancel}
              phx-value-ref={entry.ref}
              aria-label={"Cancelar #{entry.client_name}"}
              class="text-ink-gray-5 hover:text-ink-gray-8"
            >
              <Icon.icon name="x" class="size-4" />
            </button>
          </div>
          <Progress.progress value={entry.progress} size={:sm} class="mt-2" />
          <ErrorMessage.error_message
            message={Enum.map(upload_errors(@upload, entry), &error_message/1)}
            class="mt-1"
          />
        </li>
      </ul>
    </div>
    """
  end

  @doc "Mensagem em português para os erros de upload do LiveView."
  @spec error_message(atom() | term()) :: String.t()
  def error_message(:too_large), do: "Arquivo maior que o permitido."
  def error_message(:not_accepted), do: "Tipo de arquivo não aceito."
  def error_message(:too_many_files), do: "Há arquivos demais selecionados."
  def error_message(:external_client_failure), do: "Falha no envio. Tente novamente."
  def error_message(other), do: "Erro no envio (#{inspect(other)})."
end
