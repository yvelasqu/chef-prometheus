#
# Cookbook Name::prometheus2-latam
# Library::ServerGroup
#
class ServerGroup
  attr_accessor :type, :servers

  def initialize(type, servers)
    @type = type
    @servers = servers
  end

  def exclude(exclude)
    @servers.select! { |host| host.ipaddress != exclude }
    @servers
  end
end
