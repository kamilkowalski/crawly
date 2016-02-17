require "codeclimate-test-reporter"

if ENV["COVERAGE"]
  CodeClimate::TestReporter.start
end

require "minitest/autorun"
require "crawly"
