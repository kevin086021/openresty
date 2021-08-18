local config = require('configs.env')

local mysql = require('resty.mysql')

local _M = {}

_M.__index = _M

-- 配置数据
_M.options = {
    host = config.mysql.host,
    port = config.mysql.port,
    user = config.mysql.user,
    password = config.mysql.password,
    database = config.mysql.database,
}
_M.timeout = 65535

--[[  
    先从连接池取连接,如果没有再建立连接.  
    返回:  
        false,出错信息.  
        true,数据库连接  
--]]  
function _M:get_connect(cfg)  

    if ngx.ctx[_M] then  
        return true, ngx.ctx[_M]  
    end  
  
    local client, errmsg = mysql:new()  
    if not client then  
        return false, "mysql.socket_failed: " .. (errmsg or "nil")  
    end  

    client:set_timeout(self.timeout)  
  
    local result, errmsg, errno, sqlstate = client:connect(self.options)  

    if not result then  
        return false, "mysql.cant_connect: " .. (errmsg or "nil") .. ", errno:" .. (errno or "nil") ..  
                ", sql_state:" .. (sqlstate or "nil")  
    end  

    local query = "SET NAMES " .. "utf8"  
    local result, errmsg, errno, sqlstate = client:query(query)  
    if not result then  
        return false, "mysql.query_failed: " .. (errmsg or "nil") .. ", errno:" .. (errno or "nil") ..  
                ", sql_state:" .. (sqlstate or "nil")  
    end  
  
    ngx.ctx[_M] = client  
  
    -- 测试，验证连接池重复使用情况  
    --[[ comments by leon1509  
    local count, err = client:get_reused_times()  
    ngx.say("xxx reused times" .. count);  
    --]]  
  
    return true, ngx.ctx[_M]  
end  
  
--[[  
    把连接返回到连接池  
    用set_keepalive代替close() 将开启连接池特性,可以为每个nginx工作进程，指定连接最大空闲时间，和连接池最大连接数  
 --]]  
function _M:close()  
    if ngx.ctx[_M] then  
        -- 连接池机制，不调用 close 而是 keeplive 下次会直接继续使用  
        -- lua_code_cache 为 on 时才有效  
        -- 60000 ： pool_max_idle_time ， 100：connections  
        ngx.ctx[_M]:set_keepalive(60000, 80)  
        -- 调用了 set_keepalive，不能直接再次调用 query，会报错  
        ngx.ctx[_M] = nil  
    end  
end  
  
--[[  
    执行SQL语句  
    有结果数据集时返回结果数据集  
    无数据数据集时返回查询影响  
    返回:  
        false,出错信息,sqlstate结构.  
        true,结果集,sqlstate结构.  
--]]  
function _M:query(sql)  

    local ret, client = self:get_connect(self.options)  
    if not ret then  
        ngx.log(1, client)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        --return false, client, nil  
    end  

    local result, errmsg, errno, sqlstate = client:query(sql)  

    while errmsg == "again" do  
        result, errmsg, errno, sqlstate = client:read_result()  
    end  
  
    self:close()  
  
    if not result then  
        errmsg = "mysql.query_failed:" .. (errno or "nil") .. (errmsg or "nil") 
        ngx.log(1, errmsg)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        --return false, errmsg, sqlstate  
    end  
  
    return true, result, sqlstate  
end  

-- 防SQL注入
function _M:quote_str(str)
    return ngx.quote_sql_str(str)
end

--[[  
    查询一条数据  
    有结果数据集时返回结果数据集  
    无数据数据集时返回 nil   
--]] 
function _M:get_data(sql)

    local ret, res, sqlstate = self:query(sql)
    if not ret then
        if not res then
            return nil
        else
            --ngx.say(res ..'<br>'..sql)
            --ngx.exit(ngx.HTTP_OK)
            ngx.log(1, res ..'<br>'..sql)
            ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        end
    else 
        for i, row in ipairs(res) do  
              return row 
        end  
    end 
end
  
--[[  
    查询多条数据  
    有结果数据集时返回结果数据集  
    无数据数据集时返回 nil  
--]] 
function _M:get_data_list(sql)
    local ret, res, sqlstate = self:query(sql)
    if not ret then
        if not res then
            return nil
        else
            --ngx.say(res ..'<br>'..sql)
            --ngx.exit(ngx.HTTP_OK)
            ngx.log(1, res ..'<br>'..sql)
            ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        end
    else 
        if(#res>0) then
            return res
        else
            return nil
        end
    end     
end  

--[[  
    执行SQL语句，如更新，删除，插入
    执行成功，返回 TRUE
    执行失败，显示报错原因
--]] 
function _M:execute(sql)
    local ret, res, sqlstate = self:query(sql)
    if not ret then
        if res then
            --ngx.say(res ..'<br>'..sql)
            --ngx.exit(ngx.HTTP_OK)
            ngx.log(1, res ..'<br>'..sql)
            ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        end
    end
    return true
end 

return _M




















