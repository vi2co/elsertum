defmodule LinuxConfigWeb.ConfigLive do
  use LinuxConfigWeb, :live_view
  alias LinuxConfig.ConfigAccess

  @impl true
  def mount(%{"file" => file_id}, _session, socket) do
    filename = "#{file_id}.conf"

    # 1. Load data from file
    initial_data = ConfigAccess.read_config(filename)

    # 2. Assign data to socket
    socket =
      socket
      |> assign(:page_title, String.upcase(file_id) <> " Settings")
      |> assign(:filename, filename)
      |> assign(:form, to_form(initial_data)) # Convert Map to Phoenix Form
      |> assign(:config_keys, Map.keys(initial_data)) # Store keys to maintain list order
      |> assign(:initial_data, initial_data) # Keep original to restore on Cancel

    {:ok, socket}
  end

  # Handle realtime form updates (Temporary storage)
  @impl true
  def handle_event("validate", params, socket) do
    # Simply update the form with new user input, do not save to disk yet
    {:noreply, assign(socket, form: to_form(params))}
  end

  # Handle the Save button
  @impl true
  def handle_event("save", params, socket) do
    ConfigAccess.save_config(socket.assigns.filename, params)

    {:noreply,
     socket
     |> put_flash(:info, "Configuration saved to #{socket.assigns.filename}!")
     # Refresh data from disk to be sure
     |> push_navigate(to: ~p"/config/#{String.replace(socket.assigns.filename, ".conf", "")}")}
  end

  # Handle the Cancel button
  @impl true
  def handle_event("cancel", _params, socket) do
    # Reset form to initial_data
    {:noreply, assign(socket, form: to_form(socket.assigns.initial_data))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-md mx-auto bg-gray-100 p-6 rounded-lg shadow-md">
      <h1 class="text-2xl font-bold mb-4"><%= @page_title %></h1>

      <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-4">
        <%!-- Iterate over keys to generate inputs dynamically --%>
        <%= for key <- @config_keys do %>
          <div class="flex flex-col">
            <label class="font-bold text-gray-700 capitalize"><%= key %></label>

            <%!-- Check the value type in the FORM (not the file) to decide UI --%>
            <% value = @form[key].value %>

            <%= if is_boolean(value) or value == "true" or value == "false" do %>
              <%!-- Radio Buttons for Booleans --%>
              <div class="flex gap-4 mt-1">
                <label class="flex items-center">
                  <input type="radio" name={key} value="true" checked={value == true || value == "true"} class="mr-2"> True
                </label>
                <label class="flex items-center">
                  <input type="radio" name={key} value="false" checked={value == false || value == "false"} class="mr-2"> False
                </label>
              </div>
            <% else %>
              <%!-- Text Input for Strings --%>
              <input type="text" name={key} value={value} class="p-2 border rounded" />
            <% end %>
          </div>
        <% end %>

        <div class="flex justify-between pt-6 mt-4 border-t border-gray-300">
          <%!-- Cancel Button (Red) --%>
          <button type="button" phx-click="cancel"
            class="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded">
            Cancel
          </button>

          <%!-- Save Button (Green) --%>
          <button type="submit"
            class="bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-4 rounded">
            Save
          </button>
        </div>
      </.form>
    </div>
    """
  end
end
