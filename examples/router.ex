defmodule Examples.Router do
  import Percussion.Decorators
  import Percussion.Dispatcher, only: [command: 2, command: 3, router: 1]
  import Percussion.Request

  defmodule GuildCog do
    def routes do
      router([
        rules()
      ])
    end

    @doc """
    Shows this server's rules.
    """
    def rules do
      command("rules", &rules/1, description: @doc)
    end

    defp rules(request) do
      reply(request, "You should probably put your server rules here...")
    end
  end

  defmodule RolesCog do
    def routes do
      router([
        assign(),
        unassign()
      ])
    end

    @doc """
    Assigns the specified self-assignable roles to yourself.
    """
    def assign do
      command("assign", &assign/1, description: @doc, aliases: ["iam"])
    end

    defp assign(request) do
      halt(request, "Roles assigned!")
    end

    @doc """
    Removes the specified self-assignable roles from yourself.
    """
    def unassign do
      command("unassign", &unassign/1, description: @doc, aliases: ["iamn", "iamnot"])
    end

    defp unassign(request) do
      halt(request, "Roles removed!")
    end
  end

  def routes do
    router([
      ping(),
      default(),
      GuildCog.routes(),
      RolesCog.routes()
    ])
  end

  def default() do
    command(nil, &halt(&1, "This command does not exist!"))
  end

  def ping do
    command("ping", &ping/1, pipe: [help("ping - send ICMP ECHO_REQUEST to network hosts")])
  end

  defp ping(request) do
    reply(request, "Pong!")
  end
end
