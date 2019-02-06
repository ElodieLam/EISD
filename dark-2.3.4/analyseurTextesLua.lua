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

for line in io.lines("natation.txt") do
	line = line:gsub("’", "'")
	line = line:gsub("%p", " %0 ")
	local seq = dark.sequence(line)
	P(seq)
	print(seq:tostring(tags))
end


local db = {
	["natation"] = {
		objectif = {"Ces conditions vous permettent de developper vos capacités cardio - vasculaires et pulmonaires à votre rythme et de manière homogène .",
			"L ' absence de choc et de vibration vous permet de travailler vos muscles en douceur .",
			"La natation vous permet de travailler vos muscles de manière harmonieuse .",
			"En plus d ' être votre meilleure alliée pour la récupération après l ' effort , la natation vous permet aussi de progresser dans le cadre d ' un programme de rééducation ou d ' une reprise progressive du sport .",
			"Enceinte , en forme , en surpoids , en âge , en nage ? La natation vous permet de vous activer et de vous faire plaisir à votre rythme .",
			"Lorsque vous nagez , le principe d ' archimède vous permet de flotter à la surface de l ' eau . Ce qui vous soulage des deux tiers de votre poids . Cette quasi - apesanteur vous permet de pratiquer une activité physique sans fatiguer votre dos ou vos articulations .",
			">Quel que soit votre âge , votre poids ou vos antécédents de santé , la natation vous permet de vous faire plaisir et de vous dépenser à votre rythme .",
			},
		bienfaits = {"Une pratique régulière améliore vos capacités cardio et respiratoires .",
			"En plus d ' améliorer votre souffle et votre endurance , vous développez vos capacités cardiaques .",
			"L ' absence de choc et de vibration vous permet de travailler vos muscles en douceur .",
			"La natation vous permet de travailler vos muscles de manière harmonieuse .",
			"Les différentes nages demandent des efforts musculaires différents et si vous souhaitez travailler un groupe de muscles en particulier , vous pouvez utiliser des accessoires comme les plaquettes et / ou le pull - buoys .",
			"En natation c ' est simple , tout votre corps est dans l ' eau et vous vous musclez donc en totalité , sans stresser les articulations .",
			">Quel que soit votre âge , votre poids ou vos antécédents de santé , la natation vous permet de vous faire plaisir et de vous dépenser à votre rythme .",
			"Découvrez avec nous les origines de la natation en tant que sport , les règlements en piscine et en compétition , les bienfaits pour votre santé et l ' équipement dont vous avez besoin pour vous mettre à l ' eau .",
			"Si on trouve des traces de la nage humaine depuis l ' antiquité , la natation en tant que pratique sportive se développe en Angleterre dans les années 1830 .",
			"Si vous cherchez un sport bénéfique pour votre santé , vous êtes au bon endroit .",
			"Vous pouvez travailler votre musculature et votre cardio à votre rythme , sans forcer .",
			"Enfin , si vous voulez améliorer vos chronos et vos sensations , pensez au rasoir !",
			},
		contres = {"C ' est un sport qui favorise le tonus musculaire et la souplesse praticable même si vous avez des problèmes de circulation ou d ' articulation .",
			"C ' est un sport qui possède peu de contre - indications . La natation peut même être conseillée en cas de problèmes d ' asthme , de dos ou d ' articulations .",
			},
		installations = {"Découvrez avec nous les origines de la natation en tant que sport , les règlements en piscine et en compétition , les bienfaits pour votre santé et l ' équipement dont vous avez besoin pour vous mettre à l ' eau .",
		},
		equipement = {"Vous vous en doutez , pour vous mettre à l ' eau , il vous faut un maillot de bain .",
		},
		age = {"Fins connaisseurs ou grands débutants , si vous souhaitez en faire une pratique sportive , la nage peut vous apporter de nombreux avantages .",
			"Enceinte , en forme , en surpoids , en âge , en nage ? La natation vous permet de vous activer et de vous faire plaisir à votre rythme .",
			">Quel que soit votre âge , votre poids ou vos antécédents de santé , la natation vous permet de vous faire plaisir et de vous dépenser à votre rythme .",
			"L ' apprentissage de la natation commence par la découverte de l ' eau , donc dès le plus jeune âge ( 6 mois en France ) . Ensuite , l ' apprentissage des 4 nages codifiées de la natation course , elles , commencent vers 6 - 7 ans .",
			"Et si vous ne savez pas nager , sachez qu ' il existe des cours pour adultes . Après tout , on ne sait pas non plus skier ou pédaler avant d ' apprendre . Et comme pour monter à vélo , il n ' y a pas d ' âge pour se mettre à l ' eau . Il est même plus facile de mémoriser et synchroniser les gestes de la natation à l ' âge adulte .",
			},
	},
	["volleyball"] = {
		objectif = {"Ses principes de jeu et ses lieux de pratique , notamment sur le sable , vous permettent de vous amuser dès vos débuts .", 
			"Le volley vous permet de progresser de façon globale sur votre équilibre et votre coordination ",
			},
		bienfaits = {"Vous la développez au fur et à mesure de votre pratique sans perdre de vue le plaisir initial du volley - ball : gardez la balle en vie et renvoyez - la en seulement trois touches !", 
			"On ne vas pas vous mentir , vous allez tout de même faire des tours de terrain en début d ' échauffement . Mais vous améliorez votre endurance progressivement et vous gagnez en tonicité grâce à l ' alternance entre des phases de repos et des phases d ' effort courtes .",
			"Le volley - ball fait travailler votre coordination ." ,
			"Le basket , le volley et le hand demandent une bonne forme physique et font beaucoup travailler le système cardiovasculaire , la détente et la vélocité .", 
			"Le basket - ball développe l ' endurance et l ' adresse .",
			} ,
		contres = {"Les os : les fractures touchent surtout les poignets ou les avant - bras lors de chutes , mais aussi le tibia ou le pied lors de mauvaises réceptions en basket ou en volley . Dans ce sport , il n ' est pas rare de voir des fractures des doigts lors des contres . Le basketteur et le volleyeur peuvent aussi être victimes de fractures de fatigue du tibia , mais aussi des vertèbres .",
			"Les tendons : là encore , l ' entraînement intensif peut être à l ' origine de tendinites . Le tendon d ' Achille , le pied , la jambe et le genou sont les plus touchés dans les trois sports . Le bras utilisé pour lancer au hand , ou smasher et servir au volley , est également concerné par ce genre de problèmes , au niveau du coude et de l ' épaule .",
			"Même si ces sports peuvent se pratiquer hors du cadre d ' un club , sur des terrains municipaux par exemple , inscrivez - vous à un club pour bénéficier des conseils d ' un entraîneur . Celui - ci vous permettra d ' améliorer vos performances et votre tactique sans prendre de risques pour votre santé .",
			"Les problèmes observés le plus souvent au basket - ball sont les entorses du genou ou de la cheville , la maladie de Sever , les fractures de fatigue , les inflammations de la rotule et les ruptures du ligament croisé antérieur .",
			},
		installations = "",
		equipement = {"Evidemment , il vous faut aussi un ballon , qui n ' est pas le même pour le beach - volley et le volley - ball .",
			},
		age = {"En plus , il n ' y a pas d ' âge pour commencer : c ' est un sport sans contact qui mise sur vos réflexes .",
			"Le basket - ball , le hand - ball et le volley - ball peuvent être à l ' origine d ' accidents chez les enfants sportifs .",
			"Par rapport aux autres sports de ballon , il offre l ' avantage de pouvoir être pratiqué seul entre les entraînements . Un enfant peut pratiquer le basket - ball quelle que soit sa taille . Cependant , plus l ' âge avance et plus les tailles élevées sont privilégiées . Les enfants de parents de petite taille doivent être conscients très tôt de ce handicap pour ne pas être déçus .",
			"Ce sport est parfois conseillé aux enfants présentant des signes de scoliose . Chez ces enfants , une surveillance médicale régulière est indispensable .",
			"Les dimensions du terrain et de la balle ainsi que la hauteur du filet ont été adaptées à la pratique de ce sport par les enfants . Le volley s ' avère une bonne indication pour les enfants souffrant d ' une scoliose légère .",
			},
	}
}

print(serialize(db))