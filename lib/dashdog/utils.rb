require 'json'
require 'diffy'
require 'coderay'

module Dashdog
  class Utils

    def self.diff(hash1, hash2)
      Diffy::Diff.new(
        JSON.pretty_generate(self.deep_sort_hash(hash1)) + "\n",
        JSON.pretty_generate(self.deep_sort_hash(hash2)) + "\n",
        :diff => '-u'
      ).to_s(:color)
    end

    def self.print_yaml(yaml)
      CodeRay::Encoders::Terminal::TOKEN_COLORS[:key] = {
        self: "\e[32m",
      }
      puts CodeRay.scan(yaml, :yaml).terminal
    end

    def self.print_ruby(ruby, options = {})
      if options[:color]
        puts CodeRay.scan(ruby, :ruby).terminal
      else
        puts ruby
      end
    end

    def self.print_json(json)
      puts CodeRay.scan(json, :json).terminal
    end

    def self.deep_sort_hash(obj)
      case obj
      when Hash
        new_hash = {}

        obj.sort_by{|k, _| k.to_s }.each do |key, value|
          new_hash[key] = self.deep_sort_hash(value)
        end

        new_hash
      when Array
        obj.map do |value|
          self.deep_sort_hash(value)
        end
      else
        obj
      end
    end
  end
end
