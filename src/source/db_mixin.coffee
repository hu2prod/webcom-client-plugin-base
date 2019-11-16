### !pragma coverage-skip-block ###
# ###################################################################################################
#    experimental webnative broadcast extention
# ###################################################################################################
window.broadcast_register = (ws)->
  ws.__broadcast_factory_hash = {}
  ws.on 'data', (data)->
    return if data.switch != 'webnative_broadcast'
    return if !entity_blueprint = ws.__broadcast_factory_hash[data.collection]
    puts 'webnative_broadcast', data
    if val = entity_blueprint.ref_id_hash[data._id]
      if val._load_cb_list.length == 0
        if data.data?
          val.deserialize data.data
        else
          val.load()
    return
# ###################################################################################################
#    experimental db_mixin
# ###################################################################################################
react_deep_clone = (t)->
  return t if !t? or typeof t != 'object'
  if Array.isArray t
    res = []
    for v in t
      res.push react_deep_clone v
    return res
  
  res = {}
  for k,v of t
    unless k == '$undefined'
      continue if k[0] == '$' # react stuff
    continue if typeof v == 'function'
    res[k] = react_deep_clone v
  res
window.db_mixin = (athis, collection)->
  event_mixin athis
  collection ?= window.db.collection athis.name.toLowerCase()
  broadcast_factory_hash = collection.parent.wsrs.ws.__broadcast_factory_hash
  broadcast_factory_hash[collection.name] = athis
  athis.collection = collection
  athis.ref_id_hash = {}
  athis.factory = (_id)->
    ret = athis.ref_id_hash[_id]
    return ret if ret
    ret = new athis
    ret._id = _id
    ret
    
  
  athis.prototype._id = null
  athis.prototype._load_cb_list = []
  athis.prototype._save_cb_list = []
  athis.prototype._load_init = false
  athis.prototype._deserialize_last = null
  athis.prototype.version = 1
  
  athis.prototype.load = (on_end=->)->
    @_load_cb_list.push on_end
    return if @_load_cb_list.length > 1
    loop
      await collection.find {_id:@_id}, defer(err, list)
      if !res = list[0]
        err = new Error "missing id '#{@_id}'"
        break
      await @deserialize res, defer err; break if err
      break
    for cb in @_load_cb_list
      try
        cb(err)
      catch e
        perr e
    @_load_cb_list.clear()
    return
  
  athis.prototype.load_init = (on_end=->)->
    if @_load_init
      return on_end null
    @load on_end
    return
  
  athis.prototype.save = (on_end=->)->
    @_load_init = true # дабы мы потом не угробили свое состояние
    @_save_cb_list.push on_end
    return if @_save_cb_list.length > 1
    loop
      await @serialize defer(err, json)     ; break if err
      await collection.save json, defer(err, id_update); break if err
      @dispatch "save", @
      if _id = id_update?.insertedIds?[0]
        @_id = _id
      break
    for cb in @_save_cb_list
      try
        cb(err)
      catch e
        perr e
    @_save_cb_list.clear()
    return
  
  athis.prototype.serialize = (on_end)->
    ret = {}
    ret = {_id:@_id} if @_id # т.к. он будет пропущен условием пропуска _
    for k,v of @
      continue if k[0] == '_' # skip _dbmap, _load_cb_list, _save_cb_list
      continue if k[0] == '$' # $event_hash + react stuff
      continue if typeof v == 'function'
      if typeof v == 'object'
        continue unless v?.$undefined?
      ret[k] = v
    
    for k,dbmap_hint of @_dbmap or {}
      switch dbmap_hint.type
        when 'clone'
          ret[k] = react_deep_clone @[k]
        when 'ref', 'ref_force'
          if @[k]
            if !@[k]._id?
              await @[k].save defer err; return on_end err if err
            id = @[k]._id
          else
            id = @["_#{k}_oid"]
          set_k = k
          set_k += '_oid' if !/_oid$/.test set_k
          ret[k] = id
        when 'ref_list'
          ref_list = []
          for v in @[k]
            if !v._id?
              await v.save defer err; return on_end err if err
            ref_list.push v._id
          ret[k] = ref_list
      @[k]
    
    ret.last_edit_ts = Date.now()
    on_end null, ret
    return
  
  athis.prototype.deserialize = (json, on_end=->)->
    @_load_init = true
    if @_deserialize_last == null
      @_deserialize_last = {
        json
        handler_list : [on_end]
      }
    else
      @_deserialize_last.json = json
      @_deserialize_last.handler_list.push on_end # WARNING. Он получит не самые свежие данные, но ему скорее всего будет пофиг. Он же broadcast
    for k,v of json
      if dbmap_hint = @_dbmap[k]
        switch dbmap_hint.type
          when 'clone'
            @[k] = v
          when 'ref'
            @["_#{k}_oid"] = v
          when 'ref_force'
            @["_#{k}_oid"] = v
            await @load_ref k, defer err; return on_end err if err
          when 'ref_list'
            @[k] = v
      else
        continue if typeof @[k] == 'function' # prevent breaking self
        # TODO protect this
        # _load_cb_list
        # _save_cb_list
        # _load_init
        # _deserialize_last
        @[k] = v
    
    if @_deserialize_last.json == json
      _deserialize_last = @_deserialize_last
      @_deserialize_last = null
      for cb in _deserialize_last.handler_list
        try
          cb()
        catch e
          perr e
      @dispatch 'db_change'
    else
      on_end null
      call_later ()=>
        @deserialize @_deserialize_last.json
    return
  
  athis.prototype.load_ref = (field, on_end=->)->
    if !dbmap_hint = @_dbmap[field]
      perr "unknown field '#{field}'"
      return on_end new Error "unknown field '#{field}'"
    if !@["_#{field}_oid"]?
      perr "empty oid field '#{field}'"
      return on_end new Error "empty oid field '#{field}'"
    
    if !@[field]
      @[field] = proxy = dbmap_hint.factory(@["_#{field}_oid"])
    
    await proxy.load_init defer err; return on_end err if err
    on_end null
    return
  
  athis.prototype.clone = (on_end)->
    await @serialize defer(err, json); return on_end err if err
    ret = new athis
    await ret.deserialize json, defer(err); return on_end err if err
    ret.parent_oid = ret._id
    ret._id = null # т.к. иначе 2 instance на 1 сущность
    ret.version++
    on_end null, ret
    return
  
  return

window.db_mixin_constructor = (athis)->
  event_mixin_constructor athis
  athis._load_cb_list = []
  athis._save_cb_list = []
  @create_ts = Date.now()
  return
