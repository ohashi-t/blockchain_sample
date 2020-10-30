require 'pry'
require_relative '../utils/neighbor'

# PATTERN = Regexp.new(/^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/)
PATTERN = Regexp.new(/^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.){3})(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/)

def find_neighbors(my_host, my_port, start_ip, end_ip, start_port, end_port)
  address = "#{my_host}:#{my_port}"
  m = my_host.match(PATTERN)
  return nil unless m
  binding.pry
  prefix_host = m[1]
  last_ip = m[-1].to_i
  neighbors = []

  start_port.upto(end_port) do |port|
    start_ip.upto(end_ip) do |ip|
      guess_host = prefix_host + (last_ip + ip).to_s
      guess_target = "#{guess_host}:#{port}"
      if guess_target != address && is_found_host(guess_host, port)
        neighbors << guess_target
      end
    end
  end
  neighbors
end

p find_neighbors("127.0.0.1", 5000, 0, 3, 5000, 5003)