


#<######################################################################################>
# R studio----
#<######################################################################################>

# 4 Fenster


# Scripts und Projekte






#<######################################################################################>
# Basic R concepts---- 
#<######################################################################################>


#> Verschiedendes----
#===============================================================>

#1) Strukturierung mit Ueberschriften

#2) Kommentare und Anmerkungen

#3) Case-sensitivity und Genauigkeit

#4) Fehlermeldungen vs. Warnungen






#> Zuweisungen und Objekte----
#===============================================================>

a <- 1+2
a + 5


# Beispiel lineare Regression
linreg <- lm(mpg ~ hp + wt, data=mtcars) 

summary(linreg) #Anzeige der Koeffizienten
anova(linreg)   #Anzeige der ANOVA-Tabelle



#> Klassen von Datenobjekten----
#===============================================================>

# Klassen: matrix, factor, list, dataframe


# Modi (u.a.): Numeric, character, logical (true/false)


# Anzeige mit str(.) und mode(.) und class(.)
str(mtcars)


# Beispiel: mtcars-dataframe 





#> Funktionen----
#===============================================================>

# Body und 3 Arten von Argumenten (essentielle, default, optionale)


# Hilfe mit ?
?lm()




#> Pakete----
#<===============================================================>

# Was ist das?


# Download/Installation vs. Aktivierung
install.packages("lavaan") 

# Aktivierung / Ladung (Kann, muss aber nicht in Anfuehrungszeichen stehen')
library(lavaan) 


# Konflikte zwischen Paketen, die die selben Funktionsnamen haben (und Loesung mit Paket::Funktion)
dplyr::select(var1, var2)


# Typische Fehlermeldung: "could not find function "read_csv2": Paket ist nicht geladen




#> Indizieren ("Die Plage")----
#<===============================================================>

wt #Geht nicht, da in dem Objekt mtcars
mtcars$wt #Geht


cor(cbind(mtcars$mpg, mtcars$wt, mtcars$hp), use="pair")

# Alternative ist, mtcars zu "attachen":

attach(mtcars)
cor(cbind(mpg, wt, hp), use="pair")

# Problem: Wenn 2 Datensätze mit gleichen Variablen attached werden
mtcars2 <- mtcars #Kopie
attach(mtcars2) #R zeigt bereits das Problem


# Lösung: "Detachen"
attach(mtcars)
cor(cbind(mpg, wt, hp), use="pair")
detach(mtcars)

# -> Zu aufwaendig. Mit dem tidyverse-Ansatz braucht man all dies nicht




#<######################################################################################>
# Das tidyverse----
#<######################################################################################>


# Online Buch von Hadley Wickham: https://r4ds.had.co.nz/index.html

# Packages:
# -tibble
# -tidyr
# -dplyr  
# -purrr   
# -stringr 
# -readr   
# -forcats 
# -ggplot2


install.packages("tidyverse")
library(tidyverse)




#> Dataframes vs. Tibbles----
#<===============================================================>

library(ISLR) # Paket zum James et al. Buch
data(Hitters)

Hitters # Als dataframe

as_tibble(Hitters) # Als Tibble (!)




# Einlesen von Daten 
#<===============================================================>

#> BASE R
read.csv2("C:\\Users\\steinmetzh\\Dropbox\\Lehre\\Methoden\\SEM\\Corona data.csv", header=TRUE)  # (Semikola als Trennzeichen)
# Achtung: Pfade ben?tigen Doppel-Backslashes!


#> Tidyverse (readr-package):
read_csv2("C:\\Users\\steinmetzh\\Dropbox\\Lehre\\Methoden\\SEM\\Corona data.csv") #Tidyverse, Semikola


#> Einlesen von Excelfiles
library(readxl)
read_excel("Beispiel Relational Database.xlsx",
                          sheet = "departments")




#> Pipelines und der "pipe operator"----
#<===============================================================>

# Base R beruht auf dem Verschachteln von Funktionen in anderen Funktionen.

# Beispiel einer Sequenz von Aufgaben
c(1,4,5,2,5)

sqrt(c(1,4,5,2,5))

round(sqrt(c(1,4,5,2,5)), 2)

mean(round(sqrt(c(1,4,5,2,5)), 2))
#-> Nicht elegant und schlecht lesbar



# Stattdessen: Pipeline
c(1,4,5,2,5) %>%   # Füge werde zu einem Vektor zusammen..."und dann"
  sqrt() %>%       # Ziehe die Wurzel..."und dann"
  round(., 2) %>%  # Runde ..."und dann"
  mean()           # Berechne das Mittel

  
  
  

#> dplyr's Fab 5----
#<######################################################################################>

#Überblick
# select(): Variablen auswählen
# filter(): In einer Variable Fälle herein- oder herausfiltern
# summarise(): Deskriptive Stats berchnen / über Fälle aggregieren
# mutate(): Variablen verändern / neue Variablen berechnen
# group_by(): Nachfolgende Operationen gruppieren




# Select
#<===============================================================>

# Auswahl aufgrund der Variablenummer, Name oder Bereich

mtcars %>% 
  select(1,3,5)  # Drei Variablen auswaehlen (die 1., 3., und 5.)

mtcars %>% 
  select(1:5, 8) #Die ersten 5 und die 8. variable auswaehlen

mtcars %>% 
  select(mpg, hp)  # Die Variablen mit ihren Namen ansprechen

mtcars %>% 
  select(mpg:hp, vs) # Den Bereich der Variablen von mpg BIS hp UND vs auswaehlen


# Sortieren mit select / Nutzen von "everything()"
mtcars %>% 
  select(vs, disp, cyl, mpg, everything()) 
# Nimm die Variablen vs etc. in dieser Reihenfolge nachvorne und lasse den Rest (everything() wo er ist'


# Negativ-Auswahl mit "-" 
mtcars %>% 
  select(-mpg, -vs) # Nimm alles AUSSER mpg und vs

mtcars %>% 
  select(-(mpg:disp)) # Nimm alles AUSSER mpg BIS disp


# Variablen umbenennen innerhalb select()
mtcars %>% 
  select(mpg, zyl = cyl) # Wähle mpg und cyl, aber benenne cyl um'





# Filter
#<===============================================================>

# Pruefung von Bedingungen: Logische Symbole: ==, >=, <=, !=, |, &

mtcars %>% 
  filter(cyl == 6 ) #Filtere alle F?lle, dei cyl==6 sind (Achtung: "==" nehmen)

#Und-Verknüpfungen mit "&"
mtcars %>% 
  filter(cyl == 6 & hp== 110)


# Oder-Verknüpfungen mit "|"
mtcars %>% 
  filter(cyl == 6 | hp== 110)


# Positive filter vs. negative Filter
mtcars %>% 
  filter(cyl != 6 ) # Das Symbol != bedeutet "ist nicht"


# Zahlen vs. Worte filtern
X = c("Hallo", "Hallo", "Schwimmbad", "Gym", "Haengematte")
X <- as_tibble(X)
X %>% 
    filter(value == "Hallo")


# Einen Bereich von Werten filtern ("%in% c(5:10)"). Anm. Die Werte m?ssen vorkommen

# Intuitiv:
mtcars %>% 
  filter(cyl == "6" | cyl=="8")
#--> Ist aber aufwaendig bei vielen Werten, die man moechte. Besser ist dabei  
# folgender command:
  
mtcars %>% 
  filter(cyl %in% c(6, 7, 8))

# Werte kleiner als ... filtern
mtcars %>% 
  filter(disp < 200)


# Zufällige Anzahl von Faellen filtern mit slice_sample(n=10) oder ..(prop=.2)
mtcars %>% 
  slice_sample(n=10) # 10 Fälle per Zufall auswählen

mtcars %>% 
  slice_sample(prop = .50) # 50% per Zufall wählen


# Fehlende Werte (missing data) rein - oder rausfiltern mit is.na()
Hitters %>% 
  as_tibble() %>%    # weils schöner ist ;)
  filter(is.na(Salary))   #Missings anzeigen/filtern
  
 
Hitters %>% 
  filter(!is.na(Salary)) # Missings in Salary eliminieren

na.omit(Hitters)   #Alle missings entfernen




# Deskription: Count & summarise
#<===============================================================>

# Count: Einfach
mtcars %>% count(vs)

# Kreuztabelle
mtcars %>% count(vs, am)


# Zählen der einzigartigen Werte 
mtcars %>% 
  summarise(unique_values = n_distinct(vs))


# Summarise und wichtigste Sub-Funktionen mean(), med()sd(), min(), max()
Hitters %>% ...

# Hilfreich: Benennungen
Hitters %>% ...

# Gesamtsummary: psych::describe(.)  
psych::describe(Hitters) 

# Nutzen von "as_tibble": 
psych::describe(mtcars) %>% 
  as_tibble() %>% 
  select(-mad, -range, -skew, -kurtosis, -se, -vars) #Z.B. Auswahl wichtiger Statistiken









# Mutate
#<===============================================================>

# Corona-Datensatz laden/importieren (Achtung: File muss im selben Ordner sein wie
# Das R-Projektfile)
cor_data <- read_csv2("Corona data.csv")



# Grundprinzip: In mutate kann jedwelche mathematische Funktion angewendet werden:

# (ich wandle mtcars erst einmal in ein tibble)
mtcars <- mtcars %>%  
  as_tibble(rownames = "car_type")


mtcars %>% 
  mutate(x = cyl+5) #"Lege die Variable X an und die soll eine Funktion der Variable cyl sein + 5"

mtcars %>% 
  mutate(cyl_sqrt = sqrt(cyl)) #Dto. Lege die Variable cyl_sqrt an als Wurzel von cyl



# Praktisches Beispiel Zentrierung und Standardisierung von Variablen
#  Hintergund:
#     X_s = (X - mean(X))  ---> Zentrierung
#     X_s = (X - mean(X)) / sd(X) ---> Standardisierung

 mtcars %>% 
  mutate(disp_s = disp - mean(disp)  )  #Zentrierung 
 
 mtcars %>% 
   mutate(disp_s = (disp - mean(disp)) / sd(disp) )  #Standardisierung (Klammern beachten!)
  


# Modi umwandeln mit as.numeric, as.character, as.factor
mtcars   #Check: Welchen Modus hat die Variable vs?

mtcars %>%
  as_tibble() %>% 
  mutate(vs_fact = as.factor(vs))

# Achtung: Bei allen mutate Befehlen muss f�r eine dauerhafte Speicherung der neuen Variable 
# die pipeline einem Objekt zugewiesen werden (alter Datensatz oder Kopie):

mtcars %>% 
  mutate(x = cyl+5)  # Keine Speicherung/nur temporaer vs.

mtcars <- mtcars %>% 
  mutate(x = cyl+5)  #--> Speicherung. 
#Tipp: Die Zuweisung erst am Ende vornehmen, wenn die pipeline gecheckt wurde und funktioniert 



# Summen-/Mittelwert ("composite") bilden
cor_data %>%
  rowwise() %>%
  mutate(worries_mean = mean(c(worries_trait_01,
                              worries_trait_02,
                              worries_trait_03)
                             )
         ) %>% 
  ungroup() 

# Bedingtes Berechnen: hier am Beispiel einer Rekodierung der Geschlechtsvariable
cor_data <- cor_data %>% 
  mutate(sex_new = case_when(sex == 1 ~ 0,  
                             sex == 2 ~ 1,
                             TRUE ~ sex)) %>% 
  mutate(sex_new = as.factor(sex_new))  #In die pipeline kommt eine 2. Berechnung "as.factor"--hier mit 
                                        #separatem mutate-Befehl

#Zweite Version derselben pipeline (diesmal mit einem einzigen mutate-Befehl)
cor_data %>% 
  mutate(sex_new = case_when(sex == 1 ~ 0,
                             sex == 2 ~ 1,
                             TRUE ~ sex),
        sex_new = as.factor(sex_new)  ) 


# Wann ist es sinnvoll eine dummy variable als numeric umzudefinieren?
cor_data %>% 
  select(aff_worry_o, aff_worry_v01, sex_new) %>% 
  mutate(sex_new = as.numeric(sex_new)) %>% 
  cor(., use="pair")


# Rekodieren von Variablen
data <- data %>% 
  mutate(x_rec = recode(x, "0"=6,"1"=5,"2"=4,"3"=3,"4"=2, "5"=1, "6"=0 ))


# Kategorien eines Faktors zu einer Restkategorie zusammenfassen
starwars %>% 
  count(eye_color, sort=TRUE)

starwars2 <- starwars %>%
  mutate(eye_color = fct_lump(eye_color, n = 8))  #n = Anzahl der gewuenschten Kategorien

starwars2 %>% 
  count(eye_color, sort = TRUE)






# group_by
#<===============================================================>

# Sinnvoll fuer summarise()

cor_data %>% 
  group_by(sex_new) %>% 
  summarise(mean_worries = mean(aff_worry_o))


# Kreuzung von Variablen 
cor_data %>% 
  group_by(sex_new) %>% 
  count(aff_worry_o) %>% 
  spread(sex_new, n) #Formiert die Tabelle von einer Listenansicht in eine Kreuztabellen-Ansicht

#Zweite Version des desselben Ziels: Hier ohne group_by; stattdessen erfolgt die Kreuzung in count()
cor_data %>% 
  count(aff_worry_o, sex_new) %>% 
  spread(sex_new, n)
  
#4-Felder Mittelwertstabellen
mtcars %>% 
  group_by(vs,am) %>% 
  summarise(mean_disp = mean(disp)) %>% 
  spread(vs, mean_disp) #Kreuzung: Diesmal ist der angelegte Mittelwerte der Zelleninhalt--nicht "n"


  
  
# Hilfreich für gruppenspezifische Berechnungen (z.B. Prozentwerte in Haeufigkeitstabellen)
mtcars %>% 
  group_by(vs) %>% 
  count(carb) %>% 
  mutate(perc = n / sum(n))




#> ggplot----
#<######################################################################################>


# -- Nice intro: https://www.youtube.com/watch?v=HPJn1CMvtmI
# -- Das layers-Konzept: 
#     1) data
#     2) mapping
#     3) geom(etry)
#     4) facets
#     5) coordinates
#     6) labels
#     7) theme
# -- Basic form / simple plot: Mapping + geometries
# -- Typische geoms: 
#    geom_point()
#    geom_line()
#    geom_smooth()
#    geom_histogram
#    geom_col
#    geom_boxplot
# -- Global vs. local mapping
# -- Plots as part of pipelines
# -- Extras: size, color, shape, alpha
# -- Drittvariablen und facet wrap
# -- labs
# -- Typische Fehler: kein aes(), pipe-Operator





# Generische Grund-plots
#<===============================================================>


# Histogramm
mtcars %>% 
  ggplot(aes(x = qsec))+
  geom_histogram()
# Hilfreiche Argumente:
# -- bins = 20
# -- binwidth = 10


mtcars %>% 
  mutate(am=as.factor(am)) %>% 
  ggplot(aes(x = mpg, fill = am)) +
  geom_histogram(binwidth = 5, position="identity", alpha=.6) 
#position = "identity" verursacht, dass beide überlappen (ansonsten werden sie gestapelt)


# Boxplot
mtcars %>% 
  ggplot(aes(mpg))+
  geom_boxplot(fill="steelblue")+ #Nummer anstelle Farbwort von www.colorbrewer2.org
  coord_flip()

mtcars %>% 
  mutate(am = as.factor(am)) %>% 
  ggplot(aes(mpg, fill=am))+
  geom_boxplot()+
  coord_flip()
  

# Balkendiagram
mtcars %>% 
  ggplot(aes(x = gear)) + 
  geom_bar()+
  coord_flip() #Dreht das Diagramm


# Scatterplot
mtcars %>% 
  ggplot(aes(x= wt, y= mpg))+
  geom_point(size=3, alpha=.3) +
  theme_bw()
  


# Scatterplot-Variationen
#<===============================================================>

# Regressionslinie oder Nicht-lineare Kurve hinzufuegen
mtcars %>% 
  ggplot(aes(wt, mpg))+
  geom_point(size=3)+
  geom_smooth(method="lm", se=FALSE)+ #Regr.gerade
  geom_smooth(method="gam", se=FALSE, color="red") #Kurve


# Farbe nach einer kategorialen Drittvariablen
mtcars %>% 
  ggplot(aes(wt, mpg,colour = factor(cyl)))+
  geom_point(aes(colour = factor(cyl)), size=3) #aes = local mapping, hier neue Variable

#...und Gruppenspezifsichen Regressionslinien/kurven'
mtcars %>% 
  ggplot(aes(wt, mpg,colour = factor(cyl)))+
  geom_point(aes(colour = factor(cyl)), size=3) + #Hier muss aes(.) in das geom Und nicht ggplot!
  geom_smooth(method="lm", se=FALSE)


#Kontinuilierche Drittvariablen durch Punkte-Groe?e kennzeichnen
mtcars %>% 
  ggplot(aes(wt, mpg)) +
  geom_point(aes(size = qsec), alpha=.3)

#Kontinuierliche Drittvariablen farblich kennzeichnen
mtcars %>% 
  ggplot(aes(wt, mpg) )+
  geom_point(aes(colour=qsec), size=3)


#Aufdr�seln von Gruppen mit facet wrap
mtcars %>% 
  ggplot(aes(wt, mpg)) +
  geom_point(size=3)+
  facet_wrap(~ cyl, nrow = 2) 































