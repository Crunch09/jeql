class Jeql::GraphqlBlock < Liquid::Block

  def initialize(tag_name, text, tokens)
    super
    @params = text.strip.split(',').map(&:strip).map{|s| s.gsub(%r!['"]!, '').split(':').map(&:strip)}
    @text = text
  end

  def render(context)
    hash_params = {}
    @params.each {|k, v| hash_params[k] = v}

    endpoint_config = context.registers[:site].config["jeql"][hash_params["endpoint"]]
    query = Jeql::Query.new(hash_params["query"], context.registers[:site].config["source"], endpoint_config)

    context['data'] = JSON.parse(query.response.body)['data']
    super
  end
end

Liquid::Template.register_tag('graphql', Jeql::GraphqlBlock)
