require 'json'
require 'diffy'
require 'coderay'

module Dashdog
  class Utils

    def self.diff(hash1, hash2)
      Diffy::Diff.new(
        JSON.pretty_generate(hash1),
        JSON.pretty_generate(hash2),
        :diff => '-u'
      ).to_s(:color)
    end

    def self.print_yaml(yaml)
      CodeRay::Encoders::Terminal::TOKEN_COLORS[:key] = {
        self: "\e[32m",
      }
      puts CodeRay.scan(yaml, :yaml).terminal
    end

    def self.print_ruby(ruby)
      puts CodeRay.scan(ruby, :ruby).terminal
    end

    def self.print_json(json)
      puts CodeRay.scan(json, :json).terminal
    end
  end
end
