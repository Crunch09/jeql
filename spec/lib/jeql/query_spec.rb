RSpec.describe Jeql::Query do
  # Jeql::Query.new(hash_params["query"], context.registers[:site].config["source"], endpoint_config)
  let(:query_name) { "last_repos" }
  let(:request_body_name) { "request_body" }
  let(:url) { "https://api.github.com/graphql" }
  let(:faraday_response) { "last_repos_success" }
  let(:response_body) { File.read(File.expand_path("responses/#{faraday_response}.json", source_dir)) }
  let(:response_status) { 200 }

  subject do
    described_class.new(query_name, source_dir, {"url" => url})
  end

  describe "response" do
    before do
      f = File.read(File.expand_path("_graphql/#{request_body_name}.json", source_dir))
      stub_request(:post, url)
        .with(body: f, headers: {'Content-Type' => 'application/json'})
        .to_return(status: response_status, body: response_body)
      Jekyll.logger.log_level = :error
    end

    it "executes the query" do
      response = subject.response
      expect(subject.response.status).to be response_status
      expect(subject.response.body).to eq response_body
    end

    it "memoizes the result" do
      subject.response
      subject.response
      expect(WebMock).to have_requested(:post, url).once
    end
  end
end
