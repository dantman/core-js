require! {'../fn/promise', './config': {banner}, fs: {readFile, writeFile, unlink}, path: {join}, webpack, temp}

list = <[
  es5
  es6.symbol
  es6.object.assign
  es6.object.is
  es6.object.set-prototype-of
  es6.object.to-string
  es6.object.freeze
  es6.object.seal
  es6.object.prevent-extensions
  es6.object.is-frozen
  es6.object.is-sealed
  es6.object.is-extensible
  es6.object.get-own-property-descriptor
  es6.object.get-prototype-of
  es6.object.keys
  es6.object.get-own-property-names
  es6.function.name
  es6.function.has-instance
  es6.number.constructor
  es6.number.epsilon
  es6.number.is-finite
  es6.number.is-integer
  es6.number.is-nan
  es6.number.is-safe-integer
  es6.number.max-safe-integer
  es6.number.min-safe-integer
  es6.number.parse-float
  es6.number.parse-int
  es6.math.acosh
  es6.math.asinh
  es6.math.atanh
  es6.math.cbrt
  es6.math.clz32
  es6.math.cosh
  es6.math.expm1
  es6.math.fround
  es6.math.hypot
  es6.math.imul
  es6.math.log10
  es6.math.log1p
  es6.math.log2
  es6.math.sign
  es6.math.sinh
  es6.math.tanh
  es6.math.trunc
  es6.string.from-code-point
  es6.string.raw
  es6.string.trim
  es6.string.code-point-at
  es6.string.ends-with
  es6.string.includes
  es6.string.repeat
  es6.string.starts-with
  es6.string.iterator
  es6.string.anchor
  es6.string.big
  es6.string.blink
  es6.string.bold
  es6.string.fixed
  es6.string.fontcolor
  es6.string.fontsize
  es6.string.italics
  es6.string.link
  es6.string.small
  es6.string.strike
  es6.string.sub
  es6.string.sup
  es6.array.from
  es6.array.of
  es6.array.iterator
  es6.array.species
  es6.array.copy-within
  es6.array.fill
  es6.array.find
  es6.array.find-index
  es6.regexp.constructor
  es6.regexp.flags
  es6.regexp.match
  es6.regexp.replace
  es6.regexp.search
  es6.regexp.split
  es6.promise
  es6.map
  es6.set
  es6.weak-map
  es6.weak-set
  es6.reflect.apply
  es6.reflect.construct
  es6.reflect.define-property
  es6.reflect.delete-property
  es6.reflect.enumerate
  es6.reflect.get
  es6.reflect.get-own-property-descriptor
  es6.reflect.get-prototype-of
  es6.reflect.has
  es6.reflect.is-extensible
  es6.reflect.own-keys
  es6.reflect.prevent-extensions
  es6.reflect.set
  es6.reflect.set-prototype-of
  es6.date.to-string
  es6.typed.array-buffer
  es6.typed.data-view
  es6.typed.int8-array
  es6.typed.uint8-array
  es6.typed.uint8-clamped-array
  es6.typed.int16-array
  es6.typed.uint16-array
  es6.typed.int32-array
  es6.typed.uint32-array
  es6.typed.float32-array
  es6.typed.float64-array
  es7.array.includes
  es7.string.at
  es7.string.pad-start
  es7.string.pad-end
  es7.string.trim-left
  es7.string.trim-right
  es7.object.get-own-property-descriptors
  es7.object.values
  es7.object.entries
  es7.map.to-json
  es7.set.to-json
  es7.system.global
  es7.error.is-error
  es7.math.iaddh
  es7.math.isubh
  es7.math.imulh
  es7.math.umulh
  es7.reflect.define-metadata
  es7.reflect.delete-metadata
  es7.reflect.get-metadata
  es7.reflect.get-metadata-keys
  es7.reflect.get-own-matadata
  es7.reflect.get-own-metadata-keys
  es7.reflect.has-metadata
  es7.reflect.has-own-metadata
  es7.reflect.metadata
  web.immediate
  web.dom.iterable
  web.timers
  core.dict
  core.get-iterator-method
  core.get-iterator
  core.is-iterable
  core.delay
  core.function.part
  core.object.is-object
  core.object.classof
  core.object.define
  core.object.make
  core.number.iterator
  core.regexp.escape
  core.string.escape-html
  core.string.unescape-html
]>

experimental = <[
  es7.reflect.define-metadata
  es7.reflect.delete-metadata
  es7.reflect.get-metadata
  es7.reflect.get-metadata-keys
  es7.reflect.get-own-matadata
  es7.reflect.get-own-metadata-keys
  es7.reflect.has-metadata
  es7.reflect.has-own-metadata
  es7.reflect.metadata
]>

libraryBlacklist = <[
  es6.object.to-string
  es6.function.name
  es6.regexp.constructor
  es6.regexp.flags
  es6.regexp.match
  es6.regexp.replace
  es6.regexp.search
  es6.regexp.split
  es6.number.constructor
  es6.date.to-string
]>

es5SpecialCase = <[
  es6.object.freeze
  es6.object.seal
  es6.object.prevent-extensions
  es6.object.is-frozen
  es6.object.is-sealed
  es6.object.is-extensible
  es6.string.trim
]>

module.exports = ({modules = [], blacklist = [], library = no})->
  resolve, reject <~! new Promise _
  let @ = modules.reduce ((memo, it)-> memo[it] = on; memo), {}
    if @exp => for experimental => @[..] = on
    if @es5 => for es5SpecialCase => @[..] = on
    for ns of @
      if @[ns]
        for name in list
          if name.indexOf("#ns.") is 0 and name not in experimental
            @[name] = on

    if library => blacklist ++= libraryBlacklist
    for ns in blacklist
      for name in list
        if name is ns or name.indexOf("#ns.") is 0
          @[name] = no

    TARGET = temp.path {suffix: '.js'}

    err, info <~! webpack do
      entry: list.filter(~> @[it]).map ~>
        if library => join __dirname, '..', 'library', 'modules', it
        else join __dirname, '..', 'modules', it
      output:
        path: ''
        filename: TARGET
    if err => return reject err

    err, script <~! readFile TARGET
    if err => return reject err

    err <~! unlink TARGET
    if err => return reject err

    resolve """
      #banner
      !function(__e, __g, undefined){
      'use strict';
      #script
      // CommonJS export
      if(typeof module != 'undefined' && module.exports)module.exports = __e;
      // RequireJS export
      else if(typeof define == 'function' && define.amd)define(function(){return __e});
      // Export to global object
      else __g.core = __e;
      }(1, 1);
      """