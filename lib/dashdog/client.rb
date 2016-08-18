require 'dogapi'
require 'parallel'

module Dashdog
  class Client

    def initialize
      @api = Dogapi::Client.new(ENV['DD_API_KEY'], ENV['DD_APP_KEY'])
    end

    def get_timeboards
      ret = []
      Parallel.each(@api.get_dashboards[1]['dashes'], in_threads: 8)  do |bd|
        ret << @api.get_dashboard(bd['id'])[1]['dash']
      end
      return ret
    end

    def get_screenboards
      ret = []
      Parallel.each(@api.get_all_screenboards[1]['screenboards'], in_threads: 8) do |bd|
        ret << @api.get_screenboard(bd['id'])[1]
      end
      return ret
    end

    def create_timeboard(tb)
      ret = @api.create_dashboard(
        tb['title'],
        tb['description'],
        tb['graphs'],
        tb['template_variables'])
      raise RuntimeError, ret[1]['errors'] if ret[0] != '200'
    end

    def update_timeboard(tb)
      ret = @api.update_dashboard(
        tb['id'],
        tb['title'],
        tb['description'],
        tb['graphs'],
        tb['template_variables'])
      raise RuntimeError, ret[1]['errors'] if ret[0] != '200'
    end

    def delete_timeboard(id)
      ret = @api.delete_dashboard(id)
      raise RuntimeError, ret[1]['errors'] if ret[0] != '200'
    end

    def create_screenboard(sb)
      ret = @api.create_screenboard(sb)
      raise RuntimeError, ret[1]['errors'] if ret[0] != '200'
    end

    def update_screenboard(sb)
      id = sb['id']
      sb.delete('id')
      ret = @api.update_screenboard(id, sb)
      raise RuntimeError, ret[1]['errors'] if ret[0] != '200'
    end

    def delete_screenboard(id)
      ret = @api.delete_screenboard(id)
      raise RuntimeError, ret[1]['errors'] if ret[0] != '200'
    end
  end
end
