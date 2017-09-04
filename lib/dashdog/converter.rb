require 'dslh'

DELETE_KEYS = ['id', 'board_title', 'created', 'modified', 'created_by']

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
      context = DSLContext.new
      context.eval_dsl(dsl_file)
    end
  end
end
