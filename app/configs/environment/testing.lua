-- 测试环境的配置
local config = {}
config.name = public_params.env.testing
config.mysql = {
    host = '******',
    port = 3306,
    user = '******',
    password = '******',
    database = '******'
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