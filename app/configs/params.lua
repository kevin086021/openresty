-- 用来定义全局配置的变量参数
public_params = {

    root_path = ngx.config.prefix(),        -- 根目录

    shared_key = 'localcache',              -- 共享内存的key名称

    env = {                                 -- 环境
        development = 'development',        -- 开发环境
        testing = 'testing',                -- 测试环境
        production = 'production'           -- 生产环境
    },
    
    error = {
        none = 200,
        invalid_json = 1001,
        lack_board_field = 1002,
    },
}