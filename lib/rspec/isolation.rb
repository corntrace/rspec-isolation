module RSpec
  module Isolation
    def run_in_isolation
      example.metadata[:run_in_isolation] = true
    end
  end
end

# $LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rspec/isolation/core_ext'