## Usage


To set and persist a hostname, set `node['net']['hostname']` and, optionally, `node['net']['FQDN']` attributes and include `recipe[hostname]` in your run_list.

## Requirements

### Platform

The following platforms are supported by the cookbook:

* ubuntu
* debian
* centos
* redhat
* gentoo

### Cookbooks

This cookbook depends on the following external cookbooks:

* [hosts](https://github.com/lxmx-cookbooks/hosts)

## Recipes

### default

Sets and persists node hostname using different approaches on different platforms.

## Attributes

* `node['net']['hostname']` - node hostname to set and persist.

* `node['net']['FQDN']` - an optional additional entry for `/etc/hosts`.

## License

Copyright:: Vasily Mikhaylichenko.

Licensed under BSD license.

    http://opensource.org/licenses/BSD-2-Clause


