#
# Cookbook Name:: at_mail
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

def install(pkg)
  package pkg do
    action :install
  end
end

# update repository
bash 'apt-get_update' do
  user 'root'
  code 'apt-get update'
end

# vim, screen
%w[git vim screen nkf fish].each do |pkg|
  install pkg
end

%w[screenrc vimrc gitconfig].each do |rc|
  template rc do
    owner 'vagrant'
    group 'vagrant'
    mode  0644
    path  "/home/vagrant/.#{rc}"
  end
end

# fish
#bash 'fish' do
#  cwd '/etc/yum.repos.d/'
#  user 'root'
#  code <<-EOF
#    wget http://download.opensuse.org/repositories/shells:fish:release:2/CentOS_6/shells:fish:release:2.repo
#  EOF
#  not_if 'which fish'
#  notifies :install, 'package[fish]', :immediately
#end
#
#package 'fish' do
#  action :nothing
#end

# apache
install 'apache2'

service 'apache2' do
  action [ :enable, :start ]
end

# Virtualhost の設定をする
template 'virtualhost.conf' do
  path     '/etc/apache2/sites-available/develop-env.conf'
  owner    'root'
  notifies :run, 'execute[a2ensite_develop-env]'
end

execute 'a2ensite_develop-env' do
  action :nothing
  user     'root'
  command  'a2ensite develop-env'
  notifies :restart, 'service[apache2]'
end

# apache module の適用
execute 'a2enmod' do
  user     'root'
  command  'a2enmod rewrite'
  notifies :restart, 'service[apache2]'
end

# iptables
service 'iptables' do
  action [:disable, :stop]
end

#bash 'DEBIAN_FRONTEND=noninteractive' do
#  user 'root'
#  code 'DEBIAN_FRONTEND=noninteractive'
#  notifies :install 'package[mysql-server-5.6]'
#end
#
## mysql
#package 'mysql-server-5.6' do
#  action :noting
#end
#%w[mysql-server-5.6].each do |pkg|
#  install pkg
#end

#service 'mysqld' do
#  action [ :enable, :start ]
#end

#bash 'mysql-create-user' do
#  code <<-EOF
#    mysql -uroot -e "CREATE DATABASE IF NOT EXISTS `#{node['mysql']['database']}` DEFAULT CHARACTER SET utf8;
#    mysql -uroot -e "GRANT ALL PRIVILEGES ON #{node['mysql']['database']}.* TO #{node['mysql']['user']}@localhost IDENTIFIED BY '#{node['mysql']['password']}';
#  EOF
#end

# php
#%w[php php-mbstring php-mysql php-pdo php-pear].each do |pkg|
%w[php5].each do |pkg|
  install pkg
end

# php.iniの設定
#template 'php.ini' do
#  path     '/etc/php.ini'
#  owner    'root'
#  notifies :restart, 'service[httpd]'
#end
#
## error_log の設置
#directory File.dirname(node['php']['error_log']) do
#  user     'root'
#  group    'root'
#  mode      0755
#  recursive true
#  action    :create
#end
#
#file node['php']['error_log'] do
#  owner  'root'
#  group  'root'
#  mode    0666
#  action  :create
#end

# deploy
directory '/home/vagrant' do
  mode 0705
  action :create
end

#directory '/home/vagrant/xxneorg' do
#  mode 0755
#  action :create
#end
#
#link '/home/vagrant/xxneorg/app' do
#  to '/home/vagrant/xxneorg/httpdocs/scripts/app'
#  link_type :symbolic
#  owner 'vagrant'
#  action :create
#  not_if 'test -L /home/vagrant/xxneorg/httpdocs/scripts/app'
#end

