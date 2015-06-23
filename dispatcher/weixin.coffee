Wego = require 'wego-enterprise'

Base = require './base'

redisClient = require('../db-connect').redis_conn()

#获取黑砖窑里面的包工头
Supervisor = require '../black-brickkiln/supervisor'

#用来发微信的奴隶数量
slaveCount = 3

class Weixin extends Base
  constructor: (@key)->
    #召唤处一个包工头 包含５个微信奴隶的
    @supervisor  = new Supervisor("weixin", slaveCount)

  ###
    message消息体
    {
      touser: {string} #userid, 多个userid使用 | 分割开来
      content: {string} #消息内容
    }
  ###

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


key = require('../config').message.weixin

module.exports = new Weixin(key)