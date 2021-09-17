require 'fy/codegen'
{
  master_registry
  Webcom_plugin
} = require 'webcom/lib/client_configurator'
fs = require 'fs'

plugin = new Webcom_plugin
plugin.name = 'ws request service'
master_registry.plugin_add plugin
do (plugin)->
  plugin.code_gen = ()->
    fs.readFileSync(require.resolve('./source/ws_request_service'), 'utf-8').replace('### !pragma coverage-skip-block ###\n', '')
# ###################################################################################################
