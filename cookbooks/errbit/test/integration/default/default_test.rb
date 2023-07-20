require 'json'

begin
  node_config = json("/tmp/node.json").params
rescue StandardError => e
  puts "Failed to load node configuration: #{e}"
  exit 1
end

errbit_host = json("/tmp/node.json")['default']['errbit']['config']['host']
errbit_port = json("/tmp/node.json")['default']['errbit']['config']['port']

control 'port-tests' do
  describe port(errbit_port) do
    it { should be_listening }
    its('processes') {should include 'ruby'}
  end

  describe port(27017) do
    it { should be_listening }
    its('processes') {should include 'mongod'}
  end
end

control 'service-tests' do
  describe systemd_service('mongod.service') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe systemd_service('errbit.service') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end

# if errbit_host.nil? || errbit_port.nil?
#   puts 'ERRBIT_HOST and/or ERRBIT_PORT not set.'
#   exit 1
# else
#   describe http("http://#{errbit_host}:#{errbit_port}") do
#     its('status') { should cmp 200 }
#   end
# end
