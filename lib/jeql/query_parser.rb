module Jeql
  ##
  # For identifing and extracting a query body, whilst capturing relevant data
  class QueryParser
    attr_reader :ext, :path

    PATH_TEMPLATE = './_graphql/%s.%s'.freeze
    QUERY_TYPES = %w[json graphql].freeze

    def initialize(file_name)
      QUERY_TYPES.each do |ext|
        if File.exist? format(PATH_TEMPLATE, file_name, ext)
          @query_path = format(PATH_TEMPLATE, file_name, ext)
          @ext = ext
        end
      end
      raise format('Unable to locate query file for name: %s', file_name) if !@query_path || !@ext
    end

    def build_request_body(source_dir)
      file_path = File.expand_path @path, source_dir
      query_file = File.read(file_path, chomp: true).gsub("\n", '')
      query_parser.ext == 'json' if return query_file
      query_data = { query: query_file }

      return JSON.generate(query_data)
    end
  end
end
