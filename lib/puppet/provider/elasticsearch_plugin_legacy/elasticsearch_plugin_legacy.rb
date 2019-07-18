require 'puppet/provider/elastic_plugin_legacy'

Puppet::Type.type(:elasticsearch_plugin_legacy).provide(
  :elasticsearch_plugin_legacy,
  :parent => Puppet::Provider::ElasticPluginLegacy
) do
  desc <<-END
    Post-5.x provider for Elasticsearch bin/elasticsearch-plugin
    command operations.'
  END

  case Facter.value('osfamily')
  when 'OpenBSD'
    commands :plugin => '/usr/local/elasticsearch/bin/elasticsearch-plugin'
    commands :es => '/usr/local/elasticsearch/bin/elasticsearch'
    commands :javapathhelper => '/usr/local/bin/javaPathHelper'
  else
    commands :plugin => '/usr/share/elasticsearch/bin/elasticsearch-plugin'
    commands :es => '/usr/share/elasticsearch/bin/elasticsearch'
  end

end
