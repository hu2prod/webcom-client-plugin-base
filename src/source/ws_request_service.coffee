### !pragma coverage-skip-block ###
class window.Ws_request_service
  ws : null
  request_uid : 0
  response_hash : {}
  interval : 1000
  timeout : 30000

  is_alive : true
  constructor : (@ws)->
    @response_hash = {}
    @ws.on "data", (data)=>
      # puts data
      if data.request_uid?
        if @response_hash[data.request_uid]?
          cb = @response_hash[data.request_uid].callback
          if data.error
            cb new Error(data.error), data
          else
            cb null, data
        else
          perr "missing request_uid = #{data.request_uid}. Possible timeout. switch=#{data.switch}"
      return
    
    setTimeout ()=>
      while @is_alive
        now = Date.now()
        for k,v of @response_hash
          if now > v.end_ts
            delete @response_hash[k]
            if !@quiet
              perr "ws_request_service timeout"
              perr v.req
              perr v.callback_orig.toString()
            v.callback new Error "timeout"
        await setTimeout defer(), @interval
    , 1
  
  delete : ()->
    @is_alive = false
  
  request : (req, handler, opt = {})->
    err_handler = null
    callback = (err, res)=>
      @ws.off "error", err_handler
      delete @response_hash[req.request_uid] if err or !res.continious_request
      delete res.request_uid if res?
      handler err, res
    
    @ws.once "error", err_handler = (err)=>
      callback err
    
    req.request_uid = @request_uid++
    @response_hash[req.request_uid] = {
      req
      callback
      callback_orig : handler
      end_ts    : Date.now() + (opt.timeout or @timeout)
    }
    @ws.write req
    return req.request_uid

  send : @prototype.request
