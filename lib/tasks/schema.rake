namespace :schema do
  # The public schema will evolve over time, so you'll want to periodically
  # refetch the latest and check in the changes.
  #
  # An offline copy of the schema allows queries to be typed checked statically
  # before even sending a request.
  desc "Update GitHub GraphQL schema"
  task :update => [:clobber, "db/schema.json"]

  task :clobber do
    rm "db/schema.json"
  end

  file "db/schema.json" => :environment do
    document = GraphQL.parse(GraphQL::Introspection::INTROSPECTION_QUERY)
    # TODO: Access token shouldn't be required to fetch schema
    context = { access_token: Rails.application.secrets.github_access_token }
    schema = GitHub::HTTPAdapter.call(document, {}, context)
    File.open("db/schema.json", 'w') { |f| f.write(JSON.pretty_generate(schema)) }
  end
end
