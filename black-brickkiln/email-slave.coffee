_nodemailer = require 'nodemailer'
_smtpTransport = require 'nodemailer-smtp-transport'

redisClient = require('../db-connect').redis_conn()
async = require 'async'
Log = require '../log'
config = require('../config')

key = config.message.email
_smtp = config.mail

transport = _nodemailer.createTransport(_smtpTransport(_smtp))

class EmailSlave
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
    @event.on("supervisor:email:work", (e)->
      self.work() if not self.isWorking
    )


  send: (msg, done)->
    self = @
    @standardEMail(msg)
    transport.sendMail(msg, (error, info)->
      done(null, msg)
      return if not error
      Log.error("THIS is email message")
      Log.error("error message:", error)
      Log.error("info:", info)
      self.dealErrorMessage(msg)
    )

  standardEMail: (msg)->
    msg.from = _smtp.auth.user
    msg.subject = msg.subject or "No title"
    msg

  #处理出错的消息
  dealErrorMessage: (msg)->
    console.log msg, "error"

module.exports = EmailSlave