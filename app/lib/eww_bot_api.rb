require 'net/http'
require 'uri'
require 'json'
class EwwBotApi
  def self.reload_modules
    self.client(
      action: "POST",
      endpoint: "/reload_commands"
    )
  end

  def self.modules
    self.client(
      action: "GET",
      endpoint: "/modules"
    )
  end

  def self.reload_task(task)
    self.client(
      action: "POST",
      endpoint: "/reload_tasks/#{task}"
    )
  end

  private
  def self.client(action:, endpoint:)
    api_endpoint = "http://localhost:8000#{endpoint}"
    # Create a URI object with the API endpoint
    uri = URI(api_endpoint)

    # Create an HTTP request
    case action
    when "GET"
      request = Net::HTTP::Get.new(uri)
    when "POST"
      request = Net::HTTP::Post.new(uri)
    else
      # type code here
    end

    # Make the HTTP request
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    # Check the response and parse JSON if successful
    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      JSON.parse(response.body)
    end
  end
end