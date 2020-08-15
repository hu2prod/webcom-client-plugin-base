### !pragma coverage-skip-block ###
# TODO пересматривать https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills
# ###################################################################################################
#    Poor poor IE, and phantomjs
# ###################################################################################################
# better polyfill https://github.com/paulmillr/console-polyfill/blob/master/index.js
window.console ?= {}
window.console.log ?= ()->
window.console.log.bind ?= ()->
  ()->
window.console.error ?= ()->
window.console.error.bind ?= ()->
  ()->
Date.now ?= ()->new Date().getTime() # https://gist.github.com/eliperelman/1035932

# http://blog.stevenlevithan.com/archives/faster-trim-javascript
# String.prototype.trim ?= ()->@replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '')
String.prototype.trim ?= ()->@replace(/^[\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680\u180E\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000\u2028\u2029\uFEFF\xA0]+|[\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680\u180E\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000\u2028\u2029\uFEFF\xA0]+$/g, '')
# https://developer.mozilla.org/ru/docs/Web/JavaScript/Reference/Global_Objects/String/Trim
# https://gist.github.com/eliperelman/1035982 тут несогласны и предлагают заменять \s на \u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680\u180E\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000\u2028\u2029
# http://perfectionkills.com/whitespace-deviations/ список идиотизмов
Object.keys ?= (t)->
  ret = []
  for k of t
    ret.push k
  ret
# ВНИМАНИЕ. Это НЕПРАВИЛЬНЫЙ polyfill, но мне его достаточно
# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/indexOf
Array.prototype.indexOf ?= (t)-> # indexOf is not in all browsers, lol
  for v,k in @
    return k if v == t
  -1
# need JSON http://cdnjs.cloudflare.com/ajax/libs/json3/3.3.2/json3.js (faster/serurer than eval)
# ###################################################################################################
#  rubyfy
# ###################################################################################################
String.prototype.to_s = ()-> @toString()
window.p    = console.log.bind console
window.puts = console.log.bind console
window.pe   = console.error.bind console
window.perr = console.error.bind console
# proper print not available
window.print = console.log.bind console
window.println= console.log.bind console
Array.prototype.to_s  = Array.prototype.toString
Number.prototype.to_s = Number.prototype.toString

String.prototype.reverse = ()->
  @split('').reverse().join('')
String.prototype.capitalize = ()->
  @substr(0,1).toUpperCase() + @substr 1
String.prototype.center = (length, char = ' ')->
  append_length= Math.max(0, length - @length)/2
  append_start = new Array(Math.ceil(append_length) + 1).join char
  append_end   = new Array(Math.floor(append_length) + 1).join char
  append_start + @ + append_end
String.prototype.ljust = (length, char = ' ')->
  append = new Array(Math.max(0, length - @length) + 1).join char
  append = append.substr 0, length - @length
  @ + append
String.prototype.rjust = (length, char = ' ')->
  append = new Array(Math.max(0, length - @length) + 1).join char
  append = append.substr 0, length - @length
  append + @
String.prototype.repeat = (count)->
  res = new Array count+1
  res.join @
Number.prototype.ljust  = (length, char = ' ')-> @.toString().ljust  length, char
Number.prototype.rjust  = (length, char = ' ')-> @.toString().rjust  length, char
Number.prototype.center = (length, char = ' ')-> @.toString().center length, char
Number.prototype.repeat = (count)-> @.toString().repeat count
# ###################################################################################################
#  matlabfy
# ###################################################################################################
timer = null
window.tic = ()->
  timer = new Date
window.toc = ()->
  (new Date - timer)/1000
window.ptoc = ()->
  console.log toc().toFixed(3)+' s'
# ###################################################################################################
#  generic
# ###################################################################################################
window.call_later= (cb)->setTimeout cb, 0
window.requestAnimationFrame ?= call_later
window.once_interval = (timer, cb, interval=100)->
  if !timer
    return setTimeout cb, interval
  return timer
window.call_later_replace = (timer, cb, timeout = 0)->
  clearTimeout timer if timer
  setTimeout cb, timeout
Array.prototype.has   = (t)-> -1 != @indexOf t
Array.prototype.upush = (t)->
  @push t if -1 == @indexOf t
  return
Array.prototype.clone = Array.prototype.slice
Array.prototype.clear = ()->@length = 0
Array.prototype.idx   = Array.prototype.indexOf
Array.prototype.remove_idx = (idx)->
  return @ if idx < 0 or idx >= @length
  @splice idx, 1
  @
Array.prototype.remove = (t)->
  @remove_idx @idx t
  @
Array.prototype.last = Array.prototype.end = ()->
  @[@length-1]
Array.prototype.insert_after = (idx, t)->
  @splice idx+1, 0, t
  t
Array.prototype.append = (list)->
  for v in list
    @push v
  @
Array.prototype.uappend = (list)->
  for v in list
    @upush v
  @
window.h_count = window.count_h = window.hash_count = window.count_hash = (t)->
  ret = 0
  for k of t
    ret++
  ret
window.count = (t)->
  return t.length if t instanceof Array
  ret = 0
  for k of t
    ret++
  ret
# minimal _
__ = {}
__.isObject = (obj)-> obj == Object(obj)
# __.isArray = Array.isArray || (obj)-> toString.call(obj) == '[object Array]' # не согласен с underscore
__.isArray = Array.isArray || (obj)-> obj instanceof Array
__.copy_obj   = (obj)->
  ret = {}
  for k,v of obj
    ret[k] = v
  ret
__.clone  = (obj)->
  return obj if !__.isObject obj
  # if obj instanceof RegExp # этого не делает __.clone
  # return if __.isArray(obj) then obj.slice() else __.extend({}, obj)
  return if __.isArray(obj) then obj.slice() else __.copy_obj obj

window.clone = __.clone
window.deep_clone = deep_clone = (obj)->
  if obj instanceof Array
    res = []
    for v in obj
      res.push deep_clone v
    return res
  if __.isObject obj
    res = {}
    for k,v of obj
      res[k] = deep_clone v
    return res
  obj
window.obj_set = (dst, src)->
  for k,v of src
    dst[k] = v
  dst
window.obj_clear = (t)->
  for k,v of t
    delete t[k]
  t
Array.prototype.set = (t)->
  @length = t.length
  for v,k in t
    @[k] = v
  @
window.arr_set = (dst, src)->
  dst.length = src.length
  for v,k in src
    dst[k] = v
  dst
# TODO benchmark vs [].concat(a,b) vs a.concat(b)
window.array_merge = window.arr_merge = (a, b)->a.concat b
# window.array_merge = window.arr_merge = (a, b)->
#   ret = new Array a.length + b.length
#   idx = 0
#   for v in a
#     ret[idx++] = v
#   for v in b
#     ret[idx++] = v
#   ret
window.obj_merge = ()->
  ret = {}
  for a in arguments
    for k,v of a
      ret[k] = v
  ret
# http://stackoverflow.com/questions/3115150/how-to-escape-regular-expression-special-characters-using-javascript
# https://github.com/vird/ie7-js/blob/master/src/base2.js
RegExp.escape = (text)->text.replace /([-\/[\]{}()*+?.,\\^$|#\s])/g, "\\$1"
# RegExp.escape = (text)->text.replace /[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"

if window.localStorage?
  window.pref_storage_get = (k)->   JSON.parse localStorage.getItem k
  window.pref_storage_set = (k,v)-> localStorage.setItem k, JSON.stringify v
else
  window.pref_storage_get = (k)->   JSON.parse $.cookie k
  window.pref_storage_set = (k,v)-> $.cookie k, JSON.stringify v


window.devicePixelRatio ?= 1
  
  
puts "reload date #{new Date}"