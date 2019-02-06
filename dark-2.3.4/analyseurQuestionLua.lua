dark = require("dark")

local P = dark.pipeline()

P:basic()
P:lexicon("#sport", {"natation", "basket - ball", "yoga", "sport", "sports"})
P:lexicon("#bien", {"avantages"})
P:lexicon("#maladie", {"asthme", "asthmatique"})
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

for line in io.lines("questions.txt") do
	line = line:gsub("’", "'")
	line = line:gsub("%p", " %0 ")
	local seq = dark.sequence(line)
	P(seq)
	print(seq:tostring(tags))
end