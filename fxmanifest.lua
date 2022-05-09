game 'gta5'
fx_version 'cerulean'
lua54 'yes'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'client/main.lua'
}


ui_page 'html/index.html'
files {
	'html/**',
}

dependency 'es_extended'
