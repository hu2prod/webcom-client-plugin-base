require 'fy/codegen'
{
  master_registry
  Webcom_plugin
} = require 'webcom/lib/client_configurator'
fs = require 'fs'
require './wsrs'

plugin = new Webcom_plugin
plugin.dependency_list.push 'ws request service'
plugin.name = 'webnative'
master_registry.plugin_add plugin
do (plugin)->
  plugin.code_gen = ()->
    fs.readFileSync(require.resolve('./source/webnative'), 'utf-8').replace('### !pragma coverage-skip-block ###\n', '')
# ###################################################################################################


plugin = new Webcom_plugin
plugin.dependency_list.push 'ws request service'
plugin.name = 'webnative durable'
master_registry.plugin_add plugin
do (plugin)->
  plugin.code_gen = ()->
    fs.readFileSync(require.resolve('./source/webnative_durable'), 'utf-8').replace('### !pragma coverage-skip-block ###\n', '')
# ###################################################################################################

plugin = new Webcom_plugin
plugin.name = 'db_mixin'
master_registry.plugin_add plugin
do (plugin)->
  plugin.code_gen = ()->
    fs.readFileSync(require.resolve('./source/db_mixin'), 'utf-8').replace('### !pragma coverage-skip-block ###\n', '')
# ###################################################################################################