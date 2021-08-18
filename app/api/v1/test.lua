--[[
测试的API接口
]]
local os = require("os")

local _M = {} 

_M.p = nil

function _M:new() 
	
	self.p = require('api.base'):new()
	
	local super_mt = getmetatable(self.p) 

	setmetatable(_M, super_mt) 

	self.p.super = setmetatable({}, super_mt) 

	return setmetatable(self.p, { __index = _M }) 
end 

function _M:run()

	local this_cache_key = 'to_do_sql_list'
    local to_do_sql_list_str = self.fun:get_cache(this_cache_key)
	self.fun:prt(to_do_sql_list_str)


    --local text = 'y7AfOqdEx/8rBDTmDLRYhmKABDWFfOd82krTi5nWDD5zV9xWr+o760eJL3DjAnFXvEy5Xk7QXL59Ym7hof1kZ671zC4L9bmtOo/Upj6VCNTgwgwiCDBC5+4OeDW5hExR5zM7u+EVmJhm7ShgrLffHYJp8os3+z1Q'
    --local key = '3f448f79'
    --local iv = 'ac0tt5e7'
	--
    ----text = self.fun:encrypt(text, key, iv)
    ----text = ngx.encode_base64(text)
	--
	--text = ngx.decode_base64(text)
	--text = self.fun:decrypt(text, key, iv)
	--text = self.fun:gunzip(text)
	--
    --self.fun:prt(text)


	-- local fun = require('tools.fun')
	-- local http = require('resty.http')

	-- -- 这是请求的JSON字符串
	-- local content='{"whichsim":1,"offerids":"","tnumber":"","guess":0,"gaid":"c109ff90-883f-47ad-9b14-69da4a2d4d38","abmm":"","lastdidtime":"","packagename":"com.mufc.beauty","installer":"null","mainc":"xdy","country":"IT","subc":"7b44b7c9ce","who":"f1","plmn":"22201","prop":"Unknown,HSPAP,Wind,22288,it"}'

	-- -- 加密
	-- local encrypt_data = self:api_encrypt(content)

	-- self.fun:prt(encrypt_data)

	-- local api_url = 'http://******/v1/go'

	-- local data =  {
	-- 	method = "POST",
	-- 	body = encrypt_data
	-- }
	-- local httpc = http.new()
	-- local res = httpc:request_uri(api_url, data)

	-- if not res or res.status ~= 200 then
	-- 	fun:prt('哪里出错了哦') --中断，显示错误提示
	-- end

	-- -- 第一布需要先解压，得到解压后的二进制数据
	-- local response_data = self:api_decrypt(res.body)

	-- fun:prt(response_data) --中断，把结果打印出来



	--[[ 获取GET参数
	local arg = ngx.req.get_uri_args()
	for k,v in ipairs(arg) do
		ngx.say("[GET ] key:", k, " v:", v)
		ngx.say("<br>")
	end

	--[[
	-- 获取POST参数
	ngx.req.read_body()		--解析 body 参数之前一定要先读取body
	local arg = ngx.req.get_post_args()
	for k,v in pairs(arg) do
		ngx.say("[POST] key:", k, " Vaule:", v)
		ngx.say("<br>")
	end

	-- 获取header参数
	local headers = ngx.req.get_headers()
	for k,v in pairs(headers) do
		ngx.say("[HEADER] key:", k, " Vaule:", v)
		ngx.say("<br>")
	end

	-- 获取body信息
	ngx.req.read_body()
	local data = ngx.req.get_body_data()
	ngx.say(data)


	ngx.say('<br>test')

	--]]



	--[[
	local function close_db(db)  
	    if not db then  
	        return  
	    end  
	    db:close()  
	end  
	  
	local mysql = require("resty.mysql")  
	 
	local db, err = mysql:new()  
	if not db then  
	    ngx.say("new mysql error : ", err)  
	    return  
	end  

	db:set_timeout(1000)  
	  
	local props = {  
	    host = "127.0.0.1",  
	    port = 3306,  
	    database = "test",  
	    user = "root",  
	    password = ""  
	}  
	  
	local res, err, errno, sqlstate = db:connect(props)  
	  
	if not res then  
	   ngx.say("connect to mysql error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
	   return close_db(db)  
	end  
	 
	local drop_table_sql = "drop table if exists test"  
	res, err, errno, sqlstate = db:query(drop_table_sql)  
	if not res then  
	   ngx.say("drop table error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
	   return close_db(db)  
	end  
	  

	local create_table_sql = "create table test(id int primary key auto_increment, ch varchar(100))"  
	res, err, errno, sqlstate = db:query(create_table_sql)  
	if not res then  
	   ngx.say("create table error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
	   return close_db(db)  
	end  
	  

	local insert_sql = "insert into test (ch) values('hello')"  
	res, err, errno, sqlstate = db:query(insert_sql)  
	if not res then  
	   ngx.say("insert error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
	   return close_db(db)  
	end  
	  
	res, err, errno, sqlstate = db:query(insert_sql)  
	  
	ngx.say("insert rows : ", res.affected_rows, " , id : ", res.insert_id, "<br/>")  
	  
	 
	local update_sql = "update test set ch = 'hello2' where id =" .. res.insert_id  
	res, err, errno, sqlstate = db:query(update_sql)  
	if not res then  
	   ngx.say("update error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
	   return close_db(db)  
	end  
	  
	ngx.say("update rows : ", res.affected_rows, "<br/>")  
	  
	local select_sql = "select id, ch from test"  
	res, err, errno, sqlstate = db:query(select_sql)  
	if not res then  
	   ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
	   return close_db(db)  
	end  
	  
	  
	for i, row in ipairs(res) do  
	   for name, value in pairs(row) do  
	     ngx.say("select row ", i, " : ", name, " = ", value, "<br/>")  
	   end  
	end  
	  
	ngx.say("<br/>")  
	  
	local ch_param = ngx.req.get_uri_args()["ch"] or ''  
	 
	local query_sql = "select id, ch from test where ch = " .. ngx.quote_sql_str(ch_param)  
	res, err, errno, sqlstate = db:query(query_sql)  
	if not res then  
	   ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
	   return close_db(db)  
	end  
	  
	for i, row in ipairs(res) do  
	   for name, value in pairs(row) do  
	     ngx.say("select row ", i, " : ", name, " = ", value, "<br/>")  
	   end  
	end  
	  

	local delete_sql = "delete from test"  
	res, err, errno, sqlstate = db:query(delete_sql)  
	if not res then  
	   ngx.say("delete error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
	   return close_db(db)  
	end  
	  
	ngx.say("delete rows : ", res.affected_rows, "<br/>")  
	  
	  
	close_db(db)  

	--]]

	--[[
	local account = require('models.account')

	local a = account:new()
	a:deposit(200)

	local b = account:new()
	b:deposit(550)

	ngx.say(a.balance, "<br/>")  
	ngx.say(b.balance, "<br/>")  
	--]]

	--local config = require 'configs.env'

	--ngx.say(config.db.host)



	--[[
	local db = require 'tools.mysql'
	sql = 'SELECT * FROM `test` WHERE id=1'

	--执行sql语句
	local data = db:get_data(sql);

	--判断查询结果
	if(data) then
	  ngx.say("select row ".. data.id .." ".. data.ch .."<br/>")  
	else
	  ngx.say("Not found data")
	  --ngx.say(ret)
	end

	--]]

	--[[
	sql = 'SELECT * FROM `test` WHERE id>20'

	--执行sql语句
	local data_list = db:get_data_list(sql);
	--判断查询结果
	if(data_list) then
	  for i, row in ipairs(data_list) do  
	    ngx.say("select row ".. row.id .." ".. row.ch .."<br/>")  
	  end  
	else
	  ngx.say("No found data")
	end


	sql = 'INSERT INTO `test` SET `ch1`="abc1"'
	result = db:execute(sql)
	ngx.say(result)

	sql = 'UPDATE `test` SET `ch`="abc1"'
	result = db:execute(sql)
	ngx.say(result)

	sql = 'DELETE FROM `test` WHERE `id`>10'
	result = db:execute(sql)
	ngx.say(result)

	--]]

	--local str = 'Hello World!'

    --self.fun:prt(str)

	--local str = '{"whichsim":0,"operator":"TH-AIS","plmn":"52001","country":"TH","prop":"","gaid":"","installer":"","mainc":"","subc":""}'
    --
    --str = self:api_encrypt(str)

    --self.fun:write_data_to_file(str, '/Users/Tommy/123456.bin')

    -- self.fun:prt('222')

end

return _M
