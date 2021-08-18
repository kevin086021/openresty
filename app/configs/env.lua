-- 用来标识当前是哪一个环境，此文件中在不同的环境值不一样
local config = nil

config = require('configs.environment.development')		--开发环境

return config