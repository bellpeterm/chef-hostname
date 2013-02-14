if node['net']
  fqdn     = node['net']['FQDN'] || ''
  hostname = node['net']['hostname']

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

  hosts_entry "127.0.0.1 #{hostname} #{fqdn}" do
    action :add
  end
end
