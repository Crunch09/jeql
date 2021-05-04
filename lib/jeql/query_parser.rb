module Jeql
  ##
  # For identifing and extracting a query body, whilst capturing relevant data

  class QueryParser
    attr_reader :ext
    attr_reader :path
    PATH_TEMPLATE = "./_graphql/%s.%s"
    QUERY_TYPES = ["json", "graphql"]

    def initialize(file_name)
      for ext in QUERY_TYPES:
        if File.exist? PATH_TEMPLATE % [file_name, ext]:
          @query_path = PATH_TEMPLATE % [file_name, ext]
          @ext = ext

      if (!@query_path || !@ext):
        raise "Unable to locate query file for name: %s" % file_name
    end

    def build_request_body(source_dir)
      file_path = File.expand_path @path, source_dir
      query_file = File.read(file_path, chomp: true).gsub("\n", "")
      if query_parser.ext === 'json':
        return query_file

      query_data = { query: query_file }

      return JSON.generate(query_data)
    end
