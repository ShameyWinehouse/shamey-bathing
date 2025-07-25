fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 "yes"

client_scripts {
	"client/structs.js",
	"client/*.lua",
}

server_scripts {
	"server/*.lua",
	"@oxmysql/lib/MySQL.lua",
}

shared_scripts {
	"config.lua",
	"shared/*.lua",
	"shared/**/*.lua",
	"@jo_libs/init.lua",
}

files {
	"ui/*",
  }
ui_page "ui/hud.html"

-- dependencies {
-- 	"rainbow-core",
-- 	"vorp_inputs",
-- }


dependencies {
	'vorp_core',
	'vorp_utils',
	'rainbow-core',
}


jo_libs {
	'notification',
}


author 'Shamey Winehouse'
description 'License: GPL-3.0-only'