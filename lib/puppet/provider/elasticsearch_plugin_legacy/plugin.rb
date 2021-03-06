require 'puppet/provider/elastic_plugin_legacy'

Puppet::Type.type(:elasticsearch_plugin_legacy).provide(
  :plugin,
  :parent => Puppet::Provider::ElasticPluginLegacy
) do
  desc 'Pre-5.x provider for Elasticsearch bin/plugin command operations.'

  case Facter.value('osfamily')
  when 'OpenBSD'
    commands :plugin => '/usr/local/elasticsearch/bin/plugin'
    commands :es => '/usr/local/elasticsearch/bin/elasticsearch'
    commands :javapathhelper => '/usr/local/bin/javaPathHelper'
  else
    commands :plugin => '/usr/share/elasticsearch/bin/plugin'
    commands :es => '/usr/share/elasticsearch/bin/elasticsearch'
  end

end
