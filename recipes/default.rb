ohai 'reload' do
  action :nothing
end

if node['net']
  fqdn         = node['net']['fqdn']
  the_hostname = node['net']['hostname']
  ip           = node['net']['ip']

  if node['hostname'] != the_hostname
    # Update the hostname
    case node['platform_family']
    when 'debian'
      file '/etc/hostname' do
        content "#{the_hostname}\n"
        mode '0644'
      end
    when 'rhel'
      ruby_block 'edit /etc/sysconfig/network' do
        block do
          rc = Chef::Util::FileEdit.new('/etc/sysconfig/network')
          rc.search_file_replace_line(/^HOSTNAME/, "HOSTNAME=#{the_hostname}")
          rc.write_file
        end
      end
    when 'gentoo'
      file '/etc/conf.d/hostname' do
        content "HOSTNAME=\"#{the_hostname}\"\n"
      end
    end

    hostsfile_entry '127.0.0.1' do
      hostname 'localhost'
      aliases ['localhost.localdomain']
    end

    execute "hostname #{the_hostname}" do
      notifies :reload, 'ohai[reload]'
    end
  end

  if fqdn && node['fqdn'] != fqdn
    # Update the FQDN
    case node['platform_family']
    when 'debian'
      hostsfile_entry ip do
        hostname fqdn
        aliases [ the_hostname ]
      end
      hostsfile_entry '127.0.1.1' do
        hostname fqdn
        aliases [ the_hostname ]
      end
    when 'rhel'
      hostsfile_entry ip do
        hostname fqdn
        aliases [ the_hostname ]
      end
    when 'gentoo'
      hostsfile_entry '127.0.0.1' do
        hostname fqdn
        aliases [ the_hostname, 'localhost.localdomain', 'localhost' ]
      end
    end

    execute "true" do
      notifies :reload, 'ohai[reload]'
    end
  end
end
