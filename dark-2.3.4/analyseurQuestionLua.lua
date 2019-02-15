dark = require("dark")

local P = dark.pipeline()

P:basic()
P:lexicon("#sport", {"natation", "basket - ball", "yoga", "sport", "sports"})
P:lexicon("#infoSport", {"j'aimerai pratiquer", "j'aimerai faire", "je voudrais faire", "j'ai envie de", "je veux"})
P:lexicon("#bien", {"avantages", " bienfaits", "" })
P:lexicon("#maladie", {"asthme", "asthmatique", "enceinte", "os fragiles", "sclerose en plaques"})
P:lexicon("#but", {"but", "objectif"})
--ajout 15/02
P:lexicon("#listeObjectifs", {"equilibre", "coordination", "endurance", "tonicité", "détente", "vélocité", "réflexes", "concentration", "perte de poids", "poids"})

P:lexicon("#listeGenerations", {"jeune", "personne agée", "agé", "jeune"})

P:lexicon("#listesMaladies", {"asthme", "asthmatique", "enceinte", "os fragiles", "sclerose en plaques"})




P:lexicon("#question", {"convenir", "pratiquer", "conseilles", "conseiller", "comment", "faire pour", "quels sont", "quels", "Y a t-il"})
P:lexicon("#precision", {"collectif", "extérieur", "collectifs", "sans contact", "individuel"})
P:lexicon("#resutatSport", {"equilibre", "coordination", "endurance", "tonicité", "détente", "vélocité", "réflexes", "concentration"})
P:lexicon("#risques", {"danger", "dangereux", "à risques"})

P:pattern([[ [#sports #sport] ]])
P:pattern([[ [#objectif #but] ]])
P:pattern([[ [#bienfaits #bien] ]])
P:pattern([[ [#contres #maladie] ]])
P:pattern([[ [#precisionQ #precision] ]])
P:pattern([[ [#butQ #question] ]])
P:pattern([[ [#equipement   ("vous" "faut" | "faut" | "besoin" | "équipement")] ]])
P:pattern([[ [#age ("âge" | "jeune" | "adulte" | #d "ans")] ]])




local tags = {
	["#sports"] = "yellow",
	["#objectif"] = "red",
	["#bienfaits"] = "green",
	["#contres"] = "blue",
    ["#butQ"] = "white",
    ["#precisionQ"] = "black",
	["#equipement"] = "cyan",
	["#age"] = "magenta",
}


function havetag(seq, tag)
	return #seq[tag] ~= 0
end


function tagstring(seq, tag, deb, fin)
	deb, fin = deb or 1, fin or #seq
	if not havetag(seq, tag) then
		return
	end

	for idx, pos in ipairs(seq[tag]) do
		local d, f = pos[1], pos[2]
		if d >= deb and f <= fin then
			local res = {}
			for i = deb, fin do
				res[#res + 1] = seq[i].token
			end
			return table.concat(res, " ")
		end
	end
end



function tagstringlink(seq, link, tag)
	if not havetag(seq, link) then
		return
	end
	local pos = seq[link][1]
	local deb, fin = pos[1], pos[2]
	return tagstring(seq, tag, deb, fin)
end  	

local db = {

	["sports"] = { 
	}
}

---------------------Dialogue
io.write('S: Bonjour, Je peux aussi vous aider à trouver le sport qui vous correspond le mieux. Quel est votre objectif? \n')

while true do
  io.write('U: ')
	--print(type(io.lines('natation.txt')))
  local word = io.read()
  word = word:gsub("’", "'")
	word = word:gsub("%p", " %0 ")
	local seq = dark.sequence(word)
	P(seq)
	--print(seq:tostring(tags))

  	if havetag(seq, "#listeObjectifs") then
    	io.write("S: Très bien, je peux vous proposer plusieurs sports! Etes vous plutot jeune ou âgé ? \n")

    else if havetag(seq, "#listeGenerations") then
    	io.write("S: OK! Super ! Avez-vous des problèmes de santé ou des contre-indications ? \n")

   	else if havetag(seq, "#listesMaladies") then
    	io.write("S: J’ai trouvé quelques sports qui peuvent vous correspondre. Je vous propose SPORTA, SPORTB ou encore SPORTC. Vous plus de détails sur ces sports ?  \n")


	  db[sports] = db[sports] or {}
	  print(serialize(db))
 	  --db[monument].hauteur = mesure
  end

  if line == nil then break end
  if line == "bye" then break end

  --TODO analyse de la question
  
  --TODO recherche de la réponse
  local reponse = "..."

  --print réponse
  io.write('S: ', reponse, '!\n')
  io.write("S: Avez-vous une autre question? \n")

end 
end
end
