module.exports =
  #mysql 配置
  db:
    database:
      client: 'mysql'
      connection:
        host: 'localhost'
        user: 'root'
        password: '123456'
        database: 'message_center'
    schema: 'schema'

  # redis配置
  redis:
    host: "127.0.0.1"
    port: 6379

  #启动端口
  port: 3000

  #开发者模式
  develop: true

  message:
    weixin: "message:weixin"
    email: "message:email"
    jpusher: "message:jpusher"
    webhooks: "message:webhooks"
  weixin:
    agentid: 12
    corpid: "xxx"
    corpsecret: "xxx"
  mail:
    host: 'smtp.163.com'
    port: 25
    auth:
      user: "xxx",
      pass: "xxx"
  jpush:
    appKey: 'xxx'
    masterKey: 'xxx'