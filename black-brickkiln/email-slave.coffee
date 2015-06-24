_nodemailer = require 'nodemailer'
_smtpTransport = require 'nodemailer-smtp-transport'
_Slave = require './slave'
redisClient = require('../db-connect').redis_conn()

config = require '../config'

_key = config.message.email
_smtp = config.mail

transport = _nodemailer.createTransport(_smtpTransport(_smtp))

class EmailSlave extends _Slave
  constructor: (@event)->
    @type = "email"
    @key = _key
    @initCall()

  send: (data, done)->
    msg = data.msg
    self = @
    @standardEMail(msg)
    transport.sendMail(msg, (error, info)->
      done(null, msg)
      return if not error
      self.dealErrorMessage(data)
    )

  standardEMail: (msg)->
    msg.from = _smtp.auth.user
    msg.subject = msg.subject or "No title"
    msg

module.exports = EmailSlave