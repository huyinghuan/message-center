assert = require 'assert'
async = require 'async'
request = require 'request'
describe("发送消息到微信", ->

  it("发送", (done)->
    queue = []

    queue.push((callback)->
      request.post("http://localhost:3000/api/token", {form: {
          username: "test2"
          password: "123456"
        }, json: true},
        (error, resp, body)->
          callback(error, body.private_token)
      )
    )

    queue.push((token, callback)->
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

    async.waterfall(queue, (error, statusCode)->
      statusCode.should.eql(200)
      done()
    )
  )

)