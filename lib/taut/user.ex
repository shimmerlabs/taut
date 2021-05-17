defmodule Taut.User do
  use Taut.Model

  schema "taut_users" do
    field :display_name, :string
    field :foreign_id, :string
    field :role, :string, default: "visitor"

    has_many :subscriptions, Taut.Subscription
    has_many :rooms, through: [:subscriptions, :room]

    timestamps(type: :utc_datetime)
  end

  @doc """
  Gets a User based on the foreign_id given.  If the User does not exist, it
  is created.  You can pass the :display_name and :role keys and these will
  be used to update the User record before returning it, and/or use these
  for creating a user that doesn't exist.  If these fields aren't provided
  and the user needs to be created, they are defaulted to "Unnamed Guest"
  with the role "visitor". 

  Returns tuple {:ok, user} or {:error, changeset}
  """
  def get(foreign_id, opts \\ []) do
    changes = Enum.into(opts, %{}, &(&1))
    case Repo.get_by(__MODULE__, [foreign_id: foreign_id]) do
      %__MODULE__{} = user -> Repo.update(changeset(user, changes))
      nil -> new_user(Map.put(changes, :foreign_id, foreign_id))
    end
  end

  def new_user(attrs) do
    default_room = Taut.Room.get_default_room()

    with {:ok, user} <- Repo.insert(changeset(%__MODULE__{}, attrs)),
         {:ok, _sub} <- Repo.insert(Taut.Subscription.new(user_id: user.id, room_id: default_room.id)) do
      {:ok, user}
    end
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:display_name, :foreign_id, :role])
    |> default_display_name()
    |> validate_required([:display_name, :role])
  end

  # Only if this is a new record.
  defp default_display_name(%{data: %{id: nil}}=cs) do
    given_name = get_field(cs, :display_name)
                 |> to_string()
                 |> String.trim()
    if given_name == "" do
      put_change(cs, :display_name, "Unnamed Guest")
    else
      cs
    end

  end
  defp default_display_name(cs), do: cs

  @doc """
  Subscribe to the PubSub for all events that affect the given user.
  """
  def subscribe(%__MODULE__{foreign_id: fid}) when is_binary(fid) do
    Phoenix.PubSub.subscribe(Taut.PubSub, "taut_user:#{fid}")
  end
  
end
