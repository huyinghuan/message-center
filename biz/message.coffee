Base = require('water-pit').Base

redisClient = require('../db-connect')

fs = require 'fs'

dispatcherPath = path.join(process.cwd(), "dispatcher")

class Message extends Base
  constructor: ->

  post: (req, resp, next)->

    type = req.params.type

    type = "unknow" if not type

    return @code406(resp, "路径访问错误") if not @isExistsDispatcher(type)

    require(path.join(dispatcherPath, type)).push(req.body, (statusCode)->
      resp.sendStatus(statusCode)
    )


  get: (req, resp, next)->

    resp.sendStatus(200)

  isExistsDispatcher: (type)->
    return true if fs.existsSync(path.join(dispatcherPath, "#{type}.js"))
    return true if fs.existsSync(path.join(dispatcherPath, "#{type}.coffee"))
    return false

module.exports = new Message()