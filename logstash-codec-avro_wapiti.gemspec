Gem::Specification.new do |s|
  s.name          = 'logstash-codec-avro_wapiti'
  s.version       = '1.2.1'
  s.licenses      = ['Apache-2.0']
  s.summary         = "Encode and decode avro formatted data for a Kafka/AVRO Wapiti schema"
  s.description     = "Encode and decode avro formatted data for a Kafka/AVRO Wapiti schema"
  s.authors         = ["Cameron Kerr"]
  s.email           = 'cameronkerrnz@gmail.com'
  s.homepage        = "https://github.com/cameronkerrnz/logstash-codec-avro_wapiti"
  s.require_paths   = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "codec" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_runtime_dependency "logstash-codec-line"
  s.add_runtime_dependency "avro"  #(Apache 2.0 license)
  s.add_runtime_dependency "schema_registry", ">= 0.1.0" #(MIT license)
  s.add_development_dependency "logstash-devutils"
end
