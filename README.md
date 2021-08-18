openresty 小框架
===============================
面向对象的设计，主要用来在工作中使用，轻量级的小框架

目录结构
-------------------
```
app                      			主应用程序文件夹
	api					API文件夹
		v1				版本号文件夹
			test.lua 		项目API示例
		base.lua 			所有API的基类
	configs
		environment
			development.lua 	开发环境配置
			testing.lua 		测试环境配置
			production.lua 		生产环境配置
		env.lua 			用来标识当前是哪一个环境，默认是开发环境
		env.online.lua 			线上环境的配置，通过 docker 部署到线上 会自动把此文件改名为 
		env.testing.lua 		测试环境的配置
		params.lua 			全局的参数
		rotue.lua 			API的路由白名单
	console					控制台脚本程序目录
		task.lua 			默认控制台脚本程序
	data 					第三方数据文件夹 
		ip2region.db 			查IP的归属地的数据库
	libs 					第三方库的文件夹
		...				第三方库
	models					所有数据模型的文件夹
		mysql 				mysql表的数据模型类
			base.lua 		所有数据模型类的基类
			api_log.lua 		API日志表
	tools					工具类文件夹
		fun.lua 			常用函数的类
		ip2region.lua 			查IP的归属地类
		mysql.lua 			连接mysql的数据库类
	main.lua 				主程序入口文件
conf 						nginx的配置文件夹
	nginx.conf 				nginx的本地配置文件
	nginx.online.conf 			nginx线上的配置文件
logs						nginx的日志文件夹
	error.log 				nginx的错误日志
.gitignore 					git的忽略文件或文件夹的配置
Dockerfile					Docker的配置文件
Readme.me 					框架说明
```

环境搭建说明
-------------------
```
安装Openresty环境：
    	MAC: http://openresty.org/cn/installation.html
	Ubuntu: http://openresty.org/cn/linux-packages.html
```

常见问题
-------------------
```
Q: 如何启动我的项目程序？
A: 到当前目录执行下面的命令 (Tommy本地开发环境)
    cd 到项目根目录
    执行：nginx -p `pwd`/ -c conf/nginx.conf
    测试网址GET：http://127.0.0.1:9000/v1/test

Q: 执行上面的启动脚本后为什么会在根目录多出一些文件夹?
A: 执行启动命令后，会多几个***_temp的文件夹，是nginx自动生成的，可以不用理会它

Q: 还什么注意事项吗？
A: 生产环境如果项目是部属于在Docker中，必须确保Dockerfile中配置的端口号和nginx中配置的端口号相同，否则运行不起来；部在docker中会自动把配置文件替换为线上的配置

```
