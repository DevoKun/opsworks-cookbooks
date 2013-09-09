require 'uri'
require 'net/http'
require 'net/https'

uri              = URI.parse("https://api.wordpress.org/secret-key/1.1/salt/")
http             = Net::HTTP.new(uri.host, uri.port)
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request          = Net::HTTP::Get.new(uri.request_uri)
response         = http.request(request)
keys             = response.body

node[:deploy].each do |app_name, deploy|

  template "#{deploy[:deploy_to]}/current/wp-config.php" do
    source "wp-config.php.erb"
    mode 0660
    group deploy[:group]

    case node[:platform]
      when "centos","redhat","fedora","suse"
        owner "apache"
      when "debian","ubuntu"
        owner "www-data"
    end ### case node

    action :install

    variables(
      :database   => (deploy[:database][:database] rescue nil),
      :user       => (deploy[:database][:username] rescue nil),
      :password   => (deploy[:database][:password] rescue nil),
      :host       => (deploy[:database][:host] rescue nil),
      :keys       => (keys rescue nil)
      )

  end #### template do

end #### node[:deploy].each


