dark = require("dark")

local P = dark.pipeline()

io.write('S: Bonjour, avez-vous des questions concernant un sport? Je peux aussi vous aider à trouver le sport qui vous correspond le mieux.\n')

while true do
    io.write('U: ')
    local line = io.read()

    if line == nil then break end
    if line == "bye" then break end

    --analyse de la question


    --recherche de la réponse
    local reponse = "..."

    --print réponse
    io.write('S: ', reponse, '!\n')

    io.write("S: Avez-vous une autre question? \n")
  end