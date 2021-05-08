### !pragma coverage-skip-block ###
global = window
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

window.devicePixelRatio ?= 1
# ###################################################################################################
#  rubyfy
# ###################################################################################################
window.p    = console.log.bind console
window.puts = console.log.bind console
window.pe   = console.error.bind console
window.perr = console.error.bind console
# proper print not available
window.print = console.log.bind console
window.println= console.log.bind console

# ###################################################################################################
#  matlabfy
# ###################################################################################################
timer = null
window.tic = ()->
  timer = new Date
window.toc = ()->
  (new Date - timer)/1000
window.ptoc = ()->
  console.log toc().toFixed(3)+" s"

# ###################################################################################################
#    pretty print
# ###################################################################################################
# NOT AVAILABLE in browser

# ###################################################################################################
#    String missing parts
# ###################################################################################################
String.prototype.reverse = ()->
  @split("").reverse().join("")

String.prototype.capitalize = ()->
  @substr(0,1).toUpperCase() + @substr 1

String.prototype.ljust = (length, char = " ")->
  append = new Array(Math.max(0, length - @length) + 1).join char
  append = append.substr 0, length - @length
  @ + append

String.prototype.rjust = (length, char = " ")->
  append = new Array(Math.max(0, length - @length) + 1).join char
  append = append.substr 0, length - @length
  append + @

String.prototype.center = (length, char = " ")->
  req_length = (length - @length + 1)//2
  append = new Array(Math.max(0, (req_length)*2)).join char
  append = append.substr 0, req_length
  pre = append
  post= append
  if (2*req_length + @length) > length
    post = post.substr 0, req_length-1
  pre + @ + post

String.prototype.repeat = (count)->
  res = new Array count+1
  res.join @

Number.prototype.ljust  = (length, char = " ")-> @.toString().ljust  length, char
Number.prototype.rjust  = (length, char = " ")-> @.toString().rjust  length, char
Number.prototype.center = (length, char = " ")-> @.toString().center length, char
Number.prototype.repeat = (count)-> @.toString().repeat count

# ###################################################################################################
#  Note this is polyfill between browser and server
# ###################################################################################################
window.call_later= (cb)->setTimeout cb, 0
window.requestAnimationFrame ?= call_later

# ###################################################################################################
#    Array missing parts
# ###################################################################################################
Array.prototype.has   = (t)-> -1 != @indexOf t
Array.prototype.upush = (t)->
  @push t if -1 == @indexOf t
  return

Array.isArray ?= (obj)-> obj instanceof Array
Array.prototype.clone = Array.prototype.slice
Array.prototype.clear = ()->@length = 0
Array.prototype.idx   = Array.prototype.indexOf
Array.prototype.remove_idx = (idx)->
  return @ if idx < 0 or idx >= @length
  @splice idx, 1
  @

# https://github.com/mafintosh/unordered-array-remove
Array.prototype.fast_remove = (t)->
  idx = @indexOf t
  return if idx == -1
  @[idx] = @[@length-1]
  @pop()
  @

Array.prototype.fast_remove_idx = (idx)->
  return @ if idx < 0 or idx >= @length
  @[idx] = @[@length-1]
  @pop()
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

# ###################################################################################################
#    hash missing parts
# ###################################################################################################
window.h_count = window.count_h = window.hash_count = window.count_hash = (t)->
  ret = 0
  for k of t
    ret++
  ret

window.is_object = (t)-> t == Object(t)

window.obj_set = Object.assign

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

# TODO benchmark vs [].concat(a,b) vs Array.concat vs a.concat(b)
window.array_merge = window.arr_merge = ()->
  r = []
  for a in arguments
    r = r.concat a
  r

window.obj_merge = ()->
  ret = {}
  for a in arguments
    for k,v of a
      ret[k] = v
  ret

# ###################################################################################################
#    RegExp missing parts
# ###################################################################################################
# http://stackoverflow.com/questions/3115150/how-to-escape-regular-expression-special-characters-using-javascript
RegExp.escape = (text)->text.replace /[-\/[\]{}()*+?.,\\^$|#\s]/g, "\\$&"

# ###################################################################################################
#  Function missing parts
# ###################################################################################################

Function.prototype.sbind = (athis, main_rest...)->
  __this = @
  ret       = (rest...)->__this.apply athis, main_rest.concat rest
  ret.call  = (_new_athis, rest...)-> __this.apply _new_athis, main_rest.concat rest
  ret.apply = (_new_athis, rest)->    __this.apply _new_athis, main_rest.concat rest
  # ret.toString = ()->__this.toString()
  ret

# ###################################################################################################
#    clone
# ###################################################################################################
window.clone = (t)->
  return t if t != Object(t)
  return t.slice() if Array.isArray t
  ret = {}
  for k,v of t
    ret[k] = v
  return ret

window.deep_clone = deep_clone = (t)->
  return t if t != Object(t)
  if Array.isArray t
    res = []
    for v in t
      res.push deep_clone v
    return res
  
  res = {}
  for k,v of t
    res[k] = deep_clone v
  res

# ###################################################################################################
#    Math unpack
# ###################################################################################################
_log2 = Math.log 2
_log10= Math.log 10
Math.log2 ?= (t)->Math.log(t)/_log2
Math.log10?= (t)->Math.log(t)/_log10
for v in "abs min max sqrt log round ceil floor log2 log10".split " "
  global[v] = Math[v]

# ###################################################################################################
#    MACRO-like
# ###################################################################################################
Object.defineProperty global, "__STACK__",
  get: ()->
    if Error.captureStackTrace
      orig = Error.prepareStackTrace
      Error.prepareStackTrace = (_, stack)->stack
      err = new Error
      Error.captureStackTrace err, arguments.callee
      stack = err.stack
      Error.prepareStackTrace = orig
      stack
    else
      []

Object.defineProperty global, "__LINE__",
  get: ()->__STACK__[1].getLineNumber()

Object.defineProperty global, "__FILE__",
  get: ()->__STACK__[1].getFileName().split("/").slice(-1)[0]

# ###################################################################################################
#    JSON semi-experimental
# ###################################################################################################
JSON.eq = (a,b)->
  JSON.stringify(a) == JSON.stringify(b)

JSON.ne = (a,b)->
  JSON.stringify(a) != JSON.stringify(b)

# ###################################################################################################
#    I hate promises
# ###################################################################################################
Promise.prototype.cb = (cb)->
  # промисы могут дважды вызвать callback
  used = false
  wrap_cb = (err, res)->
    if !used
      used = true
      cb err, res
    return
  
  # только через chaining. Иначе делает фигню
  @catch((err)=>wrap_cb err).then (res)=>wrap_cb null, res
  
puts "reload date #{new Date}"
