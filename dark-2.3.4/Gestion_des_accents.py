# -*- coding: utf-8 -*-
 
class Extraction_Accent:
    def __init__(self, fichier_source, fichier_destination, decalage):
        """ cryptage et décryptage """
        self.fich_s = fichier_source
        self.fich_d = fichier_destination
        self.decalage = decalage
 
    def supprime_accent(self, ligne):
        """ supprime les accents du texte source """
        accent = ['é', 'è', 'ê', 'à', 'ù', 'û', 'ç', 'ô', 'î', 'ï', 'â']
        sans_accent = ['e', 'e', 'e', 'a', 'u', 'u', 'c', 'o', 'i', 'i', 'a']
        i = 0
        while i < len(accent):
            ligne = ligne.replace(accent[i], sans_accent[i])
            i += 1
        return ligne
 
    def texte_sans_accent(self):
        """ crée un nouveau fichier txt sans accent """
        # ouvrir le fichier source
        fs = open(self.fich_s, 'r')
        # crée le fichier destination
        fd = open(self.fich_d, 'w')
        # lire chaque ligne
        while 1:
            ligne = fs.readline() 
            if ligne == "":
                break
            out = self.supprime_accent(ligne)
            fd.write(out)
        # fermeture des fichiers
        fd.close()
        fs.close()
 
if __name__ == '__main__':
    app = Extraction_Accent('natation.txt', 'natation_sans_accents.txt', 1)
   # app = Extraction_Accent('voleyball.txt', 'voleyballball_sans_accents.txt', 1)
    app.texte_sans_accent()