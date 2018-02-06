# == Class: elasticsearch_legacy::package::pin
#
# Controls package pinning for the Elasticsearch package.
#
# === Parameters
#
# This class does not provide any parameters.
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'elasticsearch_legacy::package::pin': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
# === Authors
#
# * Tyler Langlois <mailto:tyler@elastic.co>
#
class elasticsearch_legacy::package::pin {

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  case $::osfamily {
    'Debian': {
      include ::apt

      if ($elasticsearch_legacy::ensure == 'absent') {
        apt::pin { $elasticsearch_legacy::package_name:
          ensure => $elasticsearch_legacy::ensure,
        }
      } elsif ($elasticsearch_legacy::version != false) {
        apt::pin { $elasticsearch_legacy::package_name:
          ensure   => $elasticsearch_legacy::ensure,
          packages => $elasticsearch_legacy::package_name,
          version  => $elasticsearch_legacy::version,
          priority => 1000,
        }
      }

    }
    'RedHat', 'Linux': {

      if ($elasticsearch_legacy::ensure == 'absent') {
        $_versionlock = '/etc/yum/pluginconf.d/versionlock.list'
        $_lock_line = '0:elasticsearch_legacy-'
        exec { 'elasticsearch_legacy_purge_versionlock.list':
          command => "sed -i '/${_lock_line}/d' ${_versionlock}",
          onlyif  => [
            "test -f ${_versionlock}",
            "grep -F '${_lock_line}' ${_versionlock}",
          ],
        }
      } elsif ($elasticsearch_legacy::version != false) {
        yum::versionlock {
          "0:elasticsearch_legacy-${elasticsearch_legacy::pkg_version}.noarch":
            ensure => $elasticsearch_legacy::ensure,
        }
      }

    }
    default: {
      warning("Unable to pin package for OSfamily \"${::osfamily}\".")
    }
  }
}
