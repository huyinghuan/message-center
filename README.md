接口说明
--------------------

## 统一约定

### 状态码
```
  200 : 请求响应正常
  205 : 数据在数据库中重复
  401 : 用户未认证（未登录）
  403 : 没有接口操作权限
  406 : 参数错误， 参数不符合接口要求，或者参数不合法
  500 : 服务器内部错误， 任何接口都可能返回这个状态码，因此不会在以下文档中做再次说明。
  503 : 服务器暂停服务，正在维护， 同上，任何接口都可能返回次状态码
```

### 基础路径

  所有api接口前面 全部加上 /api
  如 登录, 如果文档中写的是 login， 那么实际API接口为 http://remote_IP:port/api/login
  
### 数据格式 
  1 所有移动端到服务器，浏览器到服务器 全部采用json数据格式进行数据交换。
  2 服务端所有响应都会提供相应状态码
   
### 该文档规范说明
  0. 接口路径用 url描述
  1. 请求类型用method描述
  2. url参数类型用 query 描述
  3. 提交表单的参数类型 用body 描述
  4. url路径中携带的参数用 params描述
  5. 其中用needed表示必填参数， optional表示可选参数, 除非标记了needed，否则表示可选填内容
  6. 服务端响应 会提供状态码和相关数据。响应码用 status_code 表示，返回数据用data表示
  7. 如若相关属性不存在，则表示，该参数不必传递。或者没有返回数据（但是状态码是一定会有的）
  
  
  举例(非真实):
  desc: 提交某个检点的时间戳
  request:
```
    method: POST
    url:
      activity/:activity_id/group/:group_id/checkpoint/:checkpoint_id
    query: 
      random: {string} 随机数
    body: 
      token: {string} 令牌
    params: （这个参数实际是包含在路径里面的）
      activity_id: {string} 活动id
      group_id: {string} 组id
      checkpoint_id: {string} 检查点id
```

  response:
```
    1.  status_code: 200
        提交数据成功
    2.  status_code: 205
        该数据已提交过
```   
  假设现在你要提交 A活动的B组的C检查点到服务器，那么你应该如下操作：
    发送post请求到：
      http:xxx:port/api/activity/A/group/B/checkpoint/C?random=xxxx
    表单内容为
      {token: xxx}
    
  然后你 拿到了服务端的响应，  状态码为 200 表示数据处理成功了。 状态码为205 该检查点已经上传过了。
  
### 用户

#### 注册

Request:

```
  url: user
  method: POST
  body://用户的注册信息.
    {
        username: "string" #用户名 needed
        password: "string" #密码  needed
        password_repeat: "string" #重复密码
        email: "string" #email
    }
```

Response:
```
 状态码分以下几种情况：
   1. status_code: 200 注册成功 
   2. status_code: 205 用户名已注册
   3. status_code: 406 参数非法 
 
 返回数据：
    data: 无
```

### 登录

Request:

```
  url: login
  method: post
  body: {
    username: username
    password: passord
  }
```

Response:

```
状态分别为以下几种情况：

  200： 登录成功
    返回数据：
      {private_token: "xxxxxxxxx"}
        这里的token是作为以后 访问任何其他接口 所必备的。
        以后所有的请求服务器 都需要将此 private_token 设置到 request header里面发送到服务器。
      
      {headers: {private_token: "xxxxx", .....}}
        当做该用户的访问凭证。当然，有两个请求是不需要这个token的，他们分别是， 登录和注册

  401: 账户或密码错误
    返回数据： {string} 错误消息提示
    
  403： 该帐户已被封禁
    返回数据： {string} 错误消息提示
  
```

