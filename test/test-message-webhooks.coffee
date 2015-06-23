assert = require 'assert'

request = require 'request'

token = "9cb312d0-14d1-11e5-b79b-bfa179cfc352"

describe("WebHooks 测试", ->


  it.only("HTTP接口测试", ()->
    request.post(
      {
        url: "http://localhost:3000/api/message/webhooks",
        headers: {private_token: token}
        body:
          url: ""
          headers: {}
          body: {}
        json: true
      },
      (error, resp, body)->
       # callback(error, resp.statusCode)
        console.log error
        console.log resp.statusCode
        console.log body
    )
  )

)