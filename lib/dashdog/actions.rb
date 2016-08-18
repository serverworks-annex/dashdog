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
      Dashdog::Utils.print_ruby(dsl)
      File.write(options['file'], dsl) if options['write']
    end

    def apply(options)
      dry_run = options['dry_run'] ? '[Dry run] ' : ''
      conf = @converter.to_h(File.read(options['file']))

      _apply_timeboards(conf['timeboards'], @client.get_timeboards, dry_run)
      _apply_screenboards(conf['screenboards'], @client.get_screenboards, dry_run)
    end

    def _apply_timeboards(local, remote, dry_run)
      local.each do |l|
        r = _choice_by_title(remote, l['title'])
        if r.nil?
          info("#{dry_run}Create the new timeboard '#{l['title']}'")
          @client.create_timeboard(l) if dry_run.empty?
        else
          l['id'] = r['id']
          r.delete('created')
          r.delete('modified')
          if l == r
            info("#{dry_run}No changes '#{l['title']}'")
          else
            warn("#{dry_run}Update the timeboard\n#{Dashdog::Utils.diff(r, l)}")
            @client.update_timeboard(l) if dry_run.empty?
          end
        end
      end

      remote.each do |r|
        if _choice_by_title(local, r['title']).nil?
          warn("#{dry_run}Delete the timeboard '#{r['title']}'")
          @client.delete_timeboard(r['id']) if dry_run.empty?
        end
      end
    end

    def _apply_screenboards(local, remote, dry_run)
      local.each do |l|
        r = _choice_by_title(remote, l['board_title'])
        if r.nil?
          info("#{dry_run}Create the new screenboards '#{l['board_title']}'")
          @client.create_screenboard(l) unless dry_run.empty?
        else
          l['id'] = r['id']
          r.delete('created')
          r.delete('modified')
          widgets = r['widgets']
          r['widgets'] = []
          widgets.each do |wd|
            wd.delete('board_id')
            r['widgets'] << wd
          end
          if l == r
            info("#{dry_run}No changes '#{l['board_title']}'")
          else
            warn("#{dry_run}Update the screenboard '#{l['board_title']}'\n#{Dashdog::Utils.diff(r, l)}")
            @client.update_screenboard(l) if dry_run.empty?
          end
        end
      end

      remote.each do |r|
        if _choice_by_title(local, r['board_title']).nil?
          warn("#{dry_run}Delete the timeboard '#{r['board_title']}'")
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

  end
end
