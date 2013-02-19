if node['net']
  fqdn     = node['net']['FQDN'] || ''
  hostname = node['net']['hostname']
  ip = node['net']['IP']

  if node['hostname'] != hostname
    case node['platform']
    when 'ubuntu', 'debian'
      file '/etc/hostname' do
        content "#{hostname}\n"
        mode '0644'
      end
    when 'redhat', 'centos'
      ruby_block 'edit /etc/sysconfig/network' do
        block do
          rc = Chef::Util::FileEdit.new('/etc/sysconfig/network')
          rc.search_file_replace_line(/^HOSTNAME/, "HOSTNAME=#{hostname}")
          rc.write_file
        end
      end
    when 'gentoo'
      file '/etc/conf.d/hostname' do
        content "HOSTNAME=\"#{hostname}\"\n"
      end
    end

    execute "hostname #{hostname}" do
      notifies :reload, 'ohai[reload]'
    end

    ohai 'reload' do
      action :nothing
    end
  end

  host_entries = case node['platform']
  when 'ubuntu', 'debian'
    [
      "127.0.0.1 localhost localhost.localdomain",
      "127.0.1.1 #{fqdn} #{hostname}"
    ]
  when 'redhat', 'centos'
    [
      "127.0.0.1 localhost",
      "#{ip} #{fqdn} #{hostname}"
    ]
  when 'gentoo'
    [
      "127.0.0.1 #{fqdn} #{hostname} localhost.localdomain localhost"
    ]
  end

  host_entries.each do |host_entry|
    hosts_entry host_entry
  end
end
