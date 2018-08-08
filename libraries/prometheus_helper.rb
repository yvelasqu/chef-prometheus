#
# Cookbook Name::prometheus2-latam
# Library::prometheus_helper
#
def generate_flags(params, prefix = '--')
  config = ''
  # Generate cli opts for prometheus 2.x & hopefully beyond if there are no changes
  unless params['cli_opts'].nil?
    params['cli_opts'].each do |opt_key, opt_value|
      config += "#{prefix}#{opt_key}=#{opt_value} " if opt_value != ''
    end
  end

  unless params['cli_flags'].nil?
    params['cli_flags'].each do |opt_flag|
      config += "#{prefix}#{opt_flag} " if opt_flag != ''
    end
  end
  config.strip
end
