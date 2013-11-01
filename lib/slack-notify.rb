require "slack-notify/version"
require "slack-notify/error"

require "json"
require "faraday"

module SlackNotify
  class Client
    def initialize(team, token, options={})
      @team     = team
      @token    = token
      @username = options[:username] || "webhookbot"
      @channel  = options[:channel] || "#general"

      raise ArgumentError, "Subdomain required" if @team.nil?
      raise ArgumentError, "Token required"     if @token.nil?
    end

    def test
      notify("This is a test message!")
    end

    def notify(text, channel=nil)
      send_payload(
        text: text,
        channel: channel || @channel,
        username: @username
      )
    end

    private

    def send_payload(payload)
      response = Faraday.post(hook_url) do |req|
        req.body = JSON.dump(payload)
      end

      if response.success?
        true
      else
        if response.body.include?("\n")
          raise SlackNotify::Error
        else
          raise SlackNotify::Error.new(response.body)
        end
      end
    end

    def hook_url
      "https://#{@team}.slack.com/services/hooks/incoming-webhook?token=#{@token}"
    end
  end
end