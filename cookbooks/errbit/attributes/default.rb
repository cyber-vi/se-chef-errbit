default['errbit'].tap do |errbit|
    errbit['mongodb_version'] = "4.4"
    errbit['ruby_version'] = "2.7.6"
    errbit['git_repo'] = 'https://github.com/errbit/errbit.git'
    errbit['git_revision'] = 'main'
    
    errbit['config'].tap do |config|
      config['host'] = node['errbit_host'] || "errbit.example.com"
      config['port'] = node['errbit_port'] || "80"
    end

    errbit['test'].tap do |test|
      test['host'] = node['errbit_host'] || "localhost"
      test['port'] = node['errbit_port'] || "3000"
    end
end
