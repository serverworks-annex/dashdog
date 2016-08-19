require 'thor'

module Dashdog
  class Cli < Thor
    class_option :file, aliases: '-f', desc: 'Configuration file', type: :string, default: 'Boardfile'
    class_option :color, desc: 'Disable colorize', type: :boolean, default: $stdout.tty?

    def initialize(*args)
      @actions = Dashdog::Actions.new
      super(*args)
    end

    desc "export", "Export the dashboard configurations"
    option :write, aliases: '-w', desc: 'Write the configuration to the file', type: :boolean, default: false
    option :split, desc: 'Split the configuration', type: :boolean, default: false
    def export
      @actions.export(options)
    end

    desc "apply", "Apply the dashboard configurations"
    option :dry_run, aliases: '-d', desc: 'Dry run (Only output the difference)', type: :string, default: false
    def apply
      @actions.apply(options)
    end
  end
end
