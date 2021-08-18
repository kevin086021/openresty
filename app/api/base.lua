local cjson = require('cjson')
local string = require('string')
local os = require('os')
local http = require ('resty.http')

local _M = {}

_M.need_des = false
_M.cache_key_ip_mac_id = "qc_ip_mac_id_cache_name"

function _M:new()
	
	self.fun = require("tools.fun")
	self.env = require('configs.env')

    ngx.ctx = {}
	ngx.ctx.params = {}
	ngx.ctx.params.created_at = os.date("!%Y-%m-%dT%T+0800", ngx.time()+8*60*60)
	ngx.ctx.params.ip = self:get_ip()
	ngx.ctx.params.request = self.fun:get_get()
	ngx.ctx.params.response = {}
	ngx.ctx.params.response.status = public_params.error.none
	ngx.ctx.params.response.data = {}
	ngx.ctx.params.have_task = '0'
	ngx.ctx.params.top_time = ngx.now()
	ngx.ctx.params.test_time = 0

	return setmetatable({}, { __index = _M })
end 

-- API解密 bin_string 为被先压缩再加密的二进制字符串，所以需要先解密再解压
function _M:api_decrypt(bin_string)             -- 子类调此方法，必须要实现 error 的方法

	if self.fun:is_json(bin_string) then
		self:error(public_params.status.decrypt_faild)
	end

	local str = self.fun:decrypt(bin_string, public_params.secret.key, public_params.secret.iv)

	if str == nil or str == null or str == '' or not str then
		self:error(public_params.status.decrypt_faild)
	end
	return cjson.decode(self.fun:gunzip(str))
end

-- API加密
function _M:api_encrypt(string)

	local bin_string = self.fun:gzip(string)

	return self.fun:encrypt(bin_string, public_params.secret.key, public_params.secret.iv)
end

-- 获取IP地址
function _M:get_ip() 

    local headers = ngx.req.get_headers()

    local realip = headers["X_FORWARDED_FOR"]

    if type(realip) == "string" then

    	local my_arr = self.fun:string_to_array(realip)

        return self.fun:array_first(my_arr)
    end

    if type(realip) == "table" then

        return realip[#realip]

    end

    return ngx.var.remote_addr
end 

-- 直接把IP地址库存在内存中
function _M:get_ip_region()

	local ip2region = require('resty.ip2region').new({

		file = public_params.root_path..'app/data/ip2region.db',

		root = public_params.root_path,
		
		dict = public_params.shared_key,
		
		mode = 'memory'
	})

	return ip2region
end

-- 根据IP地址获取国家的基本信息
function _M:get_country_message_by_ip(ip)

	local result = nil

	if not ip then
		ip = self:get_ip()
	end

	if ip ~= '127.0.0.1' and ip ~= '192.168.192.1' then

		local ip2region = self:get_ip_region()

	    local  data, err = ip2region:search(ip);

		if (err == nil) then
			result = data
		end
	end

	return result
end

-- 获取国家名称
function _M:get_country_name(ip)
	local country_name = '中国'

	if not ip then
		ip = self:get_ip()
	end

	if ip ~= '127.0.0.1' and ip ~= '192.168.192.1' then

		local ip2region = self:get_ip_region()

	    local  data, err = ip2region:search(ip);

		if (err == nil) then
			if data.country then
				country_name = data.country
		    end
		end
	end

	return country_name
end

function _M:push_data_to_local_kibana(from)

	local es_addr = self.env.es.address
	local es_index_name = self.env.es.name

	if string.sub(from, 0, 3) == 'pre' then
		es_index_name = from .. '-'..es_index_name..'-' .. os.date("%Y-%m-%d", ngx.now())
	else
		es_index_name = es_index_name .. '-'..from..'-' .. os.date("%Y-%m-%d", ngx.now())
	end

	local use_time = ngx.now() - ngx.ctx.params.top_time
	local jdata = {
		from = from,
		created_at = string.gsub(ngx.localtime(), " ", "T") .. "+0800",
		top_time = ngx.ctx.params.top_time,
		send_time = ngx.now(),
		api_time = use_time,
		test_time = ngx.ctx.params.test_time,
		ip = self:get_ip(),
		request = self.fun:tableValueToStr(ngx.ctx.params.request)
	}

	if not self.fun:is_empty(ngx.ctx.params.request.life) then 
		jdata.request.life_force_int = tonumber(ngx.ctx.params.request.life)
	end

	--　pre　的日志不返回 response 
	if string.sub(from, 0, 3) == 'pre' then
		jdata.response =  null
	else
		local myResponse = {}
		myResponse.status = public_params.error.none
		if from == 'device' or from == 'task' then
			myResponse.have_task = ngx.ctx.params.have_task
		end
		if not self.fun:is_empty(ngx.ctx.params.response.code) then 
			myResponse.code =  ngx.ctx.params.response.code
		end 
		if ngx.ctx.params.response.data then
			local res_str_arr = self.fun:tableValueToStr(ngx.ctx.params.response.data)
			myResponse.data = res_str_arr
		end
		jdata.response =  myResponse
	end 

	--self.fun:prt(jdata)

    local httpc = http.new()
	local json_data = cjson.encode(jdata)
    local res,err = httpc:request_uri(es_addr .. "/"..es_index_name.."/logs", {
        method = "POST",
        body = json_data,
        headers = {
            ["Content-Type"] = "application/json"
        }
    })
	--self.fun:prt(err)

	if not res then
        return
	end

	httpc:set_keepalive(60)
end

-- 出错
function _M:error(code, from)

	ngx.ctx.params.response.data = null

	ngx.ctx.params.response.code = code

	self:response(from)
end

--正常响应
function _M:response(from)
	
	--把日志直接保存到kibana中
	self:push_data_to_local_kibana(from)

	local response_data = cjson.encode(ngx.ctx.params.response)
	response_data = ngx.re.gsub(response_data, [[\\/]], [[/]])
	ngx.print(response_data)
	ngx.exit(ngx.OK)
end

--设置COOKIE，默认时间为一年
function _M:set_cookie(my_key, my_value)
	ngx.header['Set-Cookie'] = my_key..'='..my_value..'; path=/; Expires=' .. ngx.cookie_time(ngx.time() + 60 * 60 * 24 * 365)
end

function _M:get_cookie(key)
	local key_name = 'cookie_'..key
	return ngx.var[key_name]
end

function _M:get_ip_mac()
	local data_str = self.fun:get_cache(self.cache_key_ip_mac_id)
	
	local my_data = {}
	if not self.fun:is_empty(data_str) then 
		my_data = cjson.decode(data_str)
	end 

	return my_data
end

function _M:set_ip_mac(key, value)
	local my_data = self:get_ip_mac()
	my_data[key] = value
	local data_str = cjson.encode(my_data)
	-- 3600*24*365 = 31536000
	self.fun:set_cache(self.cache_key_ip_mac_id, data_str, 31536000)
end


return _M

