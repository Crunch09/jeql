module Jeql
  class Query
    attr_reader :query_name

    def initialize(query_name, source_dir, endpoint_config)
      file_path = File.expand_path "./_graphql/#{query_name}.graphql", source_dir
      @query_name = query_name
      @query_file = File.read(file_path, chomp: true).gsub("\n", "")
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
        req.body = package_query
      end
    end

    def package_query
      query_data = { query: @query_file }
      return JSON.generate(query_data)
    end

    def timeout_settings
      {open_timeout: 2, timeout: 2}
    end
  end
end
