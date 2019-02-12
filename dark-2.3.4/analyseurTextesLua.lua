dark = require("dark")

local P = dark.pipeline()

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
		print("pas de tag")
		return
	end
	local pos = seq[link][1]
	local deb, fin = pos[1], pos[2]
	return tagstring(seq, tag, deb, fin)
end 

function mysplit(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

P:basic()
P:lexicon("#bien", {"améliorer", "améliore", "développez", "travailler", "musclez", "développe", "gagnez", "bénéfique"})
P:pattern([[ [#sport /^%u[%u-]+$/ ] ]])
--P:pattern([[ [#objectif  ( vous permettent | vous permet ) .*?  >(".") ] ]])
P:pattern([[ [#objectif   "vous" "permet"  .*?  >(".") ] ]])
P:pattern([[ [#bienfaits  #bien .*? >("." | "!") ] ]])
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

local db = {
	["yoga"] = {
		type = "individuel",
		objectif =  {

		},
		bienfait =  {

		},
	}
}

function sportindatabase(file)
	local sport
	for line in io.lines(file) do
		line = line:gsub("’", "'")
		line = line:gsub("%p", " %0 ")
		local seq = dark.sequence(line)
		P(seq)
		print(seq:tostring(tags))
		if havetag(seq, "#sport") then
			sport = tagstringlink(seq,"#sport", "#sport")
			print(sport)
			db[sport] = db[sport] or {}
			db[sport].objectif = {}
			db[sport].bienfait = {}

		end
		if havetag(seq, "#objectif") then
			local objectif = tagstringlink(seq,"#objectif","#objectif")
			table.insert(db[sport]["objectif"], objectif)	
		end
		if havetag(seq, "#bienfaits") then
			local bienfait = tagstringlink(seq,"#bienfaits","#bienfaits")
			local split = mysplit(bienfait, " ")
			print(serialize(split))
			local idx = 1
			local verbe = split[1]
			table.remove(split, 1)
			--local bien 
			--for k,v in ipairs(split) do
			--	if idx == 1 then
			--		print(v[idx])
			--		verbe = v[idx]
			--	else
					--print(v[idx])
			--		table.concat(bien, v[idx])
					
			--	end
			--	idx = idx + 1
			--end
			local bien  = table.concat(split, " ")
			print(serialize(verbe))
			print(bien)
			table.insert(db[sport]["bienfait"], bienfait)
		end
	end
end

sportindatabase("natation.txt")

print(serialize(db))
