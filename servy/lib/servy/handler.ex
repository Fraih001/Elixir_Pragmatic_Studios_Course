defmodule Servy.Handler do
  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam
  @moduledoc """
  Handles HTTP requests.
  """
  @pages_path Path.expand("../../pages", __DIR__)
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]
  import Servy.View, only: [render: 3]

  @doc """
  Transforms the request into a response
  """

  def handle(request) do
    request
    # |> IO.inspect()
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    # |> emojify()
    |> track()
    |> put_content_length()
    |> format_response()
  end


  def route(%Conv{method: "GET", path: "/404s"} = conv) do
    counts = Servy.FourOhFourCounter.get_counts()

    %{ conv | status: 200, resp_body: inspect counts }
  end

  def route(%Conv{method: "GET", path: "/pledges/new"} = conv) do
    Servy.PledgeController.new(conv)
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do
    sensor_data = Server.SensorServer.get_sensor_date()

    conv = %{ conv | status: 200, resp_body: inspect sensor_data }
    render(conv, "sensors.eex", resp_body: sensor_data )
  end



  def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer |> :timer.sleep

    %{ conv | status: 200, resp_body: "Awake!" }
  end

  def route(%Conv{ method: "GET", path: "/kaboom" } = conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)

    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
      |> Path.join("about.html")
      |> File.read()
      |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read
    |> handle_file(conv)
  end

  # def route(%{method: "GET", path: "/about"} = conv) do
  #   file =
  #     Path.expand("../../pages", __DIR__)
  #     |> Path.join("about.html")

  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{conv | status: 200, resp_body: content}

  #     {:error, :enoent} ->
  #       %{conv | status: 404, resp_body: "File Not Found"}

  #     {:error, reason} ->
  #       %{conv | status: 500, resp_body: "Fire error: #{reason}"}
  #   end
  # end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)

    BearController.delete(conv, params)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def route(%Conv{method: "GET", path: "/pages/" <> name} = conv) do
    @pages_path
    |> Path.join("#{name}.md")
    |> File.read
    |> handle_file(conv)
    |> markdown_to_html
  end

  def markdown_to_html(%Conv{status: 200} = conv) do
    %{ conv | resp_body: Earmark.as_html!(conv.resp_body) }
  end

  def markdown_to_html(%Conv{} = conv), do: conv

  # def emojify(%Conv{status: 200, resp_body: resp_body} = conv) do
  #   %{conv | resp_body: "🎉🎉🎉🎉" <> resp_body <> "🎉🎉🎉🎉"}
  # end

  # def emojify(%Conv{} = conv), do: conv

  def put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{ conv | resp_headers: headers }
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  defp format_response_headers(conv) do
    Enum.map(conv.resp_headers, fn {key, value} ->
      "#{key}: #{value}\r"
    end) |> Enum.sort |> Enum.reverse |> Enum.join("\n")
  end
end
