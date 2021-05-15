defmodule Taut.Message do
  use Taut.Model

  alias Taut.{User, Room}

  schema "taut_messages" do
    field :content, :string

    belongs_to :user, User
    belongs_to :room, Room

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :user_id, :room_id])
    |> validate_required([:content, :user_id, :room_id])
  end

  @doc """
  Saves the message and broadcasts to the room.

  On error, returns {:error, changeset}.  On success, returns {:ok, nil} if
  the message content was blank (and does not broadcast anything -- a NOOP),
  or {:ok, msg} if saved successfully.
  """
  def post(content, opts \\ []) do
    content
    |> to_string()
    |> String.trim()
    |> do_post(opts)
  end

  # If it's a blank message, return ok, but do nothing.  This avoids putting
  # an error state on the input field.
  defp do_post("", _), do: {:ok, nil}
  defp do_post(message, opts) do
    %{ room_id: get_id_from(Keyword.get(opts, :to)),
       user_id: get_id_from(Keyword.get(opts, :from)),
       content: message }
    |> new()
    |> Repo.insert()
    |> post_message()
  end

  defp post_message({:ok, msg}) do
    msg = Repo.preload(msg, [:user, :room])
    Phoenix.PubSub.broadcast(Taut.PubSub, "taut_room:#{msg.room_id}",
      {__MODULE__, :msg, to_payload(msg)}
    )
    {:ok, msg}
  end
  defp post_message(other), do: other
    
  @doc """
  If given a map with an id: field, use the value of that field, otherwise,
  return the value.
  """
  def get_id_from(%{id: id}), do: id
  def get_id_from(x), do: x

  @doc """
  Formats a given message content, if it can.  Returns a payload that can
  be sent to the channel.  By default, we employ a Markdown formatter, but
  you can override this by setting a :formatter field in the :taut config

  This content will be rendered into the template, so if you've marked it
  up with HTML, you'll need to return {:safe, content} to avoid escaping
  the markup.
  """
  def format(content) do
    case Application.get_env(:taut, :formatter) do
      nil -> safe_markdown(content)
      func -> func.(content)
    end
  end

  @doc """
  Attempts to apply Markdown formatting to the given content.  Returns
  {:safe, html} on success, or just the given input on failure
  """
  def safe_markdown(content) do
    case Earmark.as_html(content) do
      {:ok, html, _} -> {:safe, html}
      {:error, _, _} -> content
    end
  end

  @doc """
  Converts the given message record into a paylaod for pubsubbing.
  """
  def to_payload(%__MODULE__{id: id, content: content}=msg) do
    msg
    |> Repo.preload(:user)
    |> Map.take([:user, :content])
    |> Map.put(:id, "taut_msg_#{id}")
  end

end
