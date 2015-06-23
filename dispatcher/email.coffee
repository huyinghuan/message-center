Base = require './base'
#获取黑砖窑里面的包工头
Supervisor = require '../black-brickkiln/supervisor'
redisClient = require('../db-connect').redis_conn()
#用来发邮件的奴隶数量
slaveCount = 3

class Email extends Base
  constructor: (@key)->
    #召唤处一个包工头 包含slaveCount个奴隶的
    @supervisor  = new Supervisor("email", slaveCount)

  push: (message, cb)->
    #消息校验未通过
    return cb(406,  "参数不合法") if not @verify(message)
    #同过后给出正在处理消息
    cb(200)
    redisClient.lpush(@key, JSON.stringify(message))
    @supervisor.startWork()

  #检验消息体
  verify: (message)-> return true


key = require('../config').message.email

module.exports = new Email(key)