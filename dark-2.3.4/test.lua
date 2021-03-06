dark = require("dark")

local P = dark.pipeline()

-- see if the file exists
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

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

---------------- CREATION PATTERNS
P:basic()
--P:pattern([[ [#sport /^%u%u+$/ ] ]]) -- Mot tout en majuscule
--P:pattern([[ [#objectif #W /%l/* ( permettent | vous permet ) /(%l)|(%p-[%.]/* /%./ ] ]])

P:pattern([[
	[#permet
		(permet|permettent) de 
	]
]])

P:pattern([[
	[#action
		(developper | travailler | pratiquer | progresser | lutter)
	]
]])

P:pattern([[ [#objectif #permet #action ] ]])

-- P:lexicon("#unit", {"mètres", "centimètres", "kilomètres", "mètres carrés"})
-- P:pattern([[ [#mesure #d #unit ] ]])
-- P:pattern([[ [#monument  ( tour | pont ) #W] ]])
-- P:pattern([[ [#hauteur #monument .{0,3} "hauteur" .{0,3} #mesure] ]])

--local line = "La tour Eiffel a pour hauteur 324 mètres ."
--local seq = dark.sequence(line)

---------------- CREATION TAGS
local tags = {
	["#sport"] = "yellow",
	["#objectif"] = "red",
	--["#permet"] = "blue",
}

---------------- MAIN

-- TODO retirer les accents dans le texte


-- Open + Read file
local file = 'natation.txt'
--local file = 'volleyball.txt'
local lines = lines_from(file)

-- print all line numbers and their contents
for k,v in pairs(lines) do
	local seq = dark.sequence(v)
	P(seq)
	print('line[' .. k .. ']', seq:tostring(tags))
end

---------------- BASE DE DONNEES

-- local tags= {
-- 	["#mesure"] = "yellow",
-- 	["#monument"] = "blue",
-- 	["#hauteur"] = "red",
-- }


--print(tagstring(seq, "#monument"))
--print(tagstring(seq, "#toto"))

--- local db = {

-- 	["tour Eiffel"] = {
-- 		position = "Paris"
-- 	},
-- 	["Notre Dame de Paris"] = {
-- 		hauteur = "57m"
-- 	}
-- }

local db = {
	["natation"] = {
		objectif = "nul"
	},
	["volleyball"] = {
		objectif = "nul"
	}
}

-- if havetag(seq, "#hauteur") then
-- 	local monument = tagstringlink(seq,"#hauteur", "#monument")
-- 	local mesure = tagstringlink(seq, "#hauteur", "#mesure")
-- 	db[monument] = db[monument] or {}
-- 	db[monument].hauteur = mesure
-- end

print(serialize(db))

-- line = line:gsub("%p", "%0 ")
