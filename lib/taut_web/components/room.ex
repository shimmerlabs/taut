defmodule TautWeb.RoomComponent do
  use TautWeb, :live_component

  require Logger

  def component(socket, taut_user) do
    live_component(socket, TautWeb.RoomComponent, id: "foo", taut_user: taut_user)
  end

  @impl Phoenix.LiveComponent
  def mount(socket) do
    # if connected?(socket), do: Taut.User.subscribe()
    {:ok, socket}
  end

  @impl true
  def preload(list_of_assigns) do
    IO.inspect(list_of_assigns, structs: false, limit: :infinity)
    list_of_assigns
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div id="taut-<%= @id %>">
      <ul>
        <%= for line <- List.wrap(assigns[:messages]) do %>
          <li><%= line.content %></li>
        <% end %>
      </ul>
      <form phx-submit="send_new_message" phx-target="<%= @myself %>">
        <input type="text" name="new_message" />
      </form>
      <p>You are logged in as <%= @taut_user.display_name %></p>
    </div>
    """
  end

  @impl true
  def handle_event("send_new_message", %{"new_message" => msg}, socket) do
    msg_list = List.wrap(socket.assigns[:messages])
    socket = assign(socket, :messages, [%{content: msg} | msg_list])

    {:noreply, socket}
  end

  def handle_event("send_new_message", _, socket) do
    {:noreply, socket}
  end

end
