defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

    test "caches 3 most recent pledges and totals amount" do
      PledgeServer.start_link([])

      PledgeServer.create_pledge("larry", 10)
      PledgeServer.create_pledge("moe", 20)
      PledgeServer.create_pledge("curly", 30)
      PledgeServer.create_pledge("aubrey", 40)
      PledgeServer.create_pledge("andy", 50)

      most_recent_pledges = [{"andy", 50}, {"aubrey", 40}, {"curly", 30}]

      assert PledgeServer.recent_pledges() == most_recent_pledges
      assert PledgeServer.total_pledged() == 120
    end
end
