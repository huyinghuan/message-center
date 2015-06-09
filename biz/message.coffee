Base = require('water-pit').Base

class Message extends Base
  constructor: ->

  post: (req, resp, next)->

  get: (req, resp, next)->
    resp.sendStatus(200)

module.exports = new Message()