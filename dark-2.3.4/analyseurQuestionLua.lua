dark = require("dark")

local P = dark.pipeline()

P:basic()
P:lexicon("#sport", {"natation", "basket - ball", "yoga", "sport", "sports"})
P:lexicon("#bien", {"avantages", " bienfaits", "" })
P:lexicon("#maladie", {"asthme", "asthmatique", "enceinte", "os fragiles", "sclerose en plaques"})
P:lexicon("#but", {"but", "objectif"})
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

for line in io.lines("questions.txt") do
	line = line:gsub("’", "'")
	line = line:gsub("%p", " %0 ")
	local seq = dark.sequence(line)
	P(seq)
	print(seq:tostring(tags))
end
