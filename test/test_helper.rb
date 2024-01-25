# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "bundler/setup"
require "epub-rb"

require "minitest/utils"
require "minitest/autorun"

Dir["#{__dir__}/support/**/*.rb"].each do |file|
  require file
end

module Minitest
  class Test
    setup do
      FileUtils.rm_rf File.join(__dir__, "..", "tmp")
    end
  end
end
