### !pragma coverage-skip-block ###
window.event_mixin_constructor = (_t)->
  _t.$event_hash = {}
  _t.on "delete", ()->
    for k,v of _t.$event_hash
      continue if k == "delete" # т.к. нормально не сотрет
      _t.$event_hash[k].clear()
    return
window.event_mixin = (_t)->
  _t.prototype.$delete_state = false
  _t.prototype.$event_hash = {}
  _t.prototype.delete ?= ()->
    @dispatch "delete"
    return
  _t.prototype.once = (event_name, cb)->
    need_remove = ()=>
      @off event_name, need_remove
      cb()
      return
    @on event_name, need_remove
    return
  
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
  # remove нельзя, а вдруг определен
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
    idx = list.idx cb
    if idx >= 0
      list[idx] = null
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
    return

    
class window.Event_mixin
  event_mixin @

  constructor : ()->
    event_mixin_constructor @

window.event_manager = new window.Event_mixin()