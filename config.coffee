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

  weixin:
    corpid: "wx79049864f9856554"
    corpsecret: "Y-uLlWdtepMOWElKB-nTBGjdZaKKtIkuRvZcTFuPwbBbNdaRsS4H_n43rbeCymFS"