Base = require './base'

redisClient = require('../db-connect').redis_conn()

#获取黑砖窑里面的包工头
Supervisor = require '../black-brickkiln/supervisor'

#用来推送的奴隶数量
slaveCount = 3

class WebHooks extends Base
  constructor: (@key)->
    #召唤处一个包工头 包含５个微信奴隶的
    @supervisor  = new Supervisor("webhooks", slaveCount)

  #必须
  #存入消息体
  push: (message, cb)->
    #消息校验未通过
    return cb(406, "参数不合法") if not @verify(message)
    #同过后给出正在处理消息
    cb(200)
    redisClient.lpush(@key, JSON.stringify(message))
    @supervisor.startWork()


  #检验消息体
  verify: (message)-> return true


key = require('../config').message.webhooks

module.exports = new WebHooks(key)