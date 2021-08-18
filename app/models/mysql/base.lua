local _M = {} 

_M.version = 1

_M.table_name = 'test'

_M.db = require('tools.mysql')

function _M:new() 
	return setmetatable({}, { __index = _M }) 
end 

function _M:get_data_by_id(id)

	id = self.db:quote_str(id)

	sql = "SELECT * FROM `"..self.table_name.."` WHERE `id`="..id
	
	return self.db:get_data(sql)
end



return _M