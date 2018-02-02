# == Class: elasticsearch-legacy::package::pin
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
#   class { 'elasticsearch-legacy::package::pin': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
# === Authors
#
# * Tyler Langlois <mailto:tyler@elastic.co>
#
class elasticsearch-legacy::package::pin {

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  case $::osfamily {
    'Debian': {
      include ::apt

      if ($elasticsearch-legacy::ensure == 'absent') {
        apt::pin { $elasticsearch-legacy::package_name:
          ensure => $elasticsearch-legacy::ensure,
        }
      } elsif ($elasticsearch-legacy::version != false) {
        apt::pin { $elasticsearch-legacy::package_name:
          ensure   => $elasticsearch-legacy::ensure,
          packages => $elasticsearch-legacy::package_name,
          version  => $elasticsearch-legacy::version,
          priority => 1000,
        }
      }

    }
    'RedHat', 'Linux': {

      if ($elasticsearch-legacy::ensure == 'absent') {
        $_versionlock = '/etc/yum/pluginconf.d/versionlock.list'
        $_lock_line = '0:elasticsearch-legacy-'
        exec { 'elasticsearch-legacy_purge_versionlock.list':
          command => "sed -i '/${_lock_line}/d' ${_versionlock}",
          onlyif  => [
            "test -f ${_versionlock}",
            "grep -F '${_lock_line}' ${_versionlock}",
          ],
        }
      } elsif ($elasticsearch-legacy::version != false) {
        yum::versionlock {
          "0:elasticsearch-legacy-${elasticsearch-legacy::pkg_version}.noarch":
            ensure => $elasticsearch-legacy::ensure,
        }
      }

    }
    default: {
      warning("Unable to pin package for OSfamily \"${::osfamily}\".")
    }
  }
}
