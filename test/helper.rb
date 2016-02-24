require "codeclimate-test-reporter"

if ENV["COVERAGE"]
  CodeClimate::TestReporter.start
end

CRAWLSPEC_FILE = File.join(__dir__, "helpers", "crawlspec.rb")

require "minitest/autorun"
require "crawly"
