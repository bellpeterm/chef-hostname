ohai 'reload' do
  action :nothing
end

if node['net']
  require 'resolv'

  fqdn         = node['net']['FQDN']
  the_hostname = node['net']['hostname']
  ip           = node['net']['IP']

  if node['hostname'] != the_hostname || node['fqdn'] != fqdn
    # Update the hostname
    case node['platform']
    when 'ubuntu', 'debian'
      file '/etc/hostname' do
        content "#{fqdn}\n"
        mode '0644'
      end
    when 'redhat', 'centos'
      ruby_block 'edit /etc/sysconfig/network' do
        block do
          rc = Chef::Util::FileEdit.new('/etc/sysconfig/network')
          rc.search_file_replace_line(/^HOSTNAME/, "HOSTNAME=#{fqdn}")
          rc.write_file
        end
      end
    when 'gentoo'
      file '/etc/conf.d/hostname' do
        content "HOSTNAME=\"#{the_hostname}\"\n"
      end
    end

    hostsfile_entry '127.0.0.1' do
      hostname the_hostname
      aliases ['localhost', 'localhost.localdomain']
    end

    execute "hostname #{fqdn}" do
      notifies :reload, 'ohai[reload]', :immediately
    end
  end

  resolver = Resolv::DNS.new

  case node['platform']
  when 'ubuntu', 'debian'
    hostsfile_entry '127.0.1.1' do
      hostname fqdn
      aliases [ the_hostname ]
      not_if { resolver.getaddress(fqdn).to_s.match(/127\.0/) }
      notifies :reload, 'ohai[reload]', :immediately
    end
  when 'redhat', 'centos'
    hostsfile_entry ip do
      hostname fqdn
      aliases [ the_hostname ]
      not_if { resolver.getaddress(fqdn).to_s.match(ip) }
      notifies :reload, 'ohai[reload]', :immediately
    end
  when 'gentoo'
    hostsfile_entry '127.0.0.1' do
      hostname fqdn
      aliases [ the_hostname, 'localhost.localdomain', 'localhost' ]
      not_if { resolver.getaddress(fqdn).to_s.match(/127\.0/) }
      notifies :reload, 'ohai[reload]', :immediately
    end
  end
end
