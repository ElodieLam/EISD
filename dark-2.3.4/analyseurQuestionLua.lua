dark = require("dark")

local P = dark.pipeline()
local t = {}

listObjectifs = {"equilibre", "coordination", "endurance", "tonicité", "détente", "vélocité", "réflexes", "concentration", "perte de poids", "poids"}
listGenerations = {"jeune", "18 ans", "personne agée", "agé", "jeune"}
listMaladies = {"asthme", "asthmatique", "enceinte", "os fragiles", "sclerose en plaques"}

P:basic()
P:lexicon("#sport", {"natation", "basket - ball", "yoga", "sport", "sports"})
P:lexicon("#infoSport", {"j'aimerai pratiquer", "j'aimerai faire", "je voudrais faire", "j'ai envie de", "je veux"})
P:lexicon("#bien", {"avantages", " bienfaits", "" })
P:lexicon("#maladie", {"asthme", "asthmatique", "enceinte", "os fragiles", "sclerose en plaques"})
P:lexicon("#but", {"but", "objectif"})

P:lexicon("#listeObjectifs", listObjectifs)

P:lexicon("#listeGenerations", listGenerations)

P:lexicon("#listesMaladies",listMaladies)




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
    ["#butQ"] = "yellow",
    ["#precisionQ"] = "black",
	["#equipement"] = "cyan",
	["#age"] = "magenta",
	["#listeObjectifs"] = "red",
	["#listeGenerations"] = "yellow",
	["#listesMaladies"] = "green",
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

function isLenvenstein(list, word)
	for j=1, list do
		for mot in word:gmatch("%w+") do
			 if (string.levenshtein(mot, list[j])==1) then
	 -- 	-- On conserve la valeur reelle du mot pour l'utiliser dans la base de donnees
	 -- 	 table.insert(t, list[j]) 
				  motProcheObjectif = true
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
	local line_corrige = ""
	local array_corrige = lineInArray

	print("line in correctLine: " , line)

	for j=1, #list do
		local index = 1
		for mot in line:gmatch("%w+") do
			 if (string.levenshtein(mot, list[j])==1) then
				  motProcheObjectif = true
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
	sport = {},
	objectif = {},
	bienfaits = {},
	contres = {},
	butQ = {},
	precisionQ = {},
	equipement = {},
	age = {},
	listeObjectifs = {},
	listeGenerations = {},
	listesMaladies = {}
}




---------------------Dialogue
 
io.write('\nS: Bonjour, je peux aussi vous aider à trouver le sport qui vous correspond le mieux. Quel est votre objectif? \n \n')
local motProcheObjectif=false
local motProcheGeneration=false
local motProcheMaladie=false


while true do
	io.write('U: ')
	local line = io.read() 

	local lineInArray = stringToTable(line)
	local word_corrige = ""
	local line_corrige = ""

	if line == nil then break end
	if line == "bye" then break end

	-- Distance de Levenshtein avec les objectifs 
	lineInArray = correctLine(listObjectifs, line, lineInArray)
	-- avec l'age 
	lineInArray = correctLine(listGenerations, line, lineInArray)
	-- avec les contre-indications 
	lineInArray = correctLine(listMaladies, line, lineInArray)
	print("array: ", serialize(lineInArray))

	-- Pose des tags
	line_corrige = tableToString(lineInArray)
	line_corrige = line_corrige:gsub("’", "'")
	line_corrige = line_corrige:gsub("%p", " %0 ")
	local seq = dark.sequence(line_corrige)
	P(seq)

	-- Dialogue partie 1
	tagLeven = tagstringlink(seq, "#listeObjectifs", "#listeObjectifs" )
  	if (havetag(seq, "#listeObjectifs") or (motProcheObjectif==true)) then
    	io.write("\nS: Très bien, je peux vous proposer plusieurs sports! Etes vous plutot jeune ou âgé ? \n \n")
    	motProcheObjectif=false
   	elseif havetag(seq, "#listeGenerations") or (motProcheGeneration==true) then
     	io.write("\nS: OK! Super, Vous etes jeune donc! Avez-vous des problèmes de santé ou des contre-indications ? \n \n")
     	motProcheGeneration=false
   	elseif havetag(seq, "#listesMaladies")  or (motProcheMaladie==true) then
     	io.write("\nS: J’ai trouvé quelques sports qui peuvent vous correspondre.\n Je vous propose la natation.\n Voulez vous plus d'informations sur ce sport ?  \n \n")
	 	motProcheMaladie=false  
	end

	-- Dialogue partie 2
	-- Récupération du contenu des tags de la question
	print(seq:tostring(tags))
	tagsToDb(seq, db)
	
	-- TODO recherche de la réponse


	-- TODO print réponse

	-- Print DB
	print(serialize(db))
end


