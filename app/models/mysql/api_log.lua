--[[
api_log 数据库操作日志
]]
local cjson = require('cjson')
local _M = {}

_M.table_name = 'api_log'

_M.p = nil

function _M:new()

    self.p = require('models.mysql.base'):new()

    self.fun = require("tools.fun")

    local super_mt = getmetatable(self.p)

    setmetatable(_M, super_mt)

    self.p.super = setmetatable({}, super_mt)

    return setmetatable(self.p, { __index = _M })
end

function _M:save(type_str, request, response)
	request = cjson.encode(request)
    response = cjson.encode(response)
    response = ngx.re.gsub(response, "'", '"')
	local now_time = ngx.time()
    local sql = "INSERT INTO `api_log` SET `type`='"..type_str.."', `request`='"..request.."', `response`='"..response.."', `created_at`='"..tostring(now_time).."', `updated_at`='"..tostring(now_time).."' "
	self.p.db:execute(sql)
end

return _M