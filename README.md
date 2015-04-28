Description
====

Installs OSSEC from source in a local installation. See:

http://www.ossec.net/doc/manual/installation/index.html

Requirements
====

Tested on Ubuntu and ArchLinux, but should work on any Unix/Linux platform supported by OSSEC. Installation by default is done from source, so the build-essential cookbook needs to be used (see below).

This cookbook doesn't configure Windows systems yet. For information on installing OSSEC on Windows, see the [free chapter](http://www.ossec.net/ossec-docs/OSSEC-book-ch2.pdf)

Cookbooks
----

build-essential is required for the default installation because it compiles from source. The cookbook may require modification to support other platforms' build tools - modify it accordingly before using.

Attributes
====

Default values are based on the defaults from OSSEC's own install.sh installation script.

* `node['ossec']['server_role']` - When using server/agent setup, this role is used to search for the OSSEC server, default `ossec_server`.
* `node['ossec']['server_env']` - When using server/agent setup, this value will scope the role search to the specified environment, default nil.
* `node['ossec']['checksum']` - SHA256 checksum of the source. Verified with SHA1 sum from OSSEC site.
* `node['ossec']['version']` - Version of OSSEC to download/install. Used in URL.
* `node['ossec']['url']` - URL to download the source.
* `node['ossec']['logs']` - Array of log files to analyze. Default is an empty array. These are in addition to the default logs in the ossec.conf.erb template.
* `node['ossec']['syscheck_freq']` - Frequency that syscheck is executed, default 22 hours (79200 seconds)
* `node['ossec']['data_bag']['encrypted']` - Boolean value which indicates whether or not the OSSEC data bag is encrypted
* `node['ossec']['data_bag']['name']` - The name of the data bag to use
* `node['ossec']['data_bag']['ssh']` - The name of the data bag item which contains the OSSEC keys
* `node['ossec']['server']['maxagents']` - Maximum number of agents, default setting is 256, but will be set to 1024 in the ossec::server recipe if used. Add as an override attribute in the `ossec_server` role if more nodes are required.
* `node['ossec']['disable_config_generation']` - Boolean that dictates whether this cookbook should drop the ossec.conf template or not. This is useful if you're using a wrapper cookbook and would like to generate your own template.

The `user` attributes are used to populate the config file (ossec.conf) and preload values for the installation script.

* `node['ossec']['user']['language']` - Language to use for installation, default en.
* `node['ossec']['user']['install_type']` - What kind of installation to perform, default is local. Using the client or server recipe will set this to `agent` or `server`, respectively.
* `node['ossec']['user']['dir']` - Installation directory for OSSEC, default `/var/ossec`.
* `node['ossec']['user']['delete_dir']` - Whether to delete the existing OSSEC installation directory, default true.
* `node['ossec']['user']['active_response']` - Whether to enable active response feature of OSSEC, default true. It is safe and recommended to leave this enabled.
* `node['ossec']['user']['syscheck']` - Whether to enable the integrity checking process, syscheck. Default true. It is safe and recommended to leave this enabled.
* `node['ossec']['user']['rootcheck']` - Whether to enable the rootkit checking process, rootcheck. Default true. It is safe and recommended to leave this enabled.
* `node['ossec']['user']['update']` - Whether an update installation should be done, default false.
* `node['ossec']['user']['update_rules']` - Whether to update rules files, default true.
* `node['ossec']['user']['binary_install']` - If true, use the binaries in the bin directory rather than compiling. Default false. The cookbook doesn't yet support binary installations.
* `node['ossec']['user']['agent_server_ip']` - The IP of the OSSEC server. The client recipe will attempt to determine this value via search. Default is nil, only required for agent installations.
* `node['ossec']['user']['enable_email']` - Enable or disable email alerting. Default is true.
* `node['ossec']['user']['email']` - Destination email address for OSSEC alerts. Default is `ossec@example.com` and should be changed via a role attribute.  Can take a string or an array of email addresses.
* `node['ossec']['user']['smtp']` - Sets the SMTP relay to send email out. Default is 127.0.0.1, which assumes that a local MTA is set up (e.g., postfix).
* `node['ossec']['user']['remote_syslog']` - Whether to enable the remote syslog server on the OSSEC server. Default false, not relevant for non-server.
* `node['ossec']['user']['syslog_output']['enabled]` - Whether to enable remote syslog output.  This allows forwarding events directly to a syslog server. Not applicable to 'agent' mode.
* `node['ossec']['user']['syslog_output']['server]` -  IP of syslog server. Default is `127.0.0.1`
* `node['ossec']['user']['syslog_output']['port]` -  Receiving port on syslog server. Default is `514`
* `node['ossec']['user']['syslog_output']['format]` -  Format of transmitted events. Default is `default`, or standard syslog.  See http://ossec-docs.readthedocs.org/en/latest/syntax/head_ossec_config.syslog_output.html
* `node['ossec']['user']['syslog_output']['level]` - Minimum OSSEC event level to forward. Default is `5`
* `node['ossec']['user']['syslog_output']['group]` - If specified, only forward group types in this array. Default is to forwards all groups. (e.g., `['syscheck', 'authentication_failure']`)
* `node['ossec']['user']['firewall_response']` - Enable or disable the firewall response which sets up firewall rules for blocking. Default is true.
* `node['ossec']['user']['pf']` - Enable PF firewall on BSD, default is false.
* `node['ossec']['user']['pf_table']` - The PF table to use on BSD. Default is false, set this to the desired table if enabling `pf`.
* `node['ossec']['user']['white_list']` - Array of additional IP addresses to white list. Default is empty.
* `node['ossec']['syscheck']['ignore']` - Array of files or directories for `syscheck` to ignore.

Recipes
====

default
----

The default recipe downloads and installs the OSSEC source and makes sure the configuration file is in place and the service is started. Use only this recipe if setting up local-only installation. The server and client recipes (below) will set their installation type and include this recipe.

purge
----

Removes OSSEC altogether

Usage
====

The cookbook can be used to install OSSEC in one way only:

* local - use the ossec::default recipe.

For local-only installations, add just `recipe[ossec]` to the node run list, or put it in a role (like a base role).

Customization
----

The main configuration file is maintained by Chef as a template, `ossec.conf.erb`. It should just work on most installations, but can be customized for the local environment. Notably, the rules, ignores and commands may be modified.

Further reading:

* [OSSEC Documentation](http://www.ossec.net/doc/index.html)

License and Author
====

Copyright 2010, Opscode, Inc (<legal@opscode.com>)
Copyright 2015, Datadog, Inc (<package@opscode.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
