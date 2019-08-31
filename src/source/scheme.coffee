### !pragma coverage-skip-block ###
# TODO keyboard code mapping
# TODO keyboard scheme
# TODO keyboard scheme with modes
class window.Keyboard_scheme
  code_map : {}
  constructor : ()->
    @code_map = {}
  
  register : (hotkey, handler, opt={})->
    event_list = window.Keymap.parse hotkey
    for event in event_list
      event.prevent_default = opt.prevent_default if opt.prevent_default?
      event.description     = opt.description     if opt.description?
      event.handler = handler
      @code_map[event.code] ?= []
      @code_map[event.code].push event
    return
  
  # COPYPASTE for performance
  keypressed : (event)->
    if list = @code_map[event.keyCode]
      for v in list
        continue if !v.opt_ctrl  and v.ctrl  != event.ctrlKey
        continue if !v.opt_shift and v.shift != event.shiftKey
        continue if !v.opt_alt   and v.alt   != event.altKey
        return v.handler(event)
    return
  
class window.Keyboard_switchable_scheme
  mode : 'default'
  mode_to_scheme: {}
  active_scheme : null
  constructor   : ()->
    @mode_to_scheme =
      default : new window.Keyboard_scheme
    @scheme_select 'default'
  
  scheme_select : (name)->
    new_scheme = @mode_to_scheme[name]
    if !new_scheme
      perr "unknown scheme '#{name}'"
      return
    @active_scheme = new_scheme
    return
  
  # COPYPASTE for performance
  keypressed : (event)->
    if list = @active_scheme.code_map[event.keyCode]
      for v in list
        continue if !v.opt_ctrl  and v.ctrl  != event.ctrlKey
        continue if !v.opt_shift and v.shift != event.shiftKey
        continue if !v.opt_alt   and v.alt   != event.altKey
        return v.handler(event)
    return
  