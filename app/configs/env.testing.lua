-- 用来标识当前是哪一个环境，此文件中在不同的环境值不一样
local config = nil

config = require('configs.environment.testing')		--测试环境

return config