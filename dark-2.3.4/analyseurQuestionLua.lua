dark = require("dark")

local P = dark.pipeline()
local t = {}

listObjectifs = {"equilibre", "coordination", "endurance", "tonicité", "détente", "vélocité", "réflexes", "concentration", "perte de poids", "poids"}
listGenerations = {"jeune", "personne agée", "agé", "adulte"}
listMaladies = {"asthme", "asthmatique", "enceinte", "os fragiles", "sclerose en plaques"}
listAffirmations = {"oui", "bien sur", "d'accord", "evidemment", "très bien", "c'est note"}
listInfirmations = { "non", "ne", "pas", "jamais"}

P:basic()
P:lexicon("#listeObjectifs", listObjectifs)
P:lexicon("#listeGenerations", listGenerations)
P:lexicon("#listeMaladies",listMaladies)
P:lexicon("#listeObjectifs", listObjectifs)
P:lexicon("#listeAffirmations", listAffirmations)
P:lexicon("#listeInfirmations", listInfirmations)

P:lexicon("#volonte", {"j ' aimerai", "je voudrais"})
P:lexicon("#action", {"faire", "pratiquer"})
P:lexicon("#nomSport", {"natation", "basket - ball", "yoga", "volley - ball", "vtt"})

P:lexicon("#but", {"but", "objectif"})
P:lexicon("#bien", {"avantages", "bienfaits"})
P:lexicon("#pasbien", {"desavantages", "contres - indications"})
P:lexicon("#risque", {"risques", "risque", "dangers", "danger", "dangereux", "à risques", "risqué"})

P:lexicon("#question", {"convenir", "pratiquer", "conseilles", "conseiller", "comment", "faire pour", "quels sont", "quels", "y a t - il", "est - il", "possede - t - il", "ai - je"})
P:lexicon("#precision", {"collectif", "extérieur", "collectifs", "sans contact", "individuel"})


P:pattern([[ [#Qbienfaits #question "les" #bien] ]]) -- quels sont les bienfaits
P:pattern([[ [#Qsport #volonte #action] ]]) -- j'aimerai faire 
P:pattern([[ [#Qcontres #question "les" #pasbien] ]]) -- quels sont les contres-indications
P:pattern([[ [#Qrisques #question .* #risque] ]]) -- quels sont les risques / .. est-il dangereux / y a t-il un risque

P:pattern([[ [#sport #nomSport] ]])
P:pattern([[ [#precisionSport #Qsport .* #precision] ]]) -- j'aimerai faire un sport collectif

P:pattern([[ [#equipement #question .* ("équipements" | "équipement" | "besoin")] ]]) -- de quoi ai-je besoin / quels sont les équipements nécéssaires pour..
P:pattern([[ [#age #d "ans"] ]])



local tags = {
	["#listeObjectifs"] = "blue",
	["#listeGenerations"] = "yellow",
	["#listeMaladies"] = "green",

	["#Qsport"] = "blue",
	["#sport"] = "red",
	["#Qbienfaits"] = "magenta",
	["#Qcontres"] = "cyan",
	["#Qrisques"] = "blue",
	["#precisionSport"] = "red",
	["#precision"] = "yellow",
	["#equipement"] = "cyan",

	["#age"] = "cyan"
}


function havetag(seq, tag)
	return #seq[tag] ~= 0
end


function tagstring(seq, tag, deb, fin)
	deb, fin = deb or 1, fin or #seq
	if not havetag(seq, tag) then
		return
	end


	local res = {}
	for idx, pos in ipairs(seq[tag]) do
		local d, f = pos[1], pos[2]
		if d >= deb and f <= fin then
			local tmp = {}
			for i = deb, fin do
				tmp[#tmp + 1] = seq[i].token
			end
			res[#res + 1] = table.concat(tmp, " ")
		end
	end
	return res
end




function tagstringlink(seq, link, tag)
	if not havetag(seq, link) then
		return
	end
	local t = {}
	local seqs = seq[link]
	for i=1, #seqs do
		local pos = seqs[i]
		local deb, fin = pos[1], pos[2]
		t[#t + 1] = tagstring(seq, tag, deb, fin)
	end
	return t
end  
  

-- Returns the Levenshtein distance between the two given strings
function string.levenshtein(str1, str2)
	local len1 = string.len(str1)
	local len2 = string.len(str2)
	local matrix = {}
	local cost = 0
	
        -- quick cut-offs to save time
	if (len1 == 0) then
		return len2
	elseif (len2 == 0) then
		return len1
	elseif (str1 == str2) then
		return 0
	end
	
        -- initialise the base matrix values
	for i = 0, len1, 1 do
		matrix[i] = {}
		matrix[i][0] = i
	end
	for j = 0, len2, 1 do
		matrix[0][j] = j
	end
	
        -- actual Levenshtein algorithm
	for i = 1, len1, 1 do
		for j = 1, len2, 1 do
			if (str1:byte(i) == str2:byte(j)) then
				cost = 0
			else
				cost = 1
			end
			
			matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
		end
	end
	
        -- return the last value - this is the Levenshtein distance
	return matrix[len1][len2]
end



function tagsToDb(seq, db)
	if havetag(seq, "#sports") then
		sport = tagstringlink(seq,"#sports", "#sports")
		for i=1, #sport do
			if sport[i][1] ~= nil then
				table.insert(db["sport"], sport[i][1])
			end
		end
	end
	if havetag(seq, "#objectif") then
		objectif = tagstringlink(seq,"#objectif", "#objectif")
		for i=1, #objectif do
			if objectif[i][1] ~= nil then
				table.insert(db["objectif"], objectif[i][1])
			end
		end
	end
	if havetag(seq, "#bienfaits") then
		bienfaits = tagstringlink(seq,"#bienfaits", "#bienfaits")
		for i=1, #bienfaits do
			if bienfaits[i][1] ~= nil then
				table.insert(db["bienfaits"], bienfaits[i][1])
			end
		end
	end
	if havetag(seq, "#contres") then
		contres = tagstringlink(seq,"#contres", "#contres")
		for i=1, #contres do
			if contres[i][1] ~= nil then
				table.insert(db["contres"], contres[i][1])
			end
		end
	end
	if havetag(seq, "#butQ") then
		butQ = tagstringlink(seq,"#butQ", "#butQ")
		for i=1, #butQ do
			if butQ[i][1] ~= nil then
				table.insert(db["butQ"], butQ[i][1])
			end
		end
	end
	if havetag(seq, "#precisionQ") then
		precisionQ = tagstringlink(seq,"#precisionQ", "#precisionQ")
		for i=1, #precisionQ do
			if precisionQ[i][1] ~= nil then
				table.insert(db["precisionQ"], precisionQ[i][1])
			end
		end
	end
	if havetag(seq, "#equipement") then
		equipement = tagstringlink(seq,"#equipement", "#equipement")
		for i=1, #equipement do
			if equipement[i][1] ~= nil then
				table.insert(db["equipement"], equipement[i][1])
			end
		end
	end
	if havetag(seq, "#age") then
		age = tagstringlink(seq,"#age", "#age")
		for i=1, #age do
			if age[i][1] ~= nil then
				table.insert(db["age"], age[i][1])
			end
		end
	end
	if havetag(seq, "#listeObjectifs") then
		listeObjectifs = tagstringlink(seq,"#listeObjectifs", "#listeObjectifs")
		for i=1, #listeObjectifs do
			if listeObjectifs[i][1] ~= nil then
				table.insert(db["listeObjectifs"], listeObjectifs[i][1])
			end
		end
	end
	if havetag(seq, "#listeGenerations") then
		listeGenerations = tagstringlink(seq,"#listeGenerations", "#listeGenerations")
		for i=1, #listeGenerations do
			if listeGenerations[i][1] ~= nil then
				table.insert(db["listeGenerations"], listeGenerations[i][1])
			end
		end
	end
	if havetag(seq, "#listesMaladies") then
		listesMaladies = tagstringlink(seq,"#listesMaladies", "#listesMaladies")
		for i=1, #listesMaladies do
			if listesMaladies[i][1] ~= nil then
				table.insert(db["listesMaladies"], listesMaladies[i][1])
			end
		end
	end
end


function stringToTable(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

function tableToString(table)
	local s = ""
	for index,value in pairs(table) do
		s = s .. ' ' .. table[index]
	end
	return s
end


function correctLine(list, line, lineInArray)

	local word_corrige = ""
	local array_corrige = lineInArray

	--print("line in correctLine: " , line)

	for j=1, #list do
		local index = 1
		for mot in line:gmatch("%w+") do
			 if (string.levenshtein(mot, list[j])==1) then
				  --motProcheObjectif = true
				  word_corrige = word_corrige .. '' .. list[j]
				  array_corrige[index] = word_corrige
				  word_corrige = ""
			 end
			 index = index + 1
		 end
	end
	return array_corrige
end


local db = {
	listeObjectifs = {},
	listeGenerations = {},
	listesMaladies = {},

	sport = {}, -- le nom du sport

	Qsport = {}, -- si question sur un sport
	precisionSport = {}, -- si question sur un type de sport
	precision = {}, -- le type de sport

	Qbienfaits = {}, -- si question sur les bienfaits
	Qcontres = {}, -- si question sur les contres-indications
	Qrisques = {}, -- si question sur les risques

	equipement = {}, -- si question sur l'équipement
	age = {}, -- age

}


function getElementInDb(tagName)
	for k, v in pairs(db) do
		if (k == tagName) then
			return v
		end
	end
end

------------------------------------------Dialogue
 
io.write('\nS: Bonjour, je peux aussi vous aider à trouver le sport qui vous correspond le mieux. Quel est votre objectif? \n \n')

--------------------- Partie 1 (entonoir)
-----On repete la meme question tant que l'utilisateur 
local objCompris=false
local ageCompris=false
local contreIndCompris=false
local questCompris=false

--QUESTION 1 : Objectifs
while(objCompris==false) do
	io.write('U: ')
	local line = io.read() 

	local lineInArray = stringToTable(line)
	local word_corrige = ""
	local line_corrige = ""

	-- Distance de Levenshtein avec les objectifs 
	lineInArray = correctLine(listObjectifs, line, lineInArray)

	-- Pose des tags
	line_corrige = tableToString(lineInArray)
	line_corrige = line_corrige:gsub("’", "'")
	line_corrige = line_corrige:gsub("%p", " %0 ")
	local seq = dark.sequence(line_corrige)
	P(seq)
	--print(seq:tostring(tags))

	-- Enregistre la réponse dans la db
	tagsToDb(seq, db)

	-- Réponse du système
	if (havetag(seq, "#listeObjectifs")) then 
		objCompris = true;
		local t = getElementInDb("listeObjectifs")
		io.write("\nS: Très bien, vous voulez travailler votre ")
		for i=1, #t do 
			io.write(t[i])
			if (t[i+1] ~= nil) then
				io.write(" et ")
			end
		end
		io.write(". Je peux vous proposer plusieurs sports! Etes vous plutot jeune ou âgé ? \n \n")
	end
	else
		io.write("\nS: Je n'ai pas bien compris votre réponse pouriez vous reformuler s'il vous plait? \n \n") 
	end
end

--QUESTION 2 : Age
while(ageCompris==false) do
	io.write('U: ')
	local line = io.read() 
	
	local lineInArray = stringToTable(line)
	local word_corrige = ""
	local line_corrige = ""
	
	-- Distance de Levenshtein avec l'age 
	lineInArray = correctLine(listGenerations, line, lineInArray)
	
	-- Pose des tags
	line_corrige = tableToString(lineInArray)
	line_corrige = line_corrige:gsub("’", "'")
	line_corrige = line_corrige:gsub("%p", " %0 ")
	local seq = dark.sequence(line_corrige)
	P(seq)
	--print(seq:tostring(tags))
	
	-- Enregistre la réponse dans la db
	tagsToDb(seq, db)

	-- Réponse du système
	if (havetag(seq, "#listeGenerations")) then 
		ageCompris = true;
		local t = getElementInDb("listeGenerations")
		io.write("\nS: OK! Super, vous etes ")
		for i=1, #t do 
			io.write(t[i])
		end
		io.write(". Avez-vous des problèmes de santé ou des contre-indications ? \n \n")
	end
	else
		io.write("\nS: Je n'ai pas bien compris votre réponse pouriez vous reformuler s'il vous plait? \n \n")	 
	end
end

--QUESTION 3 : Contre-indications

while(contreIndCompris==false) do
	io.write('U: ')
	local line = io.read() 

	local lineInArray = stringToTable(line)
	local word_corrige = ""
	local line_corrige = ""

	-- Distance de Levenshtein avec les contre-indications 
	lineInArray = correctLine(listMaladies, line, lineInArray)

	-- Pose des tags
	line_corrige = tableToString(lineInArray)
	line_corrige = line_corrige:gsub("’", "'")
	line_corrige = line_corrige:gsub("%p", " %0 ")
	local seq = dark.sequence(line_corrige)
	P(seq)
	--print(seq:tostring(tags))

	-- Enregistre la réponse dans la db
	tagsToDb(seq, db)

	-- Réponse du système
	if (havetag(seq, "#listeMaladies")) then 
		contreIndCompris = true;
		local t = getElementInDb("listeMaladies")
		io.write("\nS: D'accord. \n")
		for i=1, #t do 
			--io.write(t[i])
		end
		io.write("J’ai trouvé quelques sports qui peuvent vous correspondre. Je vous propose [TODO]. \nVoulez-vous plus d'informations sur ce sport ?  \n \n")
	end
	else
		io.write("\nS: Je n'ai pas bien compris votre réponse pouriez vous reformuler s'il vous plait? \n \n")
	end
end



-- Question 5 : Question Ouverte
while (questCompris == false) do
	io.write('U: ')
	local line = io.read() 

	if line == nil then break end
	if line == "bye" then break end

	-- Distance de Levenshtein 
	local lineInArray = stringToTable(line)
	local line_corrige = ""
	lineInArray = correctLine(listObjectifs, line, lineInArray)
	lineInArray = correctLine(listGenerations, line, lineInArray)
	lineInArray = correctLine(listMaladies, line, lineInArray)
	lineInArray = correctLine(listAffirmations, line, lineInArray)

	-- Pose des tags
	line_corrige = tableToString(lineInArray)
	line_corrige = line_corrige:gsub("’", "'")
	line_corrige = line_corrige:gsub("%p", " %0 ")
	local seq = dark.sequence(line_corrige)
	P(seq)
	print(seq:tostring(tags))

	-- Récupération du contenu des tags de la question
	tagsToDb(seq, db)
	
	if(havetag(seq, "#listeAffirmations")) then
		questCompris = true;
		io.write("\nS: OK je recherche des informations et je reviens vers vous ! \n \n")
	end
	else
		 io.write("\nS: J'espère avoir pu vous aider! A bientot \n \n") 
	end

	-- TODO recherche de la réponse

	-- TODO print réponse

	-- Print DB
	--print(serialize(db))
end


