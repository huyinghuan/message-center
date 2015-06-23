redisClient = require('../db-connect').redis_conn()
async = require 'async'
jpush = require 'jpush-sdk'


Log = require '../log'
config = require('../config')

key = config.message.jpusher


_client = jpush.buildClient(config.jpush.appKey, config.jpush.masterKey)

class JPusherSlave
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
      self.send(message, done)
    )

    async.waterfall(queue, (error, message)->
      Log.error(error) if error
      self.work() if message
    )

  #是否正在工作
  isWorking: false

  #怕错过了工头训话
  initCall: ->
    self = @
    @event.on("supervisor:jpusher:work", (e)->
      self.work() if not self.isWorking
    )


  send: (msg, done)->
    self = @
    device_id = msg.device_id
    device_type = msg.device_type
    message = msg.message
    data = msg.data

    _client.push().setPlatform(jpush.ALL)
      .setAudience(jpush.registration_id(device_id))
      .setNotification('Hi, BHF', jpush.ios(message, '', 1, false, data))
      .send((err, res)->
        self.dealErrorMessage(err) if err
        done(null, msg)
      )

  #处理出错的消息
  dealErrorMessage: (msg)->
    console.log msg, "error"

module.exports = JPusherSlave