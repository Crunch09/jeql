class Jeql::GraphqlBlock < Liquid::Block
  GraphQlError = Class.new(Jekyll::Errors::FatalException)
  PARAMS_SYNTAX = /(\w+):\s*['"](\w+)['"],?/

  def initialize(tag_name, text, tokens)
    super
    @params = text.scan(PARAMS_SYNTAX)
    @text = text
  end

  def render(context)
    hash_params = Hash[@params]

    endpoint_config = context.registers[:site].config["jeql"][hash_params["endpoint"]]
    query = Jeql::Query.new(hash_params["query"], context.registers[:site].config["source"], endpoint_config)
    if query.response.success?
      context['data'] = JSON.parse(query.response.body)['data']
      super
    else
      responseBody = JSON.parse(query.response.body)
      message = responseBody.key?("message") ? "Endpoint responded: #{responseBody['message']}" : ""
      raise GraphQlError, "The query #{query.query_name} failed. " + message 
    end
  end
end

Liquid::Template.register_tag('graphql', Jeql::GraphqlBlock)
