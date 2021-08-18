local cjson = require('cjson')
local random = require('resty.random')
local string = require('string')

local _M = {}

_M.__index = _M
 
_M.c = ngx.shared[public_params.shared_key]

-- 根据键值获取缓存数据
function _M.get_cache(self, key)
    local info = nil
    if key and self.c ~= nil then
        info = self.c:get(key)   -- 若用 get_stale 则表示忽视过期的情况
    end
    return info
end

-- 设置缓存中的值
function _M.set_cache(self, key, value, life_second)
	if key and self.c ~= nil then
		if not life_second then
			life_second = 300
		end
    	self.c:set(key, value, life_second)
    end 
end

-- 获取随机字符器
function _M:rand_str()

    return ngx.md5(require("resty.random").bytes(32))

end

--获取随机数
function _M:rand_number(min, max)

    math.randomseed(math.random(ngx.now())) -- 设置种子

    if max and min then 
        return math.random(min, max)        -- 传两个数，则获取两个数以之间的随机数
    elseif min then 
        return math.random(min)             -- 传一个数，则获取1-min 这个数之间的数
    else 
        return math.random(ngx.time())      -- 不传，则获取从1-当前时间戳对应的值之间的数
    end 
end 

-- 一唯数组转成字符串，用特殊符号分隔
function _M:array_to_string(my_array, flag)
	local str = ''
	local tmp_flag = ''
	if not flag then
		flag = ','
	end

  	for i, value in ipairs(my_array) do    
    	str = str .. tmp_flag .. value
    	tmp_flag = flag
  	end 

  	return str
end

-- 字符串转成数组
function _M:string_to_array(str, delimiter)
	if str==nil or str=='' then
	    return nil
	end

	if delimiter==nil then
		delimiter = ','
	end

	local result = {}
	for match in (str..delimiter):gmatch("(.-)"..delimiter) do
	    table.insert(result, match)
	end
	return result
end

function _M:array_first(arr)
    if arr[1] then
        return arr[1]
    else 
        return arr
    end
end

-- 加密
function _M:encrypt(ret_content, key, vec)
	local pkcs7 = require("resty.nettle.padding.pkcs7")
	ret_content = pkcs7.pad(ret_content, 8)
	local des = require("resty.nettle.des")
	local ds, wk = des.new(key, "cbc", vec)
	return ds:encrypt(ret_content)
end

-- 解密
function _M:decrypt(bodydata, key, vec)

	local des = require("resty.nettle.des")
	local ds, wk = des.new(key, "cbc", vec)
    local my_bodydata = null
    if bodydata then
        my_bodydata = ds:decrypt(bodydata)
    end
	if my_bodydata then
		local pkcs7 = require("resty.nettle.padding.pkcs7")
		my_bodydata = pkcs7.unpad(my_bodydata, 8)
	end
	return my_bodydata
end

-- gzip压缩 str待压缩的为字符串
function _M:gzip(str)

    local compressed = ""

    if str == nil then
        return nil
    end

    local table_insert = table.insert
    local table_concat = table.concat
    local zlib = require('ffi-zlib')

    local one_counter = 0;

    local input = function(bufsize)
        if str ~= nil then
            one_counter = one_counter + 1;

            if one_counter == 1 then
                return str;
            else
                return nil
            end
        end
    end

    local output_table = {}
    local output = function(data)
        table_insert(output_table, data)
    end

    local strlen = string.len(str)

    local ok, err = zlib.deflateGzip(input, output, strlen)
    if not ok then
        print(err)
        return nil
    end

    compressed = table_concat(output_table, '')

    return compressed
end

--gzip解压缩 compressed_str 为压缩过的二进制字符串
function _M:gunzip(compressed_str)

    local table_insert = table.insert
    local table_concat = table.concat
    local zlib = require('ffi-zlib')
    local chunk = 16384

    local output_table = {}
    local output = function(data)
        table_insert(output_table, data)
    end

    local count = 0
    local input = function(bufsize)
        local start = count > 0 and bufsize*count or 1
        local data = compressed_str:sub(start, (bufsize*(count+1)-1) )
        count = count + 1
        return data
    end

    local ok, err = zlib.inflateGzip(input, output, chunk)
    if not ok then
        ngx.say(err)
    end
    local output_data = table_concat(output_table,'')

    return output_data
end

-- 把数据写到文件中
function _M:write_data_to_file(data, file_path)
	local io = require('io')
	file = io.open(file_path, 'w')
	assert(file)
	file:write(data)
	file:close()
end

-- 检查是否为JSON
function _M:is_json(data)
    if data == nil or data == ngx.null or data == '' then
        return false
    end
	data = string.gsub(data,"\"{","{")
	data = string.gsub(data,"}\"","}")
	data = string.gsub(data,"\\","")
	local ok, res_tab = pcall(cjson.decode, data)
	if not ok then
		return false
	end
	return true
end

-- 获取get参数
function _M:get_get()
    return ngx.req.get_uri_args()
end

-- 获取post参数
function _M:get_post()
    ngx.req.read_body()
    local post_args = ngx.req.get_post_args()
    local args = {}
    if post_args then
        for k, v in pairs(post_args) do
            args[k] = v
        end
    end
    return args
end

-- 获取body数据
function _M:get_body()
    ngx.req.read_body()
    return ngx.req.get_body_data()
end

-- 获取header参数
function _M:get_header()
    local headers_args = ngx.req.get_headers()
    local args = {}
    if headers_args then
        for k,v in pairs(headers_args) do
            args[k] = v
        end
    end
    return args
end

--去掉两端的空格
function _M:trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function _M:random_id()
    return ngx.md5(random.bytes(32))
end

--获取IP地址
function _M:get_ip()
    local headers = ngx.req.get_headers()
    local realip = headers["X_FORWARDED_FOR"]
    if type(realip) == "string" then
        local my_arr = self:string_to_array(realip)
        return self:array_first(my_arr)
    end
    if type(realip) == "table" then
        return realip[#realip]
    end
    return ngx.var.remote_addr
end

--检查数据表中是否存在指定的值
function _M:in_table(value, tbl)
    for k,v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

--检查数据表中是否存在指定的值
function _M:arr_key(tbl, key)
    for k, v in ipairs(tbl) do
        if k == key then
            return v
        end
    end
    return nil
end

function _M:prt(my_object)

	if type(my_object) == 'string' then
		ngx.say(my_object)
	else
		ngx.say(cjson.encode(my_object))
	end
	ngx.exit(200);
end

function _M:prts(my_string)
	ngx.say(my_string)
	ngx.exit(200);
end

function _M:is_empty(data)
    if data == null or data == ngx.null or data == '' or data == nil then
        return true
    end
    return false
end

function _M:file_exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

function _M:get_file_size(FileName)
    local size = 0
    pcall(
        function()
        local f = io.open(FileName, "r")
        if f == null then
            return 0
        end
        size = f:seek("end")
        f:close()
        end
    )
    return size
end

function _M:get_cdn_file_address(file_name)
    local local_file_path = public_params.root_path .. 'app/data/'..file_name
    if not self:file_exists(local_file_path) then
        return "http://"..self:get_cdn_host().."/"..file_name
    else
        local headers = ngx.req.get_headers()
        local host = headers['host']
        host = ngx.re.gsub(host, '9000', '9001')
        return "http://"..host.."/"..file_name
    end
end

function _M:download(host, file, local_file)
    require "socket"
	local f = io.open(local_file, "w+")
	local c = assert(socket.connect(host, 80));
	c:send("GET "..file.." HTTP/1.0\r\n\r\n")
	while true do
		local s,status,partial = c:receive(1024);
		f:write(s or partial)
		if status == "closed" then
			break
		end

	end
	c:close()
	f:close()
end

function _M:split(s, delim)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
      return
    end
   
    local start = 1
    local t = {}
    while true do
    local pos = string.find (s, delim, start, true) -- plain find
      if not pos then
       break
      end
   
      table.insert (t, string.sub (s, start, pos - 1))
      start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))
   
    return t
  end

  function _M:ToStringEx(value)
    if type(value)=='table' then
       return self:TableToStr(value)
    elseif type(value)=='string' then
        return "\""..value.."\""
    else
       return tostring(value)
    end
  end
  
  function _M:TableToStr(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..self:ToStringEx(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..self:ToStringEx(key)..":"..self:ToStringEx(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..self:TableToStr(getmetatable(key)).."*e".."="..self:ToStringEx(value)
                else
                    retstr = retstr..signal..key..":"..self:ToStringEx(value)
                end
            end
        end
        i = i+1
    end

     retstr = retstr.."}"
     return retstr
  end

  function _M:tableValueToStr(tab)
    if self:is_empty(tab) then 
        return {}
    end 
	local newTable = {}
    for key, val in pairs(tab) do
		if type(val) == 'table' then 
            newTable[key] = self:tableValueToStr(val)
        elseif type(val) == 'number' then
            newTable[key] = val .. ""
        elseif self:is_empty(val) then
            newTable[key] = ""
        else
            newTable[key] = val
        end
    end
    return newTable
  end


return _M