apt_repository 'mongodb' do
  distribution "#{node['lsb']['codename']}/mongodb-org/#{node['errbit']['mongodb_version']}"
  uri 'http://repo.mongodb.org/apt/' + node[:platform]
  components value_for_platform('ubuntu' => {'default' => ['multiverse']},'debian' => {'default' => ['main']})
  arch value_for_platform('ubuntu' => {'default' => 'amd64'})
  key "https://www.mongodb.org/static/pgp/server-#{node['errbit']['mongodb_version']}.asc"
end

apt_update do
  action :update
end

package [ 'mongodb-org', 'git']

git '/app' do
  repository node['errbit']['git_repo']
  revision node['errbit']['git_revision']
  action :sync
  notifies :run, 'bash[Install ruby and bundler]', :immediately
  notifies :run, 'bash[Build app]', :immediately
end

template "/app/.env" do
  source ".env.erb"
  variables(
    port: node['errbit']['config']['port'],
    host: node['errbit']['config']['host']
  )
  notifies :restart, 'systemd_unit[errbit.service]', :delayed
end

bash 'Install ruby and bundler' do
  code <<-EOH
  curl -sSL https://get.rvm.io | bash \
  && usermod -a -G rvm root \
  && source /etc/profile.d/rvm.sh \
  && rvm install #{node['errbit']['ruby_version']} \
  && rvm --default use #{node['errbit']['ruby_version']} \
  && echo "gem: --no-document" >> /etc/gemrc \
  && gem update --system "3.3.21" \
  && gem install bundler --version "2.3.21" \
  && bundle config --global frozen 1 \
  && bundle config --global disable_shared_gems false
  EOH
end

bash 'Build app' do
  code <<-EOH
  bundle install -j "$(getconf _NPROCESSORS_ONLN)" --retry 5 \
  && bundle clean --force \
  && RAILS_ENV=production bundle exec rake assets:precompile \
  && rm -rf /app/tmp/* \
  && chmod 777 /app/tmp
  EOH
  cwd "/app"
  flags "-l"
end

systemd_unit 'mongod.service' do
  action [:enable, :restart]
end

systemd_unit 'errbit.service' do
  content <<~EOU
  [Unit]
  Description=Errbit
  After=network.target

  [Service]
  WorkingDirectory=/app
  Environment=HOME=/app
  ExecStart=/bin/bash -l -c "PORT=#{node['errbit']['config']['port']} bundle exec puma -C config/puma.default.rb"
  Restart=always

  [Install]
  WantedBy=multi-user.target
  EOU
  action [:create, :enable, :restart]
end

ruby_block "Save node attributes" do
  block do
    File.write("/tmp/node.json", node.to_json)
  end
end
