--[[
定时任务
]]

require('configs.params')

local _M = {} 

function _M:new() 

	return setmetatable({}, { __index = _M }) 

end 

function _M:update_cache()
    local ok, err
    -- 只对第一个进程执行
    local worker_id = tostring(ngx.worker.id())
    if worker_id ~= '0' then
        return nil
    end

    -- 把所有在线任务写入缓存
    local handler = function(premature)
        if not premature then
             --这边写上你需要做的任务
        end
    end
    -- 每隔5秒循环执行一次
    ok, err = ngx.timer.every(5, handler)
    if not ok then
        ngx.log(ngx.ERR, 'failed to create the timer: ', err)
        return nil
    end
    -- 刚执行的第一秒执行一次
    ok, err = ngx.timer.at(1, handler)
    if not ok then
        ngx.log(ngx.ERR, 'failed to create the timer first: ', err)
        return nil
    end

end

return _M
