redisClient = require('../db-connect').redis_conn()
async = require 'async'
Log = require '../log'

key = require('../config').message.weixin

class WeixinSlave
  constructor: (@event)->
    @initCall()

  work: ->
    self = @
    self.isWorking = true
    queue = []
    queue.push((done)->
      redisClient.lpop(key, (error, result)->
        return done(error) if error
        #工作完成，不需要进行下一步了
        if not result
          self.isWorking = false
          return done(null, null)
        done(null, JSON.parse(result))
      )
    )

    queue.push((message, done)->
      return done(null, null) if not message
      #TODO 加入发微信逻辑
      setTimeout(->
        console.log message
        done(null, message)
      , 1000)
    )

    async.waterfall(queue, (error, message)->
      return Log.error(error) if error
      self.work() if message
    )

  #是否正在工作
  isWorking: false

  #怕错过了工头训话
  initCall: ->
    self = @
    @event.on("supervisor:weixin:work", (e)->
      self.work() if not self.isWorking
    )


module.exports = WeixinSlave