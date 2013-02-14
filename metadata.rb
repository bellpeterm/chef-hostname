description 'Sets and persists a hostname, manages /etc/hosts'
%w{ ubuntu debian redhat centos gentoo}.each { |os| supports os }
