-- 加载路由配置
local white_list = require('configs.rotue')

-- 获取当前 URL
local request_uri = ngx.var.uri

-- 如果URL什么也没有填写，则直接显示空
if request_uri == '/' then
	ngx.say('')
	ngx.exit(ngx.HTTP_OK)
end

-- 在路由中不存在就返回404
if not white_list[request_uri] then
  ngx.exit(ngx.HTTP_NOT_FOUND)
end

-- 加载 URL 白名单
local request_uri = white_list[request_uri]

-- 拼接API的包名
local api_package = 'api'..request_uri

require('configs.params')

-- 引入当前的包名
local object = require(api_package):new()

-- 执行 run 方式
object:run()