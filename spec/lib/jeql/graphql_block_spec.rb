RSpec.describe Jeql::GraphqlBlock do
  let(:config)  do
    {
      "title" => "site title",
      "jeql" => {
        "github" => {
          "url" => "https://api.github.com/graphql",
          "header" => {
            "Authorization" => "bearer abc123"
          }
        }
      }
    }
  end
  let(:page_meta) { {} }
  let(:page)      { make_page(page_meta) }
  let(:site)      { make_site(config) }
  let(:render_context) { make_context(:page => page, :site => site) }
  let(:text) { "endpoint: 'github', query: 'last_repos' " }
  let(:tag_name) { "graphql" }
  let(:template) {
    <<~TEMPLATE
    {% for repo in data["viewer"]["repositories"]["nodes"] %}
    <li>{{repo["name"]}}</li>
    {% endfor %}
    {% endgraphql %}
    TEMPLATE
  }
  let(:tokenizer) { Liquid::Tokenizer.new(template) }
  let(:parse_context) { Liquid::ParseContext.new }
  let(:rendered) { subject.render(render_context) }

  subject do
    tag = described_class.parse(tag_name, text, tokenizer, parse_context)
    tag.instance_variable_set("@context", render_context)
    tag
  end

  before do
    f = File.read(File.expand_path("_graphql/last_repos.json", source_dir))
    stub_request(:post, "https://api.github.com/graphql")
      .with(body: f, headers: {'Content-Type' => 'application/json'})
      .to_return(status: 200, body: File.read(File.expand_path("responses/last_repos_success.json", source_dir)))
    Jekyll.logger.log_level = :error
  end

  it "renders" do
    expected = "<li>jekyll</li>\n\n<li>jeql</li>\n\n<li>rails</li>"
    expect(rendered.strip).to eq(expected)
  end
end
