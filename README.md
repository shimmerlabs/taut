# Taut

Taut is not Slack.

Taut is a multi-room chat system, like Slack and so many other systems.  Why
build another one?  Because so many chat systems out there are overloaded with
bad Javascript, or they're designed to run in iframe tags, which are not only
problematic from a security setup, but are expected to "go away" at some point
in the future.

Taut is designed to be used either as a library for your existing Phoenix app,
so it can run directly as a subsystem to your app and embedded directly into
your templates (no iframes, no machine names, etc) -- or as a standalone
server intended to be hosted with a subdirectory route, so your user's
session cookies are already being sent and you can use a backplane API call
to handle authentication.

## Current Status

Taut is currently early in development, so it's rough and changing quickly.
The first intended use is as a library, so the standalone bit isn't at all
really started.

If you'd like to help out or contribute, feel free!


## Setup

### As a Server/Service

TBD.  The intent is to provide a Dockerfile that can be installed into a
Kubernetes cluster, and then set up a path on the ingress that routes to
the pod, then configure the pod (with environment variables) to respond to
handle the subpath and to configure the backplane API call for authn.

### As a Phoenix (Elixir) Library

In progress.

Add to your mix.exs file:

```
  {:taut, git: "https://github.com/shimmerlabs/taut.git", branch: "master"}
```

#### Configuration 

In your `config.exs` file, add (at least):

```
config :taut, server: false
```

This tells Taut not to run its own Phoenix server, because you'll be handling
that part.  Then, configure the Repo it should use.  You can actually use
the same connection details as your main Ecto.Repo if you'd like; all the
tables are prefixed with `taut_` to help avoid conflicts with any other
tables you may have, or you can configure an additional database just for
Taut data.  Note that since this is an additional Ecto Repo, it's also a
separate connection pool, so if you completely copy your existing Ecto Repo
config, you'll double the connections to the one database.

```
config :taut, Taut.Repo,
  [see Ecto.Repo docs](https://hexdocs.pm/ecto/Ecto.Repo.html)
```

Until I can figure out a better way to expose the stylesheet from the library,
you can copy the file [widget.scss](https://github.com/shimmerlabs/taut/blob/master/assets/css/widget.scss) into your own CSS directory (or just copy the
content into your existing `.scss` file.  All the styles are prefixed with
`taut_` to avoid cross-contamination.

Additional config options:

* `:default_room_name` (default: "Welcome") sets what room a user will be subscirbed and connected to by default, if no room name is given to the widget (see below)
* `:formatter` (default: internal Markdown) can be set to a 1-arity function that takes the raw text input from a message submission and returns a formatted/sanitized version, if you want to add additional formatting options, disallow Markdown, or whatever.

#### Migrations

TODO:  Clarify/formalize this for if you don't have a copy of the source on
disk.

If you've set up a custom function for doing database migrations in your
production release (where Mix is not available), as
[described in the Phoenix docs](https://hexdocs.pm/phoenix/releases.html#ecto-migrations-and-custom-commands) then you'll just want to add Taut.Repo to the
list and :taut as an additional app.  For example, the last two functions I
have look like:

```elixir
  defp repos do
    Application.fetch_env!(@app, :ecto_repos) ++ [Taut.Repo]
  end

  defp load_app do
    Application.ensure_all_started(@app)
    Application.ensure_all_started(:taut)
  end
```

#### Embedding

This is the easy part.  You can simply render the widget into your template:

```
  <%= Taut.Room.widget(@socket, @taut_user, @room_name) %>
```

`@room_name` is optional -- it defaults to "Welcome" (or what you configured
above)

`@taut_user` is a Taut.User structure filled in with the fields `foreign_id`,
`display_name` and optionally, `role` (defaults to "visitor").  This is used
to look up or create the User in the Taut system.  Since you're probably
already authenticating your users, it's recommended you put your app's
user ID (primary key) in as the `foreign_id` field and set the `display_name`
to whatever (user's username, or maybe full name, etc).  If the foreign ID
passed is not found in the Taut tables, the user will be created and
subscribed to the room being connected.  If you pass an existing ID and
change the other fields, the Taut table will update the record with the new
information (so if your user changes their name, the next time they load the
widget, they will be updated with the new name).


