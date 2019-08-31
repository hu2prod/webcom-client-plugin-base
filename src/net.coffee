require 'fy/codegen'
{
  master_registry
  Webcom_plugin
} = require 'webcom/lib/client_configurator'
require './fy'
fs = require 'fs'

plugin = new Webcom_plugin
plugin.name = 'Webcom net'
plugin.dependency_list.push 'fy'
plugin.dependency_list.push 'event_mixin'
master_registry.plugin_add plugin
do (plugin)->
  plugin.code_gen = ()->
    # там было слишком много регулярок, потому я вынес (дабы не заниматься идиотским экранированием)
    fs.readFileSync(require.resolve('./source/websocket.coffee'), 'utf-8').replace('### !pragma coverage-skip-block ###\n', '')
# ###################################################################################################