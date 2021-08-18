-- 开发环境的配置
local config = {}
config.name = public_params.env.development
config.mysql = {
    host = '127.0.0.1',
    port = 3306,
    user = 'root',
    password = '123456',
    database = 'test'
}
config.es = {
    name = '******',
    address = '******',
    username = '******',
    password = '******'
}
config.firehose = {
    region = '******',
    access_key = '******',
    secret_key = '******',
    index = '******'
}
return config