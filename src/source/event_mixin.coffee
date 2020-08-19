### !pragma coverage-skip-block ###
window.event_mixin_constructor = (_t)->
  _t.$event_hash = {}
  _t.$event_once_hash = {}
  _t.on "delete", ()->
    for k,v of _t.$event_hash
      continue if k == "delete" # т.к. нормально не сотрет
      _t.$event_hash[k].clear()
    return
  return

window.event_mixin = (_t)->
  _t.prototype.$delete_state = false
  _t.prototype.$event_hash = {}
  _t.prototype.delete ?= ()->
    @dispatch "delete"
    return
  _t.prototype.once = (event_name, cb)->
    if event_name instanceof Array
      for v in event_name
        @once v, cb
      return @
    @on event_name, cb
    @$event_once_hash[event_name] ?= []
    @$event_once_hash[event_name].push cb
    @
  
  _t.prototype.ensure_on = (event_name, cb)->
    if event_name instanceof Array
      for v in event_name
        @ensure_on v, cb
      return @
    @$event_hash[event_name] ?= []
    if !@$event_hash[event_name].has cb
      @$event_hash[event_name].push cb
    @
  _t.prototype.on = (event_name, cb)->
    if event_name instanceof Array
      for v in event_name
        @on v, cb
      return @
    @$event_hash[event_name] ?= []
    @$event_hash[event_name].push cb
    @
  
  _t.prototype.off = (event_name, cb)->
    @$delete_state = true
    if event_name instanceof Array
      for v in event_name
        @off v, cb
      return
    list = @$event_hash[event_name]
    if !list
      puts "probably lose some important because no event_name '#{event_name}' found"
      e = new Error
      puts e.stack
      return
    # нельзя удалять т.к. можем поломать кому-то итерацию по циклу
    idx = list.idx cb
    if idx >= 0
      list[idx] = null
    # а тут можно
    @$event_once_hash[event_name]?.fast_remove cb
    return
  
  _t.prototype.dispatch = (event_name, hash={})->
    if @$event_hash[event_name]
      for cb in list = @$event_hash[event_name]
        continue if cb == null
        try
          cb.call @, hash
        catch e
          perr e
      if @$delete_state
        while 0 < idx = list.idx null
          list.remove_idx idx
        @$delete_state = false
      if @$event_once_hash[event_name]
        for remove_cb in @$event_once_hash[event_name]
          list.fast_remove remove_cb
        @$event_once_hash[event_name].clear()
    return

    
class window.Event_mixin
  event_mixin @

  constructor : ()->
    event_mixin_constructor @

window.event_manager = new window.Event_mixin()