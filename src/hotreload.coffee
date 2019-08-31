require 'fy/codegen'
{
  master_registry
  Webcom_plugin
} = require 'webcom-server-delivery/lib/client_configurator'
require './net'
require './fy'
fs = require 'fs'

# ###################################################################################################
plugin = new Webcom_plugin
plugin.name = 'Webcom hotreload'
plugin.dependency_list.push 'Webcom net'
plugin.dependency_list.push 'fy'
master_registry.plugin_add plugin
do (plugin)->
  plugin.code_gen = ()->
    fs.readFileSync(require.resolve('./source/hot_reload.coffee'), 'utf-8').replace('### !pragma coverage-skip-block ###\n', '')
# ###################################################################################################