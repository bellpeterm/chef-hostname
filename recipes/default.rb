ohai 'reload' do
  action :nothing
end

if node['net']
  fqdn         = node['net']['FQDN']
  the_hostname = node['net']['hostname']
  ip           = node['net']['IP']

  # Update the hostname
  case node['platform']
  when 'ubuntu', 'debian'
    file '/etc/hostname' do
      content "#{fqdn}\n"
      mode '0644'
      not_if { open('/etc/sysconfig/network') { |f| f.grep(/string/) } }
    end
  when 'redhat', 'centos'
    ruby_block 'edit /etc/sysconfig/network' do
      block do
        rc = Chef::Util::FileEdit.new('/etc/sysconfig/network')
        rc.search_file_replace_line(/^HOSTNAME/, "HOSTNAME=#{fqdn}")
        rc.write_file
      end
      not_if { open('/etc/sysconfig/network') { |f| f.grep(/string/) } }
    end
  when 'gentoo'
    file '/etc/conf.d/hostname' do
      content "HOSTNAME=\"#{the_hostname}\"\n"
      not_if { open('/etc/conf.d/hostname') { |f| f.grep(/string/) } }
    end
  end

  hostsfile_entry '127.0.0.1' do
    hostname the_hostname
    aliases ['localhost', 'localhost.localdomain']
  end

  execute "hostname #{fqdn}" do
    notifies :reload, 'ohai[reload]', :immediately
    not_if { node['fqdn'] == fqdn }
  end

  case node['platform']
  when 'ubuntu', 'debian'
    hostsfile_entry '127.0.1.1' do
      hostname fqdn
      aliases [ the_hostname ]
      notifies :reload, 'ohai[reload]', :immediately
    end
  when 'redhat', 'centos'
    hostsfile_entry ip do
      hostname fqdn
      aliases [ the_hostname ]
      notifies :reload, 'ohai[reload]', :immediately
    end
  when 'gentoo'
    hostsfile_entry '127.0.0.1' do
      hostname fqdn
      aliases [ the_hostname, 'localhost.localdomain', 'localhost' ]
      notifies :reload, 'ohai[reload]', :immediately
    end
  end
end
