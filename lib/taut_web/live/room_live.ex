defmodule TautWeb.RoomLive do
  use TautWeb, :live_view

  require Logger

  @impl Phoenix.LiveView
  def mount(_params, %{"user" => user}=session, socket) do
    room = session["room"]

    if room && connected?(socket), do: Taut.Room.subscribe_to(room)

    socket = socket
      |> assign(:user, user)
      |> assign(:room, room)
      |> assign(:msg_input, Taut.Message.new())
      |> assign(:msg_text, "")

    {:ok, socket, temporary_assigns: [messages: []]}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="taut_room">
      <div id="room-messages" phx-update="append">
        <%= for msg <- @messages do %>
          <%= if msg.user.id == @user.id do %>
            <div id="<%= msg.id %>" class="taut_room_message_mine">
              <%= msg.content %>
            </div>
          <% else %>
            <div id="<%= msg.id %>" class="taut_room_message">
              <b><%= msg.user.display_name %> wrote:</b>
              <%= msg.content %>
            </div>
          <% end %>
        <% end %>
      </div>
      <div class="taut_input">
        <p>You are logged into <%= @room.name %>  as <%= @user.display_name %></p>
        <%= f = form_for @msg_input, "#", [phx_submit: :send_new_message] %>
          <%= label f, :content, "Enter your message:" %>
          <%= text_input f, :content, value: @msg_text %>
        </form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("send_new_message", %{"message" => msg}, socket) do
    Taut.Room.post_message(socket.assigns.room, socket.assigns.user, msg["content"])
    socket = update(socket, :msg_text, fn _ -> msg["content"] end)
      |> update(:msg_text, fn _ -> "" end)
      |> update(:msg_input, fn _ -> Taut.Message.new() end)
    {:noreply, socket}
  end

  def handle_event("send_new_message", params, socket) do
    Logger.warn("Got unhandled send_new_message with params = #{inspect(params)}")
    {:noreply, socket}
  end

  @impl true
  def handle_info({Taut.Room, :msg, payload}, socket) do
    socket = update(socket, :messages, &([payload | &1]))
    {:noreply, socket}
  end

  def widget(socket, user, room \\ nil) do
    room = Taut.Room.get_by_name(room)
    live_render(socket, __MODULE__,
                id: "taut_#{user.foreign_id || Ecto.UUID.generate()}",
                session: %{"user" => user, "room" => room})
  end

end
