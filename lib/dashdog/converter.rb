require 'dslh'

DELETE_KEYS = ['id', 'board_title', 'created', 'modified']

module Dashdog
  class Converter
    def initialize
      @boards = {'timeboards' => [], 'screenboards' => []}
    end

    def timeboards_to_dsl(tbs)
      exclude_key = proc do |k|
        false
      end

      ret = ''
      tbs.each do |tb|
        title = tb['title']
        DELETE_KEYS.each {|k| tb.delete(k) }
        dsl = Dslh.deval(
          tb,
          exclude_key: exclude_key)
        dsl.gsub!(/^/, '  ').strip!
        ret << <<-EOS
timeboard #{title.inspect} do
  #{dsl}
end

EOS
      end
      ret
    end

    def screenboards_to_dsl(screenboards)
      exclude_key = proc do |k|
          false
      end

      ret = ''
      screenboards.each do |sb|
        title = sb['board_title']
        DELETE_KEYS.each {|k| sb.delete(k) }
        widgets = sb['widgets'] || []
        sb['widgets'] = []
        widgets.each do |wd|
          wd.delete('board_id')
          sb['widgets'] << wd
        end
        dsl = Dslh.deval(
          sb,
          exclude_key: exclude_key)
        dsl.gsub!(/^/, '  ').strip!
        ret << <<-EOS
screenboard #{title.inspect} do
  #{dsl}
end

EOS
      end
      ret
    end

    def to_h(dsl_file)
      @_dsl_file = dsl_file
      instance_eval(File.read(dsl_file), dsl_file)
      @boards
    end

    private

    def require(file)
      boardfile = (file =~ %r|\A/|) ? file : File.expand_path(File.join(File.dirname(@_dsl_file), file))

      if File.exist?(boardfile)
        instance_eval(File.read(boardfile), boardfile)
      elsif File.exist?(boardfile + '.rb')
        instance_eval(File.read(boardfile + '.rb'), boardfile + '.rb')
      else
        Kernel.require(file)
      end
    end

    def timeboard(value = nil, &block)
      hash = Dslh.eval(
        allow_empty_args: true,
        &block)
      hash['title'] = value
      @boards['timeboards'] << hash
    end

    def screenboard(value = nil, &block)
      hash = Dslh.eval(
        allow_empty_args: true,
        &block)
      hash['board_title'] = value
      @boards['screenboards'] << hash
    end

  end
end
