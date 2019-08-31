require 'fy/codegen'
{
  master_registry
  Webcom_plugin
} = require 'webcom-server-delivery/lib/client_configurator'
require './fy'
fs = require 'fs'
com_preprocess = require 'webcom-server-delivery/lib/com_preprocess'

plugin = new Webcom_plugin
plugin.name = 'Webcom react'
plugin.dependency_list.push 'fy'
master_registry.plugin_add plugin
do (plugin)->
  plugin.code_gen = ()->
    com_preprocess.react_runtime()
