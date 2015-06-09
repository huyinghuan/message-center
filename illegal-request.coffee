###
  非法请求过滤
  操作日志 记录
###
_ = require 'lodash'

config = require './config'

isDev = config.develop

redisClient = require('./db-connect').redis_conn()

Log = require './bean/log'

router = require('./router')

baseUrl = router.baseUrl
no_authentication = router.no_authentication

#是否为免验证接口
isNoAuthenticationPath = (path, method)->
  console.log path, method
  for item in no_authentication
    continue if path isnt "#{baseUrl}#{item.path}"
    #如果没有设置methods表示该路径下所有方法都不用验证
    return true if not item.methods
    #如果method在配置里面则不需要验证，否则需要验证
    return true if _.indexOf(item.methods, method) isnt -1
    return false

  return false

#是否为验证用户
isAuthenticationUser = (token)-> redisClient.get(token)

module.exports = (req, resp, next)->
  # 开发环境
  #return next() if isDev

  # 免验证的api接口
  return next() if isNoAuthenticationPath(req.path, req.method)

  #保存操作日志
  if userid = isAuthenticationUser(req.headers.private_token)
    Log.save({
      uid: userid
      api: req.url
      body: ""
    })
    return next()

  #拒绝操作
  resp.status(403).end()