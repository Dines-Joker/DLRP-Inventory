server_scripts {
  '@async/async.lua',
  '@mysql-async/lib/MySQL.lua',
  '@es_extended/locale.lua',
  'files/inventory_sv.lua'
}

client_scripts {
  '@es_extended/locale.lua',
  'files/inventory_cl.lua',
}

ui_page 'interface/index.html'
files {
  'interface/index.html',
  'interface/style.css',
  'interface/app.js',
  'interface/*.png',
}




