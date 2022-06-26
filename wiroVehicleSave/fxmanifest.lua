fx_version "adamant" 

game "gta5"

client_script {
    'config.lua',
    'client.lua'
}

server_script "@mysql-async/lib/MySQL.lua"

server_script {
    'config.lua',
    'server.lua'
}