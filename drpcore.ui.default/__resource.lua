resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'DRP Menu Default'

version '1.0.3'

client_scripts {
	'@drpcore/client/wrapper.lua',
	'client.lua'
}

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/css/app.css',
	'html/js/mustache.min.js',
	'html/js/app.js',
	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf',
	'html/fonts/Roboto-Bold.ttf',
	'html/fonts/Roboto-Regular.ttf',
	'html/img/cursor.png',
	'html/img/keys/enter.png',
	'html/img/keys/return.png',
}
