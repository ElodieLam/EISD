dark = require("dark")

local P = dark.pipeline()

P:basic()
P:lexicon("#bien", {"améliorer", "améliore", "santé", "développez", "travailler", "musclez", "développe", "gagnez"})
P:pattern([[ [#sport /^%u[%u-]+$/ ] ]])
P:pattern([[ [#objectif ^#W .* ( vous permettent | vous permet ) .*? "." ] ]])
P:pattern([[ [#bienfaits ^#W .* #bien .*? ("." | "!") ] ]])
P:pattern([[ [#contres ^#W .* ( "contre" "-" "indications" | "risques" | "fractures" | "problèmes") .*? "." ] ]])
P:pattern([[ [#installations ^#W .*  ("équipements" | "équipement")  .*? "." ] ]])
P:pattern([[ [#equipement ^#W .*  ("vous" "faut" )  .*? "." ] ]])
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

for line in io.lines("volleyball.txt") do
	line = line:gsub("’", "'")
	line = line:gsub("%p", " %0 ")
	local seq = dark.sequence(line)
	P(seq)
	print(seq:tostring(tags))
end