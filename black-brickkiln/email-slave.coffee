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
      #TODO 加入发邮件逻辑
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
    @event.on("supervisor:email:work", (e)->
      self.work() if not self.isWorking
    )


  send: (msg, done)->
    transport.sendMail({
        from: _smtp.auth.user,
        to: '646344359@qq.com',
        subject: 'hello',
        text: 'hello world!'
      }, (error, info)->
      console.log error, info
      done(error)
    )


  #处理出错的消息
  dealErrorMessage: (msg)->
    console.log msg, "error"

module.exports = WeixinSlave