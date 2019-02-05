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
		return
	end
	local pos = seq[link][1]
	local deb, fin = pos[1], pos[2]
	return tagstring(seq, tag, deb, fin)
end 

P:basic()
P:pattern([[ [#sport /^%u%u+$/ ] ]])
P:pattern([[ [#objectif #W /%l/* ( permettent | vous permet ) /(%l)|(%p-[%.]/* /%./ ] ]])
-- P:lexicon("#unit", {"mètres", "centimètres", "kilomètres", "mètres carrés"})
-- P:pattern([[ [#mesure #d #unit ] ]])
-- P:pattern([[ [#monument  ( tour | pont ) #W] ]])
-- P:pattern([[ [#hauteur #monument .{0,3} "hauteur" .{0,3} #mesure] ]])

--local line = "La tour Eiffel a pour hauteur 324 mètres ."
--local seq = dark.sequence(line)
local tags = {
	["#sport"] = "yellow",
	["#objectif"] = "red",
}

for line in io.lines("natation.txt") do
	line = line:gsub("%p", " %0 ")
	local seq = dark.sequence(line)
	P(seq)
	print(seq:tostring(tags))
end



-- local tags= {
-- 	["#mesure"] = "yellow",
-- 	["#monument"] = "blue",
-- 	["#hauteur"] = "red",
-- }


--print(tagstring(seq, "#monument"))
--print(tagstring(seq, "#toto"))

-- local db = {

-- 	["tour Eiffel"] = {
-- 		position = "Paris"
-- 	},
-- 	["Notre Dame de Paris"] = {
-- 		hauteur = "57m"
-- 	}
-- }

-- if havetag(seq, "#hauteur") then
-- 	local monument = tagstringlink(seq,"#hauteur", "#monument")
-- 	local mesure = tagstringlink(seq, "#hauteur", "#mesure")
-- 	db[monument] = db[monument] or {}
-- 	db[monument].hauteur = mesure
-- end

--print(serialize(db))

-- line = line:gsub("%p", "%0 ")
