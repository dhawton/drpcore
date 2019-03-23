resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'DRP'

version '0.0.99'

ui_page('ui/index.html')

files {
    "ui/css/app.css",
    "ui/css/bootstrap.min.css",
    "ui/js/bootstrap.bundle.min.js",
    "ui/js/app.js",
    'ui/js/wrapper.js',
    "ui/img/logo.png",
    "ui/img/drp.png",
    "ui/index.html"
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'shared/async.lua',
  "server/common.lua",
  "server/functions.lua",
  "server/user.lua",
  'server/main.lua',
  'server/sync.lua'
}

client_scripts {
  'locale.lua',
  'locales/en.lua',
  'shared/async.lua',
  'client/functions.lua',
  'client/main.lua',
  'client/wrapper.lua',
  'client/sync.lua',
  'shared/weapons.lua',
}

exports {
	'getSharedObject'
}

server_exports {
	'getSharedObject'
}

