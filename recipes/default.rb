ohai 'reload' do
  action :nothing
end

puts node['net']

if node['net']

  hostsfile_entry '127.0.0.1' do
    hostname 'localhost'
    aliases ['localhost.localdomain']
  end

  # Update the hostname
  case node['platform_family']
  when 'debian'
    file '/etc/hostname' do
      content "#{node['net']['FQDN']}\n"
      mode '0644'
      not_if { open('/etc/sysconfig/network') { |f| f.grep(/string/) } }
    end

    hostsfile_entry '127.0.1.1' do
      hostname node['net']['FQDN']
      aliases [ node['net']['hostname'] ]
      notifies :reload, 'ohai[reload]', :immediately
    end
  when 'rhel'
    ruby_block 'edit /etc/sysconfig/network' do
      block do
        rc = Chef::Util::FileEdit.new('/etc/sysconfig/network')
        rc.search_file_replace_line(/^HOSTNAME/, "HOSTNAME=#{node['net']['FQDN']}")
        rc.write_file
      end
      not_if { open('/etc/sysconfig/network') { |f| f.grep(/string/) } }
    end

    hostsfile_entry node['net']['IP'] do
      hostname node['net']['FQDN']
      aliases [ node['net']['hostname'] ]
      notifies :reload, 'ohai[reload]', :immediately
    end
  when 'gentoo'
    file '/etc/conf.d/hostname' do
      content "HOSTNAME=\"#{node['net']['hostname']}\"\n"
      not_if { open('/etc/conf.d/hostname') { |f| f.grep(/string/) } }
    end

    hostsfile_entry '127.0.0.1' do
      hostname node['net']['FQDN']
      aliases [ node['net']['hostname'], 'localhost.localdomain', 'localhost' ]
      notifies :reload, 'ohai[reload]', :immediately
    end
  end

  execute "hostname #{node['net']['FQDN']}" do
    notifies :reload, 'ohai[reload]', :immediately
    not_if { node['fqdn'] == node['net']['FQDN'] }
  end

end
