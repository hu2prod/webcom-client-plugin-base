### !pragma coverage-skip-block ###
websocket_list = []
if !window.WebSocket
  # thanks to dklab
  # никаких гарантий, никакой интерактивности, скажите спасибо, что мы вообще работаем
  # known BUG url too long 
  request_div = document.createElement 'div'
  document.body.appendChild request_div
  # "websocket" callback
  # must be visible
  client_int = 1000
  server_int = 15000  # max long poll duration
  
  
  server_int = 5000  # DEBUG
  
  window.__ws_cb = (uid, msg_uid, data)->
    for ws in websocket_list
      if ws.uid == uid
        if data?
          ws.dispatch "data", data
        ws.active_script_count--
        break
    if ws?.active_script_count < 2
      # need launch new
      ws.send null
    seek = "?u=#{uid}&mu=#{msg_uid}&"
    for child in request_div.children
      if -1 != child.src.indexOf seek
        request_div.removeChild child
        child.onerror = null # Handle memory leak in IE
        break
    return
  setInterval ()->
    for ws in websocket_list
      if ws.active_script_count < 2
        ws.send null
    return
  , client_int

class Websocket_wrap
  @uid : 0
  uid  : 0
  msg_uid  : 0
  # TODO event_mixin
  websocket : null
  timeout_min : 100 # 100 ms
  timeout_max : 5*1000 # 5 sec
  # timeout_max : 5*60*1000 # 5 min
  timeout_mult: 1.5
  timeout     : 100
  url         : ''
  reconnect_timer : null
  queue       : []
  
  fallback_mode : false
  active_script_count : 0
  
  event_mixin @
  constructor : (@url)->
    event_mixin_constructor @
    @uid = Websocket_wrap.uid++
    @queue = []
    @timeout = @timeout_min
    @ws_init()
    websocket_list.push @
  
  delete : ()->
    @close()
  
  close : ()->
    clearTimeout @reconnect_timer
    @websocket.onopen = ()->
    @websocket.onclose = ()->
    @websocket.onclose = ()->
    @websocket.close()
    websocket_list.remove @
  
  ws_reconnect : ()->
    return if @reconnect_timer
    @reconnect_timer = setTimeout ()=>
      @ws_init()
      return
    , @timeout
    return
  
  ws_init : ()->
    if !window.WebSocket
      @fallback_mode = true
      # uid must be replaced with some random garbage, because predictable uid causes someone can use your session
      @uid = ""+Math.random() # good enough for the first time
      # TODO make uid a-z A-Z contain (more information)
      
      @url = @url.replace "ws:",  "http:"
      @url = @url.replace "wss:", "https:"
      
      @url += "/ws"
      @url = @url.replace /\/\/ws$/, "/ws"
      return
    @reconnect_timer = null
    @websocket = new WebSocket @url
    @timeout = Math.min @timeout_max, Math.round @timeout*@timeout_mult
    @websocket.onopen   = ()=>
      @timeout = @timeout_min
      q = @queue.clone()
      @queue.clear()
      for data in q
        @send data
      return
    @websocket.onerror  = (e)=>
      puts "Websocket error."
      perr e
      @ws_reconnect()
      return
    @websocket.onclose = ()=>
      puts "Websocket disconnect. Restarting in #{@timeout}"
      @ws_reconnect()
      return
    @websocket.onmessage = (message)=>
      data = JSON.parse message.data
      @dispatch "data", data
      return
    return
  
  send : (data)->
    if @fallback_mode
      script = document.createElement 'script'
      script.src = "#{@url}?u=#{@uid}&mu=#{@msg_uid++}&i=#{server_int}&d=#{encodeURIComponent JSON.stringify data}"
      script.onerror = ()=> # resend
        request_div.removeChild script
        script.onerror = null # Handle memory leak in IE
        @active_script_count--
        @send data
        return
      
      setTimeout ()=> # глубокий fallback, super timeout
        if script.parentElement
          script.onerror()
        return
      , server_int*3
      
      request_div.appendChild script
      @active_script_count++
      return
    if @websocket.readyState != @websocket.OPEN
      @queue.push data
    else
      @websocket.send JSON.stringify data
    return
  
  write : @prototype.send

window.Websocket_wrap = Websocket_wrap
# TODO enable later
# protocol = if location.protocol == "http:" then "ws:" else "wss:"
# window.websocket = new Websocket_wrap "#{protocol}//#{location.hostname}:20016"