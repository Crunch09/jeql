module Jeql
  ##
  # For interfacing with a given GraphQl endpoint using a specific query file

  class Query
    attr_reader :query_name

    def initialize(query_name, source_dir, endpoint_config)
      @query_name = query_name
      query_parser = QueryParser.new(query_name)
      @query_file = query_parser.build_request_body(source_dir)
      @endpoint_config = endpoint_config
    end

    def response
      @memoized_responses ||= {}
      @memoized_responses[@query_name] ||= execute
    end

    private

    def execute
      conn = Faraday.new(url: @endpoint_config["url"], request: timeout_settings)
      response = conn.post do |req|
        req.headers = (@endpoint_config["header"] || {}).merge('Content-Type' => 'application/json')
        req.body = @query_file
      end
    end

    def timeout_settings
      {open_timeout: 2, timeout: 2}
    end
  end
end
