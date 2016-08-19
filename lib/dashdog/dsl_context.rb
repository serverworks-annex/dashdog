require 'hashie'

module Dashdog
  class DSLContext
    def initialize
      @boards = {'timeboards' => [], 'screenboards' => []}
      @templates = {}
      @context = Hashie::Mash.new()
    end

    def eval_dsl(dsl_file)
      @_dsl_file = dsl_file
      instance_eval(File.read(dsl_file), dsl_file)
      @boards
    end

    private

    def template(name, &block)
      @templates[name.to_s] = block
    end

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
      hash = dslh_eval(block)
      hash['title'] = value
      @boards['timeboards'] << hash
    end

    def screenboard(value = nil, &block)
      hash = dslh_eval(block)
      hash['board_title'] = value
      @boards['screenboards'] << hash
    end

    def dslh_eval(block)
      scope_hook = proc do |scope|
        scope.instance_eval(<<-'EOS')
          def include_template(template_name, context = {})
            tmplt = @templates[template_name.to_s]

            unless tmplt
              raise "Template '#{template_name}' is not defined"
            end

            context_orig = @context
            @context = @context.merge(context)
            instance_eval(&tmplt)
            @context = context_orig
          end

          def context
            @context
          end
        EOS
      end

      scope_vars = {templates: @templates, context: @context}

      Dslh.eval(allow_empty_args: true, scope_hook: scope_hook, scope_vars: scope_vars, &block)
    end
  end
end
