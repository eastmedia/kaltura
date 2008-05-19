module ActiveResource
  class Connection
    private
    def request(method, path, *arguments)
      logger.info "#{method.to_s.upcase} #{site.scheme}://#{site.host}:#{site.port}#{path}" if logger
      result = nil
      time = Benchmark.realtime { result = http.send(method, path, *arguments) }
      logger.info "--> #{result.code} #{result.message} (#{result.body ? result.body.gsub('%', '%%') : 0}b %.2fs)" % time if logger
      handle_response(result)
    end
  end
end