module Jeql
  class Query

    def initialize(query_name, source_dir, endpoint_config)
      @query_name = query_name
      @query_file = File.read File.expand_path "./_graphql/#{query_name}.json", source_dir
      @endpoint_config = endpoint_config
    end

    def response
      @memoized_responses ||= {}
      @memoized_responses["#{@query_name}"] ||= execute
    end

    private

    def execute
      conn = Faraday.new(url: @endpoint_config["url"])
      response = conn.post do |req|
        req.headers = (@endpoint_config["header"] || {}).merge('Content-Type' => 'application/json')
        req.body = @query_file
      end
    end
  end
end
