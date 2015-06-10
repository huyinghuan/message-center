redisClient = require('../db-connect').redis_conn()

#获取黑砖窑里面的包工头
Supervisor = require '../black-brickkiln/supervisor'
#用来发微信的奴隶数量
slaveCount = 5

class Weixin
  constructor: (@key)->
    #初始化服务
    @initServer()

  ###
    message消息体
    {
      toUser: {string} #userid, 多个userid使用 | 分割开来
      content: {string} #消息内容
    }
  ###

  #存入消息体
  push: (message, cb)->
    #消息校验未通过
    return cb(406) if not @verify(message)
    #同过后给出正在处理消息
    cb(200)
    redisClient.lpush(@key, message)


  initServer: ->
    #召唤处一个包工头 包含５个奴隶的
    supervisor  = new Supervisor(slaveCount)
    #给包工头设置任务
    supervisor.setTask()









  #检验消息体
  verify: (message)->
    return true

module.exports = new Weixin("message:weixin")