### !pragma coverage-skip-block ###
window.autoreload = true

protocol = if location.protocol == "http:" then "ws:" else "wss:"
image_uid = 0

if window.config_hot_reload
  update_style_uid = 0
  update_style = (image_update = false)->
    style_list = []
    for k,v of window.framework_style_hash
      style_list.push v
    
    style_tag = document.getElementsByTagName("style")[0]
    style_cont = style_list.join "\n"
    if window.host_patch
      style_cont = style_cont.replace(/url\(\//g, "url(#{host_patch}/")
    
    update_style_uid++ if image_update
    style_cont = style_cont.replace(/url\(\"([^"'\)]+)\"\)/g, "url(\"$1?#{update_style_uid}\")")
    style_cont = style_cont.replace(/url\(\'([^"'\)]+)\'\)/g, "url('$1?#{update_style_uid}')")
    style_cont = style_cont.replace(/url\(([^"'\)]+)\)/g, "url($1?#{update_style_uid})")
    
    try # this can crash under ie6
      style_tag.innerHTML = style_cont
    catch e
      return false
    
    return true
  
  update_style()
  window.hot_reload_event_mixin = new Event_mixin
  
  url_parser = (url)->
    parser = document.createElement("a");
    parser.href = url
    parser
  
  window.hot_reload_websocket ?= new window.Websocket_wrap "#{protocol}//#{location.hostname}:#{config_hot_reload_port}#{location.pathname}"
  window.hot_reload_websocket.on "data", window.hot_reload_handler = (data)->
    return if !autoreload
    if data.event == "add" and data.switch != "hotreload_image"
      location.reload()
    
    switch data.switch
      when "hotreload_full"
        return if data.start_ts == start_ts
        hot_reload_event_mixin.dispatch "hotreload_full"
        location.reload()
      when "hotreload_js"
        return if data.start_ts == start_ts
        return if !file_list.has data.path
        if /\.com\.coffee$/.test data.path
          if window.hot_reload_extension
            {content} = data
            puts "exec #{data.path}"
            content += "//# sourceURL=#{data.path}";
            window.hotreplace = true
            eval content
            window.hotreplace = false
            window.bootstrap?()
            return
          hot_reload_event_mixin.dispatch "hotreload_com"
          new_script = document.createElement "script"
          window.hotreplace = true
          new_script.onload = ()=>
            window.hotreplace = false
            window.bootstrap?()
          new_script.src = data.path
          document.body.appendChild(new_script)
        else
          hot_reload_event_mixin.dispatch "hotreload_full"
          location.reload()
      when "hotreload_style"
        window.framework_style_hash[data.path] = data.content
        if !update_style()
          location.reload()
      when "hotreload_template"
        window.framework_template_hash[data.path] = window.template_preprocess data.content
        hot_reload_event_mixin.dispatch "hotreload_template", data.path
      when "hotreload_image"
        for loc_img in document.getElementsByTagName("img")
          url = url_parser(loc_img.src)
          src = url.pathname
          src = src.replace /^\//, ""
          data.path = data.path.replace /^\//, ""
          if src == data.path # TOO bad compare
            if url.protocol # full
              loc_img.src = "#{url.protocol}//#{url.host}#{url.pathname}?cache_killer=#{image_uid++}"
            else # simple
              loc_img.src = "#{url.pathname}?cache_killer=#{image_uid++}"
        
        if !update_style(true)
          location.reload()
        
    return
