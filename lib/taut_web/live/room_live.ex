defmodule TautWeb.RoomLive do
  use TautWeb, :live_view

  require Logger

  alias Taut.{Message, Room}

  @impl Phoenix.LiveView
  def mount(_params, %{"user" => user}=session, socket) do
    room = session["room"]

    if room && connected?(socket), do: Room.subscribe_to(room)

    socket = socket
      |> assign(:user, user)
      |> assign(:room, room)
      |> assign(:msg_input, Message.new())
      |> assign(:msg_text, "")
      |> assign(:messages, Room.messages(room, :last_20))

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
              <%= Message.format(msg.content) %>
            </div>
          <% else %>
            <div id="<%= msg.id %>" class="taut_room_message">
              <b><%= msg.user.display_name %> wrote:</b>
              <%= Message.format(msg.content) %>
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
    Message.post(msg["content"], to: socket.assigns.room, from: socket.assigns.user)
    |> case do
      {:ok, _msg} -> 
        socket = update(socket, :msg_text, fn _ -> msg["content"] end)
          |> update(:msg_text, fn _ -> "" end)
          |> update(:msg_input, fn _ -> Message.new() end)
        {:noreply, socket}
      {:error, cs} ->
        {:noreply, update(socket, :msg_input, fn _ -> cs end)}
    end
  end

  def handle_event("send_new_message", params, socket) do
    Logger.warn("Got unhandled send_new_message with params = #{inspect(params)}")
    {:noreply, socket}
  end

  @impl true
  def handle_info({Taut.Message, :msg, payload}, socket) do
    socket = assign(socket, :messages, [payload])
    {:noreply, socket}
  end

  def widget(socket, user, room \\ nil) do
    room = Room.get_by_name(room)
    live_render(socket, __MODULE__,
                id: "taut_#{user.foreign_id || Ecto.UUID.generate()}",
                session: %{"user" => user, "room" => room})
  end

end
