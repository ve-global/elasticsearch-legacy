# == Define: elasticsearch::script
#
#  This define allows you to insert, update or delete scripts that are used within Elasticsearch
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed software packages are being uninstalled.
#   * Any traces of the packages will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*source*]
#   Puppet source of the script
#   Value type is string
#   Default value: undef
#   This variable is mandatory
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
define elasticsearch_legacy::script(
  $source,
  $ensure  = 'present',
) {

  require elasticsearch_legacy

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  validate_re($source, '^(puppet|file)://')

  $filename_array = split($source, '/')
  $basefilename = $filename_array[-1]

  file { "${elasticsearch_legacy::params::homedir}/scripts/${basefilename}":
    ensure => $ensure,
    source => $source,
    owner  => $elasticsearch_legacy::elasticsearch_legacy_user,
    group  => $elasticsearch_legacy::elasticsearch_legacy_group,
    mode   => '0644',
  }
}
