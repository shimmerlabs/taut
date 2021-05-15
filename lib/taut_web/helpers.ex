defmodule TautWeb.Helpers do
  import Phoenix.LiveView

  # POSSIBLE DEPRECATION:  Just pass Taut.User to widget for now
  def default_user(_, _) do
    %Taut.User{display_name: "Anonymous", role: "visitor"}
  end

  # POSSIBLE DEPRECATION:  Just pass Taut.user to widget for now
  def get_user_from_session(socket, session) do
    Application.get_env(:taut, :user_identity, &default_user/2).(socket, session)
  end

  def assign_core_state(socket, %Taut.User{}=user) do
    assign(socket, :taut, %{
      user: user
    })
  end

  def assign_core_state(socket, nil) do
    assign(socket, :taut, %{
      user: nil
    })
  end
  
  def assign_core_state(socket, session) do
    assign_core_state(socket, get_user_from_session(socket, session))
  end

end
