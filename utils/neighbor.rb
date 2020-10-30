require 'timeout'
require 'socket'
require 'pry'

def is_found_host(host, port)
  # Timeout.timeout(1) do
  #   _o, err, _s = Socket.tcp(host, port)
  # end
  # binding.pry
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