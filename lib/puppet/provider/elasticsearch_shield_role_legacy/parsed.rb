require 'puppet/provider/elastic_yaml_legacy'

case Facter.value('osfamily')
when 'OpenBSD'
  roles = '/usr/local/elasticsearch/shield/roles.yml'
else
  roles = '/usr/share/elasticsearch/shield/roles.yml'
end

Puppet::Type.type(:elasticsearch_shield_role_legacy).provide(
  :parsed,
  :parent => Puppet::Provider::ElasticYaml,
  :default_target => roles,
  :metadata => :privileges
) do
  desc "Provider for Shield role resources."
end
