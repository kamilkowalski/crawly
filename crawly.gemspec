require File.expand_path('../lib/crawly/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "crawly"
  s.version     = Crawly::VERSION
  s.authors     = ["Kamil Kowalski"]
  s.email       = "kamil@kamilkowalski.pl"
  s.homepage    = "https://github.com/kamilkowalski/crawly"
  s.license     = "MIT"
  s.summary     = "A simple DSL and web crawler extracting text for language corpora"
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files`.split("\n")

  s.add_development_dependency "rake",                      "~> 10.0"
  s.add_development_dependency "minitest",                  "~> 5.8"
  s.add_development_dependency "codeclimate-test-reporter", "~> 0.4"

  s.add_runtime_dependency "nokogiri",                      "~> 1.6"
  s.add_runtime_dependency "pg",                            "~> 0.18"
end
