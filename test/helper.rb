require "minitest/autorun"
require "crawly"
require "codeclimate-test-reporter"

if ENV["COVERAGE"]
  CodeClimate::TestReporter.start
end
