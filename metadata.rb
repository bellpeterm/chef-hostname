maintainer       'Vasily Mikhaylichenko'
maintainer_email 'vasily.mikhaylichenko+github@gmail.com'
license          'BSD'
description      'A Chef cookbook to set and persist node hostname'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'

%w{ ubuntu debian redhat centos gentoo}.each { |os| supports os }

depends 'hosts'
