dark = require("dark")

-- début de la partie base de données

local P = dark.pipeline()

function havetagTexte(seq, tag)
	return #seq[tag] ~= 0
end

function tagstringTexte(seq, tag, deb, fin)
	deb, fin = deb or 1, fin or #seq
	if not havetagTexte(seq, tag) then
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

function tagstringlinkTexte(seq, link, tag)
	if not havetagTexte(seq, link) then
		return
	end
	local pos = seq[link][1]
	local deb, fin = pos[1], pos[2]
	return tagstringTexte(seq, tag, deb, fin)
end 


P:basic()
P:lexicon("#bien", {"améliorer", "augmenter", "brûle", "améliore", "développez", "travailler", "musclez", "développe", "gagnez", "bénéfique", "permet de"})
P:lexicon("#motCleObj", {"muscles", "musculature", "capacités", "concentration", "souplesse", "augmenter", "développer", "lutter", "coordination", "équilibre", "endurance", "plaisir", "physiquement"})
P:pattern([[ [#T #w | #d | "," | "-" | ":" | "(" | ")" | "'"  ] ]])
P:pattern([[ [#sport /^%u[%u-]+$/ ] ]])
P:pattern([[ [#type  ( collectif )] ]])
P:pattern([[ [#objectif   ( vous permet | vise "à" | est un sport | est aussi un sport)  .*?   >(".") ] ]])
P:pattern([[ [#bienfaits  #bien #T*? #motCleObj .*? >("." | "!") ] ]])
P:pattern([[ [#contres ^#W .* ( "contre" "-" "indications" | "risques" | "fractures" | "problèmes") .*? "." ] ]])
P:pattern([[ [#installations ^#W .*  ("équipements" | "équipement")  .*? "." ] ]])
P:pattern([[ [#equipement  <("vous" "faut" )  .*? >(".") ] ]])
P:pattern([[ [#age ^#W .*  (#d "ans" | "débutants" | "pour" "adultes" | "âge" | "enfants")  .*? "." ] ]])

local tags = {
	["#sport"] = "yellow",
	["#objectif"] = "red",
	["#bienfaits"] = "green",
	["#contres"] = "blue",
	["#installations"] = "white",
	["#equipement"] = "cyan",
	["#age"] = "magenta",
}

local db_sport = {}

function sportindatabase(file)
	local sport
	local premiereLigne = true
	for line in io.lines(file) do
		line = line:gsub("’", "'")
		if(not premiereLigne) then 
			line = line:gsub("%p", " %0 ")
		end
		premiereLigne = false
		local seq = dark.sequence(line)
		P(seq)
		if havetagTexte(seq, "#sport") then
			sport = tagstringlinkTexte(seq,"#sport", "#sport")
			sport = string.lower(sport)
			db_sport[sport] = db_sport[sport] or {}
			db_sport[sport].nom = sport
			db_sport[sport].objectif = {}
			db_sport[sport].bienfait = {}
			db_sport[sport].contre = {}
			db_sport[sport].age = {}
			db_sport[sport].type = { "individuel" }

		end
		if havetagTexte(seq, "#objectif") then
			local objectif = tagstringlinkTexte(seq,"#objectif","#objectif")
			table.insert(db_sport[sport]["objectif"], objectif)	
		end
		if havetagTexte(seq, "#contres") then
			local contre = tagstringlinkTexte(seq,"#contres","#contres")
			table.insert(db_sport[sport]["contre"], contre)	
		end
		if havetagTexte(seq, "#age") then
			local age = tagstringlinkTexte(seq,"#age","#age")
			table.insert(db_sport[sport]["age"], age)	
		end
		if havetagTexte(seq, "#type") then
			db_sport[sport].type = {} 
			local type = tagstringlinkTexte(seq,"#type","#type")
			table.insert(db_sport[sport]["type"], type)	
		end
		if havetagTexte(seq, "#bienfaits") then
			local bienfait = tagstringlinkTexte(seq,"#bienfaits","#bienfaits")
			table.insert(db_sport[sport]["bienfait"], bienfait)
		end
	end
end

local file = io.popen('find sport/*.txt')
for fic in file:lines() do
	sportindatabase(fic)
end

-- fin de la partie base de données

local P = dark.pipeline()
local t = {}

listObjectifs = {"equilibre", "coordination", "endurance", "tonicité", "détente", "vélocité", "réflexes", "concentration", "perte de poids", "poids"}
listGenerations = {"jeune", "personne agée", "agé", "adulte"}
listMaladies = {"asthme", "asthmatique", "enceinte", "os fragiles", "sclerose en plaques"}
listAffirmations = {"oui", "bien sur", "d'accord", "evidemment", "très bien", "c'est note", "super", "exactement", "top", "genial", "voulais", "veux", "bien", "merci"}
listInfirmations = { "non", "ne", "pas", "jamais"}

P:basic()
P:lexicon("#listeObjectifs", listObjectifs)
P:lexicon("#listeGenerations", listGenerations)
P:lexicon("#listesMaladies",listMaladies)
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
	["#listesMaladies"] = "green",

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

-- permet de recuperer le compteur ayant ete le plus incrementes parmi tous les sports
function max(tableau)
	max = tableau[1]
	for i=1, #tableau do
		if(max<tableau[i]) then 
			max=tableau[i]
		end	
	end
	return max
end


------------------------------------------Dialogue
 --print(serialize(db_sport))
io.write('\nS: Bonjour, je peux aussi vous aider à trouver le sport qui vous correspond le mieux. Quel est votre objectif? \n \n')

--------------------- Partie 1 (entonoir)
-----On repete la meme question tant que l'utilisateur 
local objCompris=false
local ageCompris=false
local contreIndCompris=false
local questCompris=false


----Compteurs permettant de definir l'affinite de chaque sport
local compteurNatation = 0 
local compteurVoley = 0 
local compteurBoxe = 0
local compteurVtt = 0
local compteurBasket = 0


local compteurObjectif = 0
local compteurContreInd = 0



function incrementeCompteur(sport_choisi)
	if string.find(sport_choisi, "boxe" ) then
		compteurBoxe= compteurBoxe + 1
	end

	if string.find(sport_choisi, "natation" ) then
		compteurNatation= compteurNatation +1
	end
	if string.find(sport_choisi, "voleyball" ) then
		compteurVoley= compteurVoley + 1
	end
	if string.find(sport_choisi, "vtt" ) then
		compteurVtt= compteurVtt + 1
	end
	if string.find(sport_choisi, "yoga" ) then
		compteurYoga= compteurYoga + 1
	end
	
end

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
    compteurObjectif = compteurObjectif + 1
		objCompris = true;
		local t = getElementInDb("listeObjectifs")
		io.write("\nS: Très bien, vous voulez travailler votre ")
		for i=1, #t do 
			io.write(t[i])
			
		-- INCREMENTATION DES COMPTEURS --  1ERE PARTIE

			for k,v in pairs(db_sport) do
				if(db_sport[k]["objectif"] ~= nil) then
                    for key, value in pairs(db_sport[k]["objectif"]) do
                        if string.find(value, t[i]) then
                            table.insert(db["sport"], db_sport[k]["nom"])
                            local sport_choisi = (serialize(db_sport[k]["nom"]))
							-- On incremente un compteur pour l'ensmeble des sports  
							incrementeCompteur(sport_choisi)
							-- print("Question 1 : ")
							-- print("Compteur Natation : ", compteurNatation)
							-- print("Compteur Basket : ", compteurBasket)
							-- print("Compteur Vtt : ", compteurVtt)
							-- print("Compteur VoleyBall : ", compteurVoley)	
							-- print("Compteur Boxe: ", compteurBoxe)	

							--print("")
						end
                    end
                end
                compteurObjectif = #t 
			end
			if (t[i+1] ~= nil) then
				io.write(" et ")
			end
		end
		if #db["sport"] > 1 then
			io.write(". Je peux vous proposer plusieurs sports! Etes vous plutot jeune ou âgé ? \n \n")
		else
			io.write(". \nJe peux vous proposer le "..db["sport"][1].." \n\n")
			ageCompris = true
			contreIndCompris = true
			questCompris = true
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

		-- INCREMENTATION DES COMPTEURS --  2EME PARTIE
			for k,v in pairs(db_sport) do
				if(db_sport[k]["age"] ~= nil) then
					for key, value in pairs(db_sport[k]["age"]) do
						if string.find(value, t[i]) then
                           -- table.insert(db["sport"], db_sport[k]["nom"])
							local sport_choisi = (serialize(db_sport[k]["nom"]))
							-- On incremente un compteur pour l'ensemble des sports 
							incrementeCompteur(sport_choisi)
							-- Tests pour la question 2 :
							-- print("Question 2 : ")
							-- print("Compteur Natation : ", compteurNatation)
							-- print("Compteur Basket : ", compteurBasket)
							-- print("Compteur Vtt : ", compteurVtt)
							-- print("Compteur VoleyBall : ", compteurVoley)	
							-- print("Compteur Boxe: ", compteurBoxe)	
						end
						end
                    end
                end
                compteurObjectif = #t 
			end

		io.write(". Avez-vous des problèmes de santé ou des contre-indications ? \n \n")
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
	if (havetag(seq, "#listesMaladies")) then 
		contreIndCompris = true;
		local t = getElementInDb("listesMaladies")
		io.write("\nS: D'accord. \n")

		for i=1, #t do 
			
		-- INCREMENTATION DES COMPTEURS --  3EME PARTIE
			for k,v in pairs(db_sport) do
				if(db_sport[k]["contre"] ~= nil) then
					for key, value in pairs(db_sport[k]["contre"]) do
						if string.find(value, t[i]) then
                           -- table.insert(db["sport"], db_sport[k]["nom"])
							local sport_choisi = (serialize(db_sport[k]["nom"]))
							-- On incremente un compteur pour l'ensemble des sports 
							incrementeCompteur(sport_choisi)
							-- Tests pour la question 3 :
							-- print("Question 3 : ")
							-- print("Compteur Natation : ", compteurNatation)
							-- print("Compteur Basket : ", compteurBasket)
							-- print("Compteur Vtt : ", compteurVtt)
							-- print("Compteur VoleyBall : ", compteurVoley)	
							-- print("Compteur Boxe: ", compteurBoxe)	
						end
						end
                    end
                end
                compteurObjectif = #t 
			end

		end
			-- Resultat propose par le chatbot selon les compteurs implementes
		local tableauCompteur={compteurBasket, compteurBoxe, compteurNatation, compteurVoley, compteurVtt, compteurYoga}
		local tableauSport = {"le basket", "la boxe", "la natation", "le voley", "le vtt", "le yoga"}

		local sportResult = tableauSport[max(tableauCompteur)]

		io.write("J’ai trouvé le sport qui pourrait vous plaire! Je ne peux que vous conseiller de commencer ", sportResult, "! Qu'en pensez vous ? \n \n")		

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
--	print(seq:tostring(tags))

	-- Récupération du contenu des tags de la question
	tagsToDb(seq, db)
	
	if(havetag(seq, "#listeAffirmations")) then
		questCompris = true;
		io.write("\nS: Super, je suis heureux d'avoir pu vous aider ! \n \n")
	else
		 io.write("\nS: Je suis en plein apprentissage, je prend en compte vos remarques! A bientot \n \n") 
	end
end

