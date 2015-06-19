assert = require 'assert'
_smtp = require('../config').mail
_nodemailer = require 'nodemailer'
_smtpTransport = require 'nodemailer-smtp-transport'

transport = _nodemailer.createTransport(_smtpTransport(_smtp))
request = require 'request'

describe("邮件测试", ->

  it("基本发送测试", (done)->
    transport.sendMail({
      from: _smtp.auth.user,
      to: '646344359@qq.com',
      subject: 'hello',
      text: 'hello world!'
    }, (error, info)->
      console.log error, info
      done(error)
    )
  )

  it.only("HTTP接口测试", ()->
    request.post(
      {
        url: "http://localhost:3000/api/message/weixin",
        headers: {private_token: token}
        formData: {touser: "huyinghuan", content: "hello This is macha test message"}
      },
      (error, resp, body)->
        callback(error, resp.statusCode)
    )
  )

)