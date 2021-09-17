require 'fy/codegen'
{
  master_registry
  Webcom_plugin
} = require 'webcom/lib/client_configurator'
fs = require 'fs'

plugin = new Webcom_plugin
plugin.name = 'fy'
master_registry.plugin_add plugin
do (plugin)->
  plugin.code_gen = ()->
    # TODO распилить на feature
    # Например нам не нужен обязательно такой пиздатый trim
    # $.cookie - требует jquery cookie, потому нужно это как-то поправить
    # там было слишком много регулярок, потому я вынес (дабы не заниматься идиотским экранированием)
    fs.readFileSync(require.resolve('./source/generic'), 'utf-8').replace('### !pragma coverage-skip-block ###\n', '')
# ###################################################################################################

plugin = new Webcom_plugin
plugin.name = 'event_mixin'
master_registry.plugin_add plugin
do (plugin)->
  plugin.code_gen = ()->
    fs.readFileSync(require.resolve('./source/event_mixin'), 'utf-8').replace('### !pragma coverage-skip-block ###\n', '')
# ###################################################################################################