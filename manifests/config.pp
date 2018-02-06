# == Class: elasticsearch::config
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'elasticsearch::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class elasticsearch_legacy::config {

  #### Configuration

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  if ( $elasticsearch_legacy::ensure == 'present' ) {

    file {
      $elasticsearch_legacy::configdir:
        ensure => 'directory',
        group  => $elasticsearch_legacy::elasticsearch_legacy_group,
        owner  => $elasticsearch_legacy::elasticsearch_legacy_user,
        mode   => '0644';
      $elasticsearch_legacy::datadir:
        ensure => 'directory',
        group  => $elasticsearch_legacy::elasticsearch_legacy_group,
        owner  => $elasticsearch_legacy::elasticsearch_legacy_user;
      $elasticsearch_legacy::logdir:
        ensure  => 'directory',
        group   => undef,
        owner   => $elasticsearch_legacy::elasticsearch_legacy_user,
        mode    => '0644',
        recurse => true;
      $elasticsearch_legacy::plugindir:
        ensure => 'directory',
        group  => $elasticsearch_legacy::elasticsearch_legacy_group,
        owner  => $elasticsearch_legacy::elasticsearch_legacy_user,
        mode   => 'o+Xr';
      "${elasticsearch_legacy::homedir}/lib":
        ensure  => 'directory',
        group   => $elasticsearch_legacy::elasticsearch_legacy_group,
        owner   => $elasticsearch_legacy::elasticsearch_legacy_user,
        recurse => true;
      $elasticsearch_legacy::params::homedir:
        ensure => 'directory',
        group  => $elasticsearch_legacy::elasticsearch_legacy_group,
        owner  => $elasticsearch_legacy::elasticsearch_legacy_user;
      "${elasticsearch_legacy::params::homedir}/templates_import":
        ensure => 'directory',
        group  => $elasticsearch_legacy::elasticsearch_legacy_group,
        owner  => $elasticsearch_legacy::elasticsearch_legacy_user,
        mode   => '0644';
      "${elasticsearch_legacy::params::homedir}/scripts":
        ensure => 'directory',
        group  => $elasticsearch_legacy::elasticsearch_legacy_group,
        owner  => $elasticsearch_legacy::elasticsearch_legacy_user,
        mode   => '0644';
      "${elasticsearch_legacy::params::homedir}/shield":
        ensure => 'directory',
        mode   => '0644',
        group  => '0',
        owner  => 'root';
      '/etc/elasticsearch/elasticsearch.yml':
        ensure => 'absent';
      '/etc/elasticsearch/logging.yml':
        ensure => 'absent';
      '/etc/elasticsearch/log4j2.properties':
        ensure => 'absent';
      '/etc/init.d/elasticsearch':
        ensure => 'absent';
    }

    if $elasticsearch_legacy::params::pid_dir {
      file { $elasticsearch_legacy::params::pid_dir:
        ensure  => 'directory',
        group   => undef,
        owner   => $elasticsearch_legacy::elasticsearch_legacy_user,
        recurse => true,
      }

      if ($elasticsearch_legacy::service_providers == 'systemd') {
        $group = $elasticsearch_legacy::elasticsearch_legacy_group
        $user = $elasticsearch_legacy::elasticsearch_legacy_user
        $pid_dir = $elasticsearch_legacy::params::pid_dir

        file { '/usr/lib/tmpfiles.d/elasticsearch.conf':
          ensure  => 'file',
          content => template("${module_name}/usr/lib/tmpfiles.d/elasticsearch.conf.erb"),
          group   => '0',
          owner   => 'root',
        }
      }
    }

    if ($elasticsearch_legacy::service_providers == 'systemd') {
      # Mask default unit (from package)
      exec { 'systemctl mask elasticsearch.service':
        unless => 'test `systemctl is-enabled elasticsearch.service` = masked',
      }
    }

    $new_init_defaults = { 'CONF_DIR' => $elasticsearch_legacy::configdir }
    if $elasticsearch_legacy::params::defaults_location {
      augeas { "${elasticsearch_legacy::params::defaults_location}/elasticsearch":
        incl    => "${elasticsearch_legacy::params::defaults_location}/elasticsearch",
        lens    => 'Shellvars.lns',
        changes => template("${module_name}/etc/sysconfig/defaults.erb"),
      }
    }

    $jvm_options = $elasticsearch_legacy::jvm_options
    file { "${elasticsearch_legacy::configdir}/jvm.options":
      content => template("${module_name}/etc/elasticsearch/jvm.options.erb"),
      owner   => $elasticsearch_legacy::elasticsearch_user,
      group   => $elasticsearch_legacy::elasticsearch_group,
    }

  } elsif ( $elasticsearch_legacy::ensure == 'absent' ) {

    file { $elasticsearch_legacy::plugindir:
      ensure => 'absent',
      force  => true,
      backup => false,
    }

  }

}
