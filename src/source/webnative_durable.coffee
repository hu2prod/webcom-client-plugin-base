### !pragma coverage-skip-block ###
class Pending_cache_request
  is_complete : false
  wait_list   : []
  err         : null
  data        : null
  creation_time : 0
  constructor : ()->
    @wait_list = []
    @creation_time = Date.now()
  
  setter :  (cb)->
    if !@is_complete
      @wait_list.push cb if cb?
    else
      call_later ()=> cb null, @data.list
    return
  
  complete : (@err, @data)->
    if !@err
      @is_complete = true
    for cb in @wait_list
      try
        if err = @err or data.error
          cb err
        else
          cb null, @data.list
      catch e
        perr e
    @wait_list.clear()
    return

class Collection
  name  : null
  parent: null
  request_cache_hash : {}
  timeout : 5*60*1000 # 5 min
  constructor : (@parent, @name)->
    @request_cache_hash = {}
    setTimeout ()=>
      setInterval ()=>
        now = Date.now()
        for k,v of @request_cache_hash
          if now - v.creation_time > @timeout
            delete @request_cache_hash[k]
        return
      , @timeout
  # ###################################################################################################
  #    durable handler
  # ###################################################################################################
  _request_push : (type, msg, cb)->
    @parent.request_need_send_list.push req = {
      type
      fn_start: ()=>
        @parent.wsrs.send msg, (err, data)=>
          if req.fn_done(err, data)
            cb err, data
          return
        
      fn_done : (err, data)->true
      ts : Date.now()
    }
    @parent._request_run()
    return
  
  # ###################################################################################################
  #    API
  # ###################################################################################################
  find : (where, col, cb)->
    if !cb
      cb = col
      col= {}
    @_request_push 'select', {
      switch  : "webnative"
      request : "find"
      collection : @name
      where : where
      column: col
    }, (err, data)=>
      # perr data # DEBUG
      if err = err or data.error
        cb? err
      else
        cb? null, data.list
  
  count : (where, cb)->
    @_request_push 'select', {
      switch  : "webnative"
      request : "count"
      collection : @name
      where : where
    }, (err, data)=>
      cb? err or data.error or null, data.count
  
  insert : (hash, cb)->
    @_request_push 'insert', {
      switch  : "webnative"
      request : "insert"
      collection : @name
      hash  : hash
    }, (err, data)=>
      cb? err or data.error or null, data.list
  
  update : (where, hash, cb)->
    @_request_push 'update', {
      switch  : "webnative"
      request : "update"
      collection : @name
      where : where
      hash  : hash
    }, (err, data)=>
      cb? err or data.error or null
  
  save : (hash, cb)->
    if arguments.length == 3
      [where, hash, cb] = arguments
    
    @_request_push (if hash._id then 'update' else 'insert'), {
      switch  : "webnative"
      request : "save"
      collection : @name
      hash  : hash
      where : where
    }, (err, data)=>
      cb? err or data.error or null, data.list
  
  remove : (where, cb)->
    @_request_push 'insert', { # NOTE remove has change row count semantics so it's equal to insert
      switch  : "webnative"
      request : "remove"
      collection : @name
      where : where
    }, (err, data)=>
      cb? err or data.error or null
  
  find_fast_cache : (where, col, cb)->
    if !cb
      cb = col
      col= {}
    key = JSON.stringify
      where : where
      col   : col
    if @request_cache_hash[key]?
      @request_cache_hash[key].setter cb if cb
      return
    pcr = @request_cache_hash[key] = new Pending_cache_request
    pcr.setter cb if cb
    @_request_push 'select', {
      switch  : "webnative"
      request : "find"
      collection : @name
      where : where
      column: col
    }, (err, data)=>
      pcr.complete err, data
  
  clear_fast_cache : ()->
    obj_clear @request_cache_hash
    return

class window.DB
  wsrs : null
  cache_collection_hash : {}
  request_need_send_list : []
  request_send_list : []
  current_request_type : ''
  constructor : (@wsrs)->
    @cache_collection_hash = {}
    @request_need_send_list = []
    @request_send_list = []
  
  collection : (name)->
    return @cache_collection_hash[name] if @cache_collection_hash[name]
    @cache_collection_hash[name] = new Collection @, name
  
  collection_list : (cb)->
    @wsrs.send
      switch  : "webnative"
      request : "collection_list"
    , cb
  # ###################################################################################################
  #    durable
  # ###################################################################################################
  _request_run : ()->
    if @request_send_list.length == 0
      @current_request_type = ''
    return if !req = @request_need_send_list[0]
    if @current_request_type == ''
      @current_request_type = req.type
    else if @current_request_type != req.type
      return
    
    req = @request_need_send_list.shift()
    @request_send_list.push req
    req.fn_done = (err, data)=>
      if err?.message == 'timeout'
        # resend
        req.fn_start()
        return false
      @request_send_list.remove req
      @_request_run()
      return true
    
    req.fn_start()
    return
