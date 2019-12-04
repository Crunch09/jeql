# jeql - Jekyll with GraphQL 

This is a quick fork to just change the Jekyll version to 4.x.

[![Build Status](https://travis-ci.org/Crunch09/jeql.svg?branch=master)](https://travis-ci.org/Crunch09/jeql) [![Gem Version](https://badge.fury.io/rb/jeql.svg)](https://badge.fury.io/rb/jeql)

## Installation

Add this to to your site's `Gemfile`:

  ```ruby
  gem 'jeql'
  ```

Add the following to your site's config file (usually `_config.yml`):

  ```yml
  plugins:
    - jeql
  ```
After this run `bundle install` within your site's directory.


## Usage

### GraphQL endpoints

You need to define graphQL endpoints within your Jekyll config. Within the key
`jeql` list all your providers in the format:
```yml
jeql:
  provider_name:
    url: "API_ENDPOINT_URL"
    header:
      Authorization: "HTTP AUTHORIZATION HEADER - SECRET"
```
An example config to access the graphQL - API from GitHub would look like this:
```yml
jeql:
  github:
    url: "https://api.github.com/graphql"
    header:
      Authorization: "bearer my-secret-header"
```

**Attention**: Make sure to *not* commit authorization tokens in a public repository.
Instead make use of Jekyll's multiple-config-file feature and add these tokens to a
private config file which is not checked into your version control system.

### GraphQL queries

Queries in `jeql` are specified as *json* files and live within the `_graphql` directory
of your Jekyll site.

An example query file would have the following content:

```json
{
  "query": "query { viewer { name repositories(last: 3){ nodes { name }} }}"
}
```
and would e.g. be stored as `/_graphql/last_touched_repositories.json`.

### Using it in liquid

After all this setup has been done you can now use the `graphql` block tag in your
template files.
The `graphql` tag expects two parameters:
- endpoint
- query

`endpoint` is the name of the graphQL - API endpoint as you have it defined in your
Jekyll config file. `query` is the name of the file under `_graphql` in which you stored
the graphQL query that should be executed against the endpoint (without the *.json* extension).

An example which uses the settings and query from the paragraphs above would look like this:

```html
{% graphql endpoint: "github", query: "last_touched_repositories" %}
...
{% endgraphql %}
```
Between the opening and closing `graphql` tag you have access to the variable `data`
which will contain the response of the graphQL query:

```html
<ul>
{% graphql endpoint: "github", query: "last_touched_repositories" %}
  {% for repo in data["viewer"]["repositories"]["nodes"] %}
    <li>{{repo["name"]}}</li>
  {% endfor %}
{% endgraphql %}
</ul>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Crunch09/jeql. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the jeql project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Crunch09/jeql/blob/master/CODE_OF_CONDUCT.md).

## Inspirations

This gem was inspired by [github-metadata](https://github.com/jekyll/github-metadata) and
[jekyll-seo-tag](https://github.com/jekyll/jekyll-seo-tag).
