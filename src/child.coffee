BAMReader = require(__dirname + "/bamreader")
BAMIterator = BAMReader.BAMIterator
LSIZE = 12
crypto = require("crypto")
process.on "message", (msg)->
  for k in msg._funcs
    msg[k] = eval("(#{msg[k]})")
  delete msg._funcs

  reader = BAMReader.createFromObject msg.reader
  msg.env = {} if not msg.env or not msg.$
  env = msg.env
  env[k] = msg[k] for k in ["start", "end", "n"]
  Object.defineProperty env, "exit",
    get: ->
      env._exit_will_be_called = true
      return ->
        env.ended = true
        process.send(env)
        process.exit()

  itr = BAMIterator.create(reader, msg)
  itr.on_end = ($)->
    msg.on_end.call(itr, $) if typeof msg.on_end is "function"
    $.exit() unless $._exit_will_be_called