module Dashdog
  class DSLContext
    def initialize
      @boards = {'timeboards' => [], 'screenboards' => []}
    end

    def eval_dsl(dsl_file)
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
