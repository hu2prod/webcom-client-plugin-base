### !pragma coverage-skip-block ###
class Keymap
  @map    :
    a         : 65
    b         : 66
    c         : 67
    d         : 68
    e         : 69
    f         : 70
    g         : 71
    h         : 72
    i         : 73
    j         : 74
    k         : 75
    l         : 76
    m         : 77
    n         : 78
    o         : 79
    p         : 80
    q         : 81
    r         : 82
    s         : 83
    t         : 84
    u         : 85
    v         : 86
    w         : 87
    x         : 88
    y         : 89
    z         : 90
    
    0         : 48
    1         : 49
    2         : 50
    3         : 51
    4         : 52
    5         : 53
    6         : 54
    7         : 55
    8         : 56
    9         : 57
    
    tab       : 9
    enter     : 13
    shift     : 16
    backspace : 8
    
    ctrl      : 17
    alt       : 18
    esc       : 27
    escape    : 27
    space     : 32
    
    menu      : 93
    pause     : 19
    cmd       : 91
    win       : 91
    winkey    : 91
    cmd_left  : 91
    win_left  : 91
    winkey_left : 91
    
    cmd_right   : 92
    winkey_right: 92
    
    insert    : 45
    home      : 36
    pageup    : 33
    
    "delete"  : 46
    end       : 35
    pagedown  : 34
    
    f1        : 112
    f2        : 113
    f3        : 114
    f4        : 115
    f5        : 116
    f6        : 117
    f7        : 118
    f8        : 119
    f9        : 120
    f10       : 121
    f11       : 122
    f12       : 123
    
    num_0     : 96
    num_1     : 97
    num_2     : 98
    num_3     : 99
    num_4     :100
    num_5     :101
    num_6     :102
    num_7     :103
    num_8     :104
    num_9     :105
    
    num_slash :11
    num_star  :106
    num_hyphen:109
    num_minus :109
    num_plus  :107
    num_dot   :110
    
    "num_/"   :11
    "num_*"   :106
    "num_-"   :109
    "num_+"   :107
    "num_."   :110
    
    capslock  :20
    numlock   :144
    scrolllock:145
    
    equals    : 61
    hyphen    : 109
    minus     : 109
    coma      : 188
    comma     : 188
    dot       : 190
    "="       : 61
    "-"       : 109
    ","       : 188
    "."       : 190
    
    gravis    : 192
    "`"       : 192
    backslash : 220
    "\\"      : 220
    sbopen    : 219
    sbclose   : 221
    "["       : 219
    "]"       : 221
    
    slash     : 191
    "/"       : 191
    semicolon : 59
    ";"       : 59
    apostrophe: 222
    "'"       : 222
    
    left      : 37
    up        : 38
    right     : 39
    down      : 40
  
  @init     : ()->
    Keymap.rev_map = {}
    for k,v of Keymap.map
      Keymap.rev_map[v] = k
    for i in [0 .. 9]
      Keymap.map["num_#{i}"] = Keymap.map["num#{i}"]
    
    for k,v of Keymap.map
      if /^num_/.test k
        Keymap.map[k.replace("num_","num")    ] = v
        Keymap.map[k.replace("num_","numpad_")] = v
        Keymap.map[k.replace("num_","numpad ")] = v
    for k,v of Keymap.map
      Keymap.map[k.toUpperCase()] = v
    # make me easy
    for k,v of Keymap.map
      @[k] = v
    return
  
  @parse : (k)->
    k = k.toLowerCase()
    templ_res = 
      opt_shift       : /\[shift[-+]\]/i.test k
      opt_ctrl        : /\[ctrl[-+]\]/i .test k
      opt_alt         : /\[alt[-+]\]/i  .test k
      shift           : /shift[-+]/i    .test k
      ctrl            : /ctrl[-+]/i     .test k
      alt             : /alt[-+]/i      .test k
      prevent_default : true
      handler         : null
      code            : 0
    k = k.replace /shift[-+]/i, ""
    k = k.replace /ctrl[-+]/i,  ""
    k = k.replace /alt[-+]/i,   ""
    k = k.replace /\[\]/g,      ""
    if /-/.test k
      [ch_start, ch_end] = k.split(/-/)
    else
      ch_start = k
      ch_end   = k
    if !Keymap.map[ch_start]?
      perr "code for ch_start #{ch_start} not found"
      return []
    if !Keymap.map[ch_end]?
      perr "code for ch_end #{ch_end} not found"
      return []
    k_start = Keymap.map[ch_start]
    k_end   = Keymap.map[ch_end]
    res_list = []
    for k in [k_start .. k_end]
      res = clone templ_res
      res.code    = k
      res_list.push res
    res_list
  
Keymap.init()
window.Keymap = Keymap