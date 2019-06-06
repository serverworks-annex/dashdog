require 'yaml'
require 'json'

module Dashdog
  class Actions
    include Dashdog::Logger::Helper

    def initialize
      @client = Dashdog::Client.new
      @converter = Dashdog::Converter.new
    end

    def export(options)
      dsl = @converter.timeboards_to_dsl(@client.get_timeboards)
      dsl << @converter.screenboards_to_dsl(@client.get_screenboards)
      if options['write']
        _export_to_file(dsl, options)
      else
        Dashdog::Utils.print_ruby(dsl, color: options[:color])
      end
    end

    def apply(options)
      dry_run = options['dry_run'] ? '[Dry run] ' : ''
      conf = @converter.to_h(options['file'])

      _apply_timeboards(conf['timeboards'], @client.get_timeboards, dry_run, options)
      _apply_screenboards(conf['screenboards'], @client.get_screenboards, dry_run, options)
    end

    private

    def _apply_timeboards(local, remote, dry_run, options)
      local.each do |l|
        next if !options['exclude_title'].nil? && l['title'].match(options['exclude_title'])
        r = _choice_by_title(remote, l['title'])
        if r.nil? || options['ignore_exists']
          info("#{dry_run}Create the new timeboard '#{l['title']}'")
          @client.create_timeboard(l) if dry_run.empty?
        else
          l['id'] = r['id']
          ['created', 'modified', 'created_by'].each do |field|
            r.delete(field)
            l.delete(field)
          end
          if l == r
            info("#{dry_run}No changes '#{l['title']}'")
          else
            warn("#{dry_run}Update the timeboard '#{l['title']}'")
            STDERR.puts Dashdog::Utils.diff(r, l)
            @client.update_timeboard(l) if dry_run.empty?
          end
        end
      end

      remote.each do |r|
        next if (!options['exclude_title'].nil? && r['title'].match(options['exclude_title'])) || options['ignore_exists']
        if _choice_by_title(local, r['title']).nil?
          warn("#{dry_run}Delete the timeboard '#{r['title']}'")
          @client.delete_timeboard(r['id']) if dry_run.empty?
        end
      end
    end

    def _apply_screenboards(local, remote, dry_run, options)
      local.each do |l|
        next if !options['exclude_title'].nil? && l['title'].match(options['exclude_title'])
        r = _choice_by_title(remote, l['board_title'])
        if r.nil? || options['ignore_exists']
          info("#{dry_run}Create the new screenboards '#{l['board_title']}'")
          @client.create_screenboard(l) if dry_run.empty?
        else
          l['id'] = r['id']
          ['created', 'modified', 'created_by'].each do |field|
            r.delete(field)
            l.delete(field)
          end
          widgets = r['widgets'] || []
          r['widgets'] = []
          widgets.each do |wd|
            wd.delete('board_id')
            r['widgets'] << wd
          end
          l['widgets'] = [] if widgets.empty?
          if l == r
            info("#{dry_run}No changes '#{l['board_title']}'")
          else
            warn("#{dry_run}Update the screenboard '#{l['board_title']}'")
            STDERR.puts Dashdog::Utils.diff(r, l)
            @client.update_screenboard(l) if dry_run.empty?
          end
        end
      end

      remote.each do |r|
        next if (!options['exclude_title'].nil? && r['title'].match(options['exclude_title'])) || options['ignore_exists']
        if _choice_by_title(local, r['board_title']).nil?
          warn("#{dry_run}Delete the screenboard '#{r['board_title']}'")
          @client.delete_screenboard(r['id']) if dry_run.empty?
        end
      end
    end

    def _choice_by_title(boards, title)
      boards.each do |b|
        return b if b['title'] == title
        return b if b['board_title'] == title
      end
      nil
    end

    def _export_to_file(dsl, options)
      file = options['file']

      if options['split']
        dsls = dsl.strip.split(/^(timeboard|screenboard)\b/).slice(1..-1).each_slice(2).map(&:join)
        requires = []

        dsls.each do |splitted|
          splitted.strip!
          title = splitted.each_line.first.strip.gsub(/\A(?:timeboard|screenboard)\s+"([^"]+)"\s+do/, '\\1')
          title.gsub!(/\W+/, '_')
          requires << title
          File.write("#{title}.rb", splitted + "\n")
          info("Write '#{title}.rb'")
        end

        open(file, 'w') do |f|
          requires.each {|r| f.puts "require #{r.inspect}" }
        end

        info("Write '#{file}'")
      else
        File.write(file, dsl)
        info("Write '#{file}'")
      end
    end
  end
end
