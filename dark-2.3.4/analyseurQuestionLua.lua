dark = require("dark")

local P = dark.pipeline()

P:basic()
P:lexicon("#sport", {"natation", "basket - ball", "yoga", "sport", "sports"})
P:lexicon("#bien", {"avantages"})
P:lexicon("#maladie", {"asthme", "asthmatique", "sclérose en plaque"})
P:lexicon("#but", {"but", "objectif"})
P:lexicon("#question", {"convenir", "pratiquer", "conseilles", "conseiller"})
P:lexicon("#precision", {"collectif", "extérieur", "collectifs"})

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


io.write('S: Bonjour, avez-vous des questions concernant un sport? Je peux aussi vous aider à trouver le sport qui vous correspond le mieux.\n')

while true do
    io.write('U: ')
	--print(type(io.lines('natation.txt')))
    local word = io.read()

	word = word:gsub("’", "'")
	word = word:gsub("%p", " %0 ")
	local seq = dark.sequence(word)
	P(seq)
	print(seq:tostring(tags))
	if havetag(seq, "#sports") then
		print("oui sports")
 	--local monument = tagstringlink(seq,"#hauteur", "#monument")
	--local mesure = tagstringlink(seq, "#hauteur", "#mesure")
		db[sports] = db[sports] or {}
		print(serialize(db))
 	--db[monument].hauteur = mesure
 end




    if line == nil then break end
    if line == "bye" then break end
	

    --analyse de la question


    --recherche de la réponse
    local reponse = "..."

    --print réponse
    io.write('S: ', reponse, '!\n')

    io.write("S: Avez-vous une autre question? \n")
end 

