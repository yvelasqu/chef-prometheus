#
# Cookbook Name::prometheus2-latam
# Library::Server
#

class Server
  attr_accessor :hostname, :ipaddress, :port

  def initialize(hostname, ipaddress, port)
    @hostname = hostname
    @ipaddress = ipaddress
    @port = port
  end

  def location
    "'#{@ipaddress}:#{@port}'"
  end

  def instance
    "'#{@hostname}'"
  end
end
