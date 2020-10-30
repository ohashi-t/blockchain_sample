require 'timeout'
require 'socket'
require 'pry'


class Neighbor
  def is_found_host(host, port)
    begin
      Timeout.timeout(1) do
        Socket.tcp(host, port)
      end
    rescue
      p "#{host}:#{port} err"
      return false
    end
    true
  end

  PATTERN = Regexp.new(/^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.){3})(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/)

  def find_neighbors(my_host, my_port, start_ip, end_ip, start_port, end_port)
    address = "#{my_host}:#{my_port}"
    m = my_host.match(PATTERN)
    return nil unless m
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

  def get_host
    # Socket.ip_address_list.find do |addr|
    #   addr.ipv4? && !addr.ipv4_loopback? && !addr.ipv4_multicast?
    # end.ip_address
    "127.0.0.1"
  end
end
