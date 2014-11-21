#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "httpd" do
  action :install
end

ruby_block "randomly_choose_language" do
  block do
    if Random.rand > 0.5
      node.run_state['scripting_language'] = 'php'
    else
      node.run_state['scripting_language'] = 'perl'
    end
  end
end

package 'scripting_language' do
  package_name lazy { node.run_state['scripting_language'] }
  action :install
end


service "httpd" do
  action [ :enable, :start ]
end

# Disable the default virtual host
execute "mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.disabled" do 
  only_if do
    File.exist?("/etc/httpd/conf.d/welcome.conf")
  end
  notifies :restart, "service[httpd]"
end

=begin
apache_vhost "lions" do
  site_port 8080
  action :create
  notifies :restart, "service[httpd]"
end

apache_vhost "lamp" do
  site_port 8089
  action :create
  notifies :restart, "service[httpd]"
end
=end

=begin
end
# Iterate over the apache sites
node["apache"]["sites"].each do |site_name, site_data|
# Set the document root
  document_root = "/srv/apache/#{site_name}"

# Add a template for Apache virtual host configuration
  template "/etc/httpd/conf.d/#{site_name}.conf" do
    source "custom.erb"
    mode "0644"
    variables(
      :document_root => document_root,
      :port => site_data["port"]
    )
    notifies :restart, "service[httpd]"
  end

# Add a directory resource to create the document_root
  directory document_root do
    mode "0755"
    recursive true
  end

# Add a template resource for the virtual host's index.html
  template "#{document_root}/index.html" do
    source "index.html.erb"
    mode "0644"
    variables(
      :site_name => site_name,
      :port => site_data["port"]
    )
  end
end
=end

apache_vhost "welcome" do
  action :remove
  notifies :restart, "service[httpd]"
end

search("apache_sites","*:*").each do |site|
  apache_vhost site[:id] do
    site_port site[:port]
    action :create
    notifies :restart, "service[httpd]"
  end
end

