if node['net']
  fqdn     = node['net']['FQDN'] || ""
  hostname = node['net']['hostname']

  file '/etc/hostname' do
    content "#{hostname}\n"
    mode '0644'
  end

  if node['hostname'] != hostname
    execute "hostname #{hostname}"
  end

  hosts_entry "127.0.0.1 #{hostname} #{fqdn}" do
    action :add
  end
end
