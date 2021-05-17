defmodule Taut.Room do
  use Taut.Model

  alias Taut.Message

  schema "taut_rooms" do
    field :name, :string
    field :private, :boolean, default: false
    field :topic, :string

    has_many :subscriptions, Taut.Subscription
    has_many :users, through: [:subscriptions, :user]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :topic, :private])
    |> validate_required([:name, :private])
  end

  @doc false
  def get_default_room() do
    default_room_name = Application.get_env(:taut, :default_room_name, "Welcome")
 
    with nil <- Repo.get_by(__MODULE__, name: default_room_name),
         {:ok, room} <- create_room(default_room_name) do
      room
    else
      %__MODULE__{} = room -> room
      other -> other
    end
  end

  @doc """
  Gets room by name, or, if nil (default), gets default room.
  """
  def get_by_name(nil) do
    case get_default_room() do
      %__MODULE__{} = room -> room
      _ -> nil
    end
  end
  def get_by_name(name) do
    Repo.get_by(__MODULE__, name: name)
  end

  @doc """
  Creates new room with the given name.  May optionally provide :private and
  :topic keys (defaults to 'not private' and no topic).  Returns {:ok, room}
  or {:error, changeset}
  """
  def create_room(name, opts \\ []) do
    %__MODULE__{}
    |> changeset(%{ name: name,
                    private: Keyword.get(opts, :private, false),
                    topic: Keyword.get(opts, :topic) })
    |> Repo.insert()
  end

  @doc """
  Subscribe to room events:
    :msg
    :topic
    :join
    :leave
  """
  def subscribe_to(%__MODULE__{id: room_id}) when not is_nil(room_id)  do
    Phoenix.PubSub.subscribe(Taut.PubSub, "taut_room:#{room_id}")
  end

  @doc """
  Broadcast a message to the given room, from the given user.

  TRANSITIONAL.  Use Message.post() to create and (if valid) post the
  message.  This may be used in future for "non-message" Room events.
  """
  def post_message(%__MODULE__{}=room, %Taut.User{}=user, msg) do
    Phoenix.PubSub.broadcast(Taut.PubSub, "taut_room:#{room.id}",
      {__MODULE__, :msg, %{
       id: "taut_msg_#{Ecto.UUID.generate()}",
       content: msg,
       user: user,
       room: room }
      }
    )
  end

  def messages(%__MODULE__{id: rid}, :last_20) do
    from(m in Message, where: [room_id: ^rid], 
         limit: 20, order_by: [desc: m.inserted_at], preload: [:room, :user])
    |> Repo.all()
    |> Enum.reduce([], fn msg, acc ->
      # Convert to payloads and reverse in one go.
      [ Message.to_payload(msg) | acc ]
    end)
  end

  defdelegate widget(socket, user), to: TautWeb.RoomLive
end
