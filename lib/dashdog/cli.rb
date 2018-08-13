require 'thor'

module Dashdog
  class Cli < Thor
    class_option :file,          aliases: '-f', desc: 'Configuration file',        type: :string,  default: 'Boardfile'
    class_option :color,                        desc: 'Disable colorize',          type: :boolean, default: $stdout.tty?
    class_option :exclude_title, aliases: '-e', desc: 'Exclude patterns of title', type: :string,  default: nil

    def initialize(*args)
      @actions = Dashdog::Actions.new
      super(*args)
    end

    desc "export", "Export the dashboard configurations"
    option :write, aliases: '-w', desc: 'Write the configuration to the file', type: :boolean, default: false
    option :split, desc: 'Split configuration file', type: :boolean, default: false
    def export
      @actions.export(options)
    end

    desc "apply", "Apply the dashboard configurations"
    option :dry_run, aliases: '-d', desc: 'Dry run (Only display the difference)', type: :boolean, default: false
    def apply
      @actions.apply(options)
    end
  end
end
