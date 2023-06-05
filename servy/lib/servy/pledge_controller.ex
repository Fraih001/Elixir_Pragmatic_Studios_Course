defmodule Servy.PledgeController do
  alias Servy.Conv
  alias Servy.PledgeServer

  import Servy.View

  def create(%Conv{} = conv, %{ "name" => name, "amount" => amount }) do
    # sends pledge to the external service and caches it
    PledgeServer.create_pledge(name, String.to_integer(amount))

    %{ conv | status: 200, resp_body: "#{name} pledged #{amount}!" }
  end

  def index(%Conv{} = conv) do
    # get recent pledges from cache
    pledges = PledgeServer.recent_pledges()

    # %{ conv | status: 200, resp_body: (inspect pledges) }
    render(conv, "recent_pledges.eex", pledges: pledges)
  end

  def new(%Conv{} = conv) do
    render(conv, "new_pledge.eex")
  end
end
