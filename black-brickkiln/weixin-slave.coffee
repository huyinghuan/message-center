redisClient = require('../db-connect').redis_conn()
async = require 'async'
Log = require '../log'
config = require('../config')
key = config.message.weixin

Wego = require('wego-enterprise')

Message = Wego.Message
access_token = new Wego.AccessToken(config.weixin.corpid, config.weixin.corpsecret)

weixin_token = "vRfZ5Jpv61xzviGeVm_9vr9h9WfWxoeAf8OLt2T9a1GdXMBXlDt2tWfsaCQk9ndL"

getToken = (cb)->
  access_token.get((error, token)->
    return Log.error(error) if error
    console.log weixin_token
    weixin_token = token
    cb and cb(token)
  )

#getToken()


class WeixinSlave
  constructor: (@event)->
    @message = new Message(weixin_token, config.weixin.agentid)
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
      self.send(message, done)
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


  send: (msg, done)->
    self = @
    @message.sendText(msg.touser, msg.content, (error, statusCode)->
      done(null, msg)
      return if statusCode is 200
      #过期，出错等等 403, 500, 400
      console.log error, statusCode
      Log.error(error)
      self.dealErrorMessage(msg)
      self.setToken() if statusCode is 403
    )

  setToken: ->
    self = @
    getToken((token)->self.message.setToken(token))

  #处理出错的消息
  dealErrorMessage: (msg)->
    console.log msg, "error"

module.exports = WeixinSlave