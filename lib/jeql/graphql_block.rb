class Jeql::GraphqlBlock < Liquid::Block
  GraphQlError = Class.new(Jekyll::Errors::FatalException)
  PARAMS_SYNTAX = /(\w+):\s*['"](\w+)['"],?/

  def initialize(tag_name, text, tokens)
    super
    @params = text.scan(PARAMS_SYNTAX)
    @text = text
  end

  def render(context)
    hash_params = {}
    @params.each {|k, v| hash_params[k] = v}

    endpoint_config = context.registers[:site].config["jeql"][hash_params["endpoint"]]
    query = Jeql::Query.new(hash_params["query"], context.registers[:site].config["source"], endpoint_config)
    if query.response.success?
      context['data'] = JSON.parse(query.response.body)['data']
      super
    else
      raise GraphQlError, "The query #{query.query_name} failed"
    end
  end
end

Liquid::Template.register_tag('graphql', Jeql::GraphqlBlock)
