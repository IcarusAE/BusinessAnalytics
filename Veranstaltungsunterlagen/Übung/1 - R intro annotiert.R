


#<######################################################################################>
# R studio----
#<######################################################################################>

# 4 Fenster
'-- Layout kann veraendert werden über die Menueleiste:
    Tools/Global options/Pane Layout
-- Hintergrundfarbe ändern: Tools/global options/appearance/ Bei mir (dark mode):
   "Pastel on dark"
-- Gestern nicht erwähnt. Damit man deutsche Umlaute eintippen kann und die nicht 
   beim Erneuten Laden des Skripts als hässliche Zeichen dargestellt werden, müssen
   2 Dinge getan werden:
   (1) Tools/Global Options/Code/Saving. Dort unter default text encoding UTF8 einstellen.
   (2) Beim ersten Speichern des Skripts File/Save with encoding --> UTF8 einstellen.
   Es kann sogar sein, dass Schritt 2 gar nicht nötig ist ;)'

# Scripts und Projekte
'-- Script: Enthalten code; Moeglichkeit der Makro-Strukturierung
    (z.B. ein Skript für das Einlesen der Daten und eines für die Modelle
 -- Projekte umfassen mehrere Skripte und die gespeicherten Objekte.
    Sie haben enorme Vorteile:
    1) Mit dem Laden des Projekt-files werden alle Skripts mitgeladen
    2) Wenn die Rohdaten im selben Ordner sind, können die Daten einfach mit 
       Verweis auf den Daten-Namen geladen werden (s.u. "Einlesen von Daten")'






#<######################################################################################>
# Basic R concepts---- 
#<######################################################################################>


#> Verschiedendes----
#===============================================================>

#1) Strukturierung mit Ueberschriften
'-- Überschriften werden generiert durch 4 Striche (----)
 -- Können direkt angesteuert werden über das Stapelsymbol rechts
    neben "Source"'

#2) Kommentare und Anmerkungen
# Mit der Raute #

#3) Case-sensitivity und Genauigkeit
'Auf Groß- und Kleinschreibung achten. Am besten, komplett alles klein'

#4) Fehlermeldungen vs. Warnungen
'Ersteres zeigt ernstes Problem, zweites ist ein Hinweis'






#> Zuweisungen und Objekte----
#===============================================================>

'Mittels des Zuweisungs-operators (<--) können Ergebnisse
 von Prozeduren (von "1+2" bis zu Modellen) dauerhaft gespeichert und
 weiterverwendet werden, z.B'

a <- 1+2
a + 5


'Beispiel lineare Regression:'
#Rechnen der LM und Zuweisen zum Objekt "linreg"
linreg <- lm(mpg ~ hp + wt, data=mtcars) 

summary(linreg) #Anzeige der Koeffizienten
anova(linreg)   #Anzeige der ANOVA-Tabelle



#> Klassen von Datenobjekten----
#===============================================================>

# Modi (u.a.): Numeric, character, logical (true/false)
'Betreffen spezifische Datenelemente (z.B. Variablen):
 1) Numeric: Zahl (in einem tibble als double (dbl). 
 2) character: String/alphanumerisch, d.h. Buchstaben und Worte (z.B. offene Antworten)
 3) logical: Tritt (meist intern) bei einer Bedingungsprüfung auf, z.B. filter()

'

# Klassen: matrix, factor, list, dataframe
'Klassen betreffen komplexere Datenobjekte:
-- Matrix: Nur ein *Modus* (z.B. numerisch)
-- List: Verschiedene Modi als separate Listenelemente
-- Dataframe: Am flexibelsten; mehrere Modi
-- Faktoren: Sehr wichtig! Sind seltsamerweise eher Variablen. Sie werden aber intern
   als entweder Numerisch kodiert (auch wenn diese zahlen als Kategorien gelten). Sie haben
   daher den Modus "numeric" (oder "integer", was ganze Zahlen sind)



F A Z I T: 
Die Begriffe "Modus" und "Klasse" sind irrelevant (und bezügl. "factors"
m.E. verwirrend). 
Was wichtig ist, ist die Frage, ob eine eine Variable im Datensatz numerisch 
(eine Zahl, mit der men Rechnen kann), ein Character, oder ein factor ist? 
Beim EInlesen von csv files kommt es ab und zu mal zu Fehlern und Faktoren 
werden als numerisch eingelesen (v.a. wenn sie numerisch kodiert sind, 
die codes aber nur Kategorie-labels sind. Daher ist der erste Check in jedem
Projekt, die Modi der Variablen zu überprüfen und ggfls. umzukodieren.
'






# Beispiel: mtcars-dataframe 
'-- Dataframes (bzw. ihre Version im Tidyverse: tibbles, s.u.) sind DAS zentrale Datenobjekt
 -- mit dem Laden von R ist ein Beispiel der mtcars-Dataframe:
'

mtcars


# Anzeige mit str(.) und mode(.) und class(.)
'str() gibt einen Überblick über einen dataframe'
str(mtcars)

# Genauerer Blick mittels View()
View(mtcars) 
'Achtung: Die einzige Funktion, die ich kenne, die groß geschrieben wird!
Hinweis: Den screen kann man vergrößern durch Klicken auf das Symbol mit dem kleinen 
Pfeil!'







#> Funktionen----
#===============================================================>

# Body und 3 Arten von Argumenten (essentielle, default, optionale)
'--Function call: z.B. "lm()
 --body enthält Argumente:
   a) essentielle: muessen rein, damit R wei?, womit es rechnen soll
   b) Default sind essentiell, aber mit einem default-Wert versehen 
      (kann geaendert werden
   c) optional: Weitere Moeglichkeiten'


# Hilfe mit ?
'z.B'
?lm()




#> Pakete----
#<===============================================================>

# Was ist das?
'Enthält eine Reihe von Funktionen, die einen bestimmten Zweck erfuellen'

# Download/Installation vs. Aktivierung
'Installation'
install.packages("lavaan") 

'Aktivierung (! Kann / muss aber nicht in Anfuehrungszeichen stehen')
library(lavaan) 


# Konflikte zwischen Paketen, die die selben Funktionsnamen haben (und Loesung mit Paket::Funktion)
dplyr::select(var1, var2)


# Typische Fehlermeldung (Paket muss geladen werden (oder überhaupt erst mal 
# heruntergeladen werden):
' could not find function "read_csv2"'




#> Indizieren ("Die Plage")----
#<===============================================================>

'Tippt man einen Namen in R, sucht R im "Suchpfad. Es findet alle
dort enthaltenen Objekte, sucht aber nicht IN den Objekten.
Um daher eine Variable in einem dataframe (=Objekt) zu finden/
anzusprechen, muss man sie indizieren'

wt #Geht nicht, da in dem Objekt mtcars
mtcars$wt #Geht

'Dies ist aufwaendig--v.a. bei mehreren Variablen. z.B. Korrelationsmatrix'

cor(cbind(mtcars$mpg, mtcars$wt, mtcars$hp), use="pair")

'Bemerke:
 -- cor() ist eine Funktion, "use="pair" ein wichtiges Argument 
    (--> pairwise deletion von missing data
 -- cbind() ist eine weitere Funktion (column bind).
Man sieht, wie umstaendlich durch die Indizierung UND cbind()

Alternative ist, mtcars zu "attachen":'

attach(mtcars)
cor(cbind(mpg, wt, hp), use="pair")
'cbind ist immer noch noetig, aber keine Indizierung. Hierbei 
ist jetzt das Problem, dass es zu Konflikten kommen kann, wenn 
mehrere dataframes attached sind die die Variablen enhalten:'

mtcars2 <- mtcars #Kopie
attach(mtcars2) #R zeigt bereits das Problem
'Rechnet man jetzt die Korrelation, bekommt man zwar eine, aber man
weiß nicht, welcher dataframe dazu benutzt wurde.
Lösung koennte sein, den dataframe nach der Korrelation zu detachen
'

attach(mtcars)
cor(cbind(mpg, wt, hp), use="pair")
detach(mtcars)

'--> Zu aufwaädig. Mit dem tidyverse-Ansatz braucht man all dies nicht ;)'




#<######################################################################################>
# Das tidyverse----
#<######################################################################################>


# Online book by Hadley Wickham! https://r4ds.had.co.nz/index.html

# Packages:
'
-- tibble
-- tidyr
-- dplyr  
-- purrr   
-- stringr 
-- readr   
-- forcats 
-- ggplot2
'

install.packages("tidyverse")
library(tidyverse)




#> Dataframes vs. Tibbles----
#<===============================================================>

install.packages("ISLR")
library(ISLR) # Paket zum James et al. Buch
data(Hitters) #Aktivieren des "Hitters"-Datensatzes, der im ISLR Paket enthalten ist

Hitters # Als dataframe: Sehr "unhandlich"!

as_tibble(Hitters) 
' Als Tibble (!): 
1) Es werden nur soviel Variablen dargestellt, wie auf den screen passen. 
2) In der ersten Zeile sieh man das N und P
3) In der 3. sieht man (sehr wichtig und handlich!) die Modi der Variablen (und factors)
   sind auch abgebildet. 
4) Negative Werte werden in rot gefärbt (beim Hitters-Datensatz gibt es nur keine)
'




# Einlesen von Daten
#<===============================================================>

# BASE R-Variante
read.csv(.....) #Kommata als Trennzeichen

read.csv2("C:\\Users\\steinmetzh\\Dropbox\\Lehre\\Methoden\\SEM\\Corona data.csv", header=TRUE)  # (Semikola als Trennzeichen)
'Achtung: Pfade benötigen Doppel-Backslashes!

Besser ist es allerdings, keinen Pfad zu verwenden, sondern ein Projekt und die Daten
im Projektordner zu speichern
'




# Tidyverse-Variante (readr-package):
corona_data <- read_csv2("Corona data.csv") #Tidyverse; Semikola als Trennzeichen
'Achtung: Setzt voraus, dass die Daten im Projektordner sind.'

# Dataframes können auch manuell umgewandelt werden in Tibbles (hatten wir oben
# schon beim Hitters Datensatz)
mtcars_tb <- as_tibble(mtcars)
mtcars_tb

'Hinweis: Manche Datensätze (wie hier der mtcars-Datensatz) haben sogenannte
"rownames" (der AUto-Typ in der ersten Spalte). Diese sind keine expliziten
Variablen (sie haben keinen Spaltennamen). Wenn das mal vorkommt, kann man das durch
das optionale Argument "rownames = <gewünschter Name>" adressieren:'
mtcars_tb <- as_tibble(mtcars, rownames = "car_type")
mtcars_tb

# Einlesen von Excelfiles
library(readxl)
rdb_departments <- read_excel("Beispiel Relational Database.xlsx",
                              sheet = "departments")
rdb_departments
'Behandlen wir in der 2. Vorlesung'




#> Pipelines und der "pipe operator"----
#<===============================================================>

'Base R beruht auf dem Verschachteln von Funktionen in anderen Funktionen.
Das kann sehr schnell sehr komplex und schwer verstaendlich werden.
Beispiel: Wir sollten mehrere Funktionen auf einen Daten vektor anwenden
a) Datenvektor generieren' 
c(1,4,5,2,5)

'b) die Wurzel aller Elemente ziehen'
sqrt(c(1,4,5,2,5))

'c) Die "gewurzelten" Werte auf 2 Dezimalstellen rundenen (mit der Funktion round(x, 2) )'
round(sqrt(c(1,4,5,2,5)), 2)

'd) und schließlich den Mittelwert berechnen'
mean(round(sqrt(c(1,4,5,2,5)), 2))
'Wie man sieht, nicht sehr elegant'


'Tidyverse nutzt dagegen das Prinzip einer Pipeline, in der Teilschritte durch den
pipe-operator %>% (STRG-SHFT-M) verbunden werden. Diesen kann man lesen als "und dann"'
c(1,4,5,2,5) %>%   # Füge werde zu einem Vektor zusammen..."und dann"
  sqrt() %>%       # Ziehe die Wurzel..."und dann"
  round(., 2) %>%  # Runde ..."und dann"
  mean()           # Berechne das Mittel


  
  
  

#> dplyr's Fab 5----
#<######################################################################################>

# Überblick
'
1) select(): Variablen auswählen
2) filter(): In einer Variable Fälle herein- oder herausfiltern
3) summarise(): Deskriptive Stats berechnen / über Fälle aggregieren
4) mutate(): Variablen verändern / neue Variablen berechnen
5) group_by(): Nachfolgende Operationen gruppieren
'



# Select
#<===============================================================>

# Auswahl aufgrund der Variablenummer, Name oder Bereich

mtcars %>% 
  select(1,3,5)  '3 Variablen auswaelen (die 1., 3., und 5.)'

mtcars %>% 
  select(1:5, 8) 'Die ersten 5 und die 8. variable auswaehlen'

mtcars %>% 
  select(mpg, hp) 'Die Variablen mit ihren Namen ansprechen'

mtcars %>% 
  select(mpg:hp, vs) 'Den Bereich der Variablen von mpg BIS hp UND vs auswaehlen'


# Sortieren mit select / Nutzen von "everything()"

mtcars %>% 
  select(vs, disp, cyl, mpg, everything()) 
'Nimm die Variablen vs etc. in dieser Reihenfolge nachvorne und 
lasse den Rest (everything() wo er ist'


# Negativ-Auswahl mit "-" 

mtcars %>% 
  select(-mpg, -vs) 'Nimm alles AUSSER mpg und vs'

mtcars %>% 
  select(-(mpg:disp)) 'Nimm alles AUSSER mpg BIS disp'



# Variablen umbenennen innerhalb select()

mtcars %>% 
  select(mpg, zyl = cyl) 'Wähle mpg und cyl, aber benenne cyl um'

# Achtung: select konfligiert h?ufig mit dem select aus anderen Paketen!
mtcars %>% 
  dplyr::select(mpg, zyl = cyl) 'Sicher ist sicher. So wird klar, dass R den select-
Befehl aus dem dyplr-Paket verwendet und keinen anderen'




# Filter
#<===============================================================>

# Pruefung von Bedingungen: Logische Symbole: ==, >=, <=, !=, |, &

mtcars %>% 
  filter(cyl == 6 ) 'Filtere alle Fälle, dei cyl==6 sind (Achtung: "==" nehmen)'

'Und-Verknüpfungen'
mtcars %>% 
  filter(cyl == 6 & hp==110)


'Oder-Verknüpfungen mit |'
mtcars %>% 
  filter(cyl == 6 | hp== 110)


# Positive filter vs. negative Filter
mtcars %>% 
  filter(cyl != 6 ) ' Das Symbol != bedeutet "ist nicht'


# Zahlen vs. Worte filtern

X = c("Hallo", "Hallo", "Schwimmbad", "Gym", "Haengematte")
X <- as_tibble(X)
X %>% 
    filter(value == "Hallo")


# Einen Bereich von Werten filtern ("%in% c(5:10)"). Anm. Die Werte müssen vorkommen

'Wenn man mehrere Werte filtern moechte kann man das explizit machen. Ist aber bei
vielen Werten zu aufwändig'
mtcars %>% 
  filter(cyl == 6 | cyl==8)

'Besser:'
mtcars %>% 
  filter(cyl %in% c(6, 7, 8))

# Werte kleiner als ... filtern)
mtcars %>% 
  filter(disp < 200)


# Verketten von Funktionen
mtcars %>% 
  filter(mpg >= 18 & mpg <=25 & disp >150) %>% 
  select(mpg, disp)
'Waehle Faelle aus die in mpg zwischen 18 und 25 liegen und Werte in disp ueber 150 haben und 
wähle dann nur die Variablen mpg und disp'



# Zufällige Anzahl von Faellen filtern mit slice_sample(n=10) oder ..(prop=.2)
mtcars %>% 
  slice_sample(n=10)

mtcars %>% 
  slice_sample(prop = .50)



# Fehlende Werte (missing data) rein - oder rausfiltern mit is.na()
Hitters %>% 
  filter(is.na(mpg)) 'Missings anzeigen/filtern'
 

mtcars %>% 
  filter(!is.na(mpg)) 'Missings rausfiltern/eliminieren'

na.omit(mtcars) 'Alle missings entfernen'



# Säubern der Variablenamen
'Mittels der clean_names() Fuktion des janitor-Pakets kann man die Variablennamen
etwas verschönern
-- Alles klein
-- Leerzeichen durch underscores ersetzen'

# Original
Hitters %>% 
  as_tibble()

# Gesäubert:
Hitters %>% 
  as_tibble() %>% 
  janitor::clean_names()



# Summarise
#<===============================================================>

# Grundprinzip mit den wichtigsten Sub-Funktionen mean(), sd(), min(), max()
mtcars %>% 
  summarise(mean = mean(mpg, na.rm=TRUE),
            sd   = sd(mpg, na.rm=TRUE),
            min = min(mpg, na.rm=TRUE),
            max = max(mpg, na.rm=TRUE) )
'Anm. Das "mean =" ist optional und führt zur entsprechenden Spaltenbeschriftung.
Vor allem hilfreich/wichtig, bei mehreren Variablen:'
mtcars %>% 
  summarise(mean_mpg = mean(mpg, na.rm=TRUE),
            mean_disp = var(disp, na.rm=TRUE))  

# Gesamtsummary: psych::describe(.)  
'Die describe-Funktion ist hilfreich um einen Überblick ueber den Datensatz zu bekommen:'
psych::describe(mtcars) %>% 
  as_tibble() %>% 
  select(-mad, -range, -skew, -kurtosis, -se, -vars)

'durch pipen in "as_tibble" ueberführt man die Tabelle in ein tibble auf das man alle
dyplr-Funktionen anwenden kann:'
psych::describe(mtcars) %>% 
  as_tibble(rownames = "variable") %>% # Rownames in explizite Variablen umwandeln
  select(-mad, -range, -skew, -kurtosis, -se, -vars) #Z.B. Auswahl wichtiger Stats



# Zählen der einzigartigen Werte 
mtcars %>% 
  summarise(n_values = n_distinct(wt))





# Mutate
#<===============================================================>

#Corona-Datensatz laden/importieren (Achtung: Ihr muesst den Pfad anpassen!)
cor_data <- read_csv2("C:\\Users\\Steinmetz\\Dropbox\\Lehre\\Methoden\\SEM\\Daten\\Corona data.csv")


# Grundprinzip: In mutate kann jedwelche mathematische Funktion angewendet werden:
mtcars %>% 
  mutate(x = cyl+5) #"Lege die Variable X an und die soll eine Funktion der Variable cyl sein + 5"

mtcars <- mtcars %>% 
  mutate(cyl_sqrt = sqrt(cyl)) #Dto. Lege die Variable cyl_sqrt an als Wurzel von cyl



# Praktisches Beispiel Zentrierung und Standardisierung von Variablen
'X_s = (X - mean(X))  ---> Zentrierung'
'X_s = (X - mean(X)) / sd(X) ---> Standardisierung' 

 mtcars %>% 
  mutate(disp_s = disp - mean(disp)  )  #Zentrierung 
 
 mtcars %>% 
   mutate(disp_s = (disp - mean(disp)) / sd(disp) )  #Standardisierung (Klammern beachten!)
  


# Modi umwandeln mit as.numeric, as.character, as.factor

mode(mtcars$vs) #Check: Welchen Modus hat die Variable vs?

mtcars %>%
  as_tibble() %>% 
  mutate(vs_fact = as.factor(vs))

'Achtung: Bei allen mutate Befehlen muss f?r eine dauerhafte Speicherung der neuen Variable 
die pipeline einem Objekt zugewiesen werden (alter Datensatz oder Kopie):'

mtcars %>% 
  mutate(x = cyl+5)  #Keine Speicherung/nur temporaer vs.

mtcars <- mtcars %>% 
  mutate(x = cyl+5)  #--> Speicherung. 
'Tipp: Die Zuweisung erst am Ende vornehmen, wenn die pipeline gecheckt wurde und funktioniert '



# Summen-/Mittelwert ("composite") bilden
mtcars %>% 
  mutate(power_mean = rowMeans(select(.,mpg, cyl,disp),na.rm=TRUE)) #Achtung, macht hier nat?rlich keinen Sinn

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
'Anm. Das schwierigste ist hier, sich nicht in den Klammern verheddern! Tipp: Die Faehigkeit von Rstudio
benutzen, ge?ffnete und passende geschlossene Klammern zu verdeutlichen, in dem man mit dem Cursor
dar?ber geht'


#Wann ist es sinnvoll eine dummy variable als numeric umzudefinieren?
'Dummies sind kategoriale Vairablen und sollten das auch sein. Es gibt aber Situationen,
da m?chte man einen pseudo-numerischen Modus erzwingen. Hier am Beispiel einer Korrelation
Neben-Aspekt: Die as.numeric-Funktion wird in der pipeline nebenbei (und tempor?r) angewendet.
D.h. die urspr?ngliche Kodierung der Variable als Faktor wird nicht ver?ndert'
cor_data %>% 
  select(aff_worry_o, aff_worry_v01, sex_new) %>% 
  mutate(sex_new = as.numeric(sex_new)) %>% 
  cor(., use="pair")




# Rekodieren von Variablen
'Survey-Items, die dasselbe Kontrukt messen, werden oft in der negativen Form (ich bin unzufrieden oder ich bin
nicht motiviert) abgefragt. Dann muss die Skala rekodiert ("invertiert") werden. Dazu gibt es die recode-Funktion'
data <- data %>% 
  mutate(x_rec = recode(x, "0"=6,"1"=5,"2"=4,"3"=3,"4"=2, "5"=1, "6"=0 ))

'Zwei wichtige Dinge beim Rekodieren
1) Alte Variable nicht ueberschreiben
2) Recode kontrollieren, z.B. mit einer Korrelation (muss r = -1 sein) oder Kreuztabelle'


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
'Zweite Version des desselben Ziels: Hier ohne group_by; stattdessen erfolgt die Kreuzung in count()'
cor_data %>% 
  count(aff_worry_o, sex_new) %>% 
  spread(sex_new, n)
  
#4-Felder Mittelwertstabellen
mtcars %>% 
  group_by(vs,am) %>% 
  summarise(mean_disp = mean(disp)) %>% 
  spread(vs, mean_disp) #Kreuzung: Diesmal ist der angelegte Mittelwerte der Zelleninhalt--nicht "n"


  
  
# Hilfreich f?r gruppenspezifische Berechnungen (z.B. Prozentwerte in Haeufigkeitstabellen)

mtcars %>% 
  group_by(vs) %>% 
  count(carb) %>% 
  mutate(perc = n / sum(n))
'Hier dient count(.) erst dazu die H?ufigkeit jedes Wertes aufzulistn (neues tibble)--anschlie?end
wird eine neue Variable angelegt/hinzugefuegt, die den Prozentwert berechnet. Das ist 
nur ein Beispiel f?r die Flexibiliaet die R und tidyverse bieten um eigene Zielgr??en kreativ zu 
entwickeln'



#> ggplot----
#<######################################################################################>

'
-- Nice intro: https://www.youtube.com/watch?v=HPJn1CMvtmI
-- Das layers-Konzept: 
    1) data
    2) mapping
    3) geom(etry)
    4) facets
    5) coordinates
    6) labels
    7) theme
-- Basic form / simple plot: Mapping + geometries
-- Typische geoms: 
   geom_point()
   geom_line()
   geom_smooth()
   geom_histogram
   geom_col
   geom_boxplot
-- Global vs. local mapping
-- Plots as part of pipelines
-- Extras: size, color, shape, alpha
-- Drittvariablen und facet wrap
-- labs
-- Typische Fehler: kein aes(), pipe-Operator
'




# Generische Grund-plots
#<===============================================================>


# Histogramm
mtcars %>% 
  ggplot(aes(x = qsec))+
  geom_histogram()
'Hilfreiche Argumente:
-- bins = 20
-- binwidth = 10'

mtcars %>% 
  mutate(am=as.factor(am)) %>% 
  ggplot(aes(x = mpg, fill = am)) +
  geom_histogram(binwidth = 5, position="identity", alpha=.6) 
'position = "identity" verursacht, dass beide ?berlappen (ansonsten werden sie gestapelt)'


# Boxplot
mtcars %>% 
  ggplot(aes(mpg))+
  geom_boxplot(fill="#fdbb84")+ #Nummer anstelle Farbwort von www.colorbrewer2.org
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
  coord_flip() #'Dreht das Diagramm'


# Scatterplot
mtcars %>% 
  ggplot(aes(x= wt, y= mpg))+
  geom_point(size=3, alpha=.3) +
  theme_bw()
  


# Scatterplot-Variationen
#<===============================================================>

'Regressionslinie oder Nicht-lineare Kurve hinzufuegen'
mtcars %>% 
  ggplot(aes(wt, mpg))+
  geom_point(size=3)+
  geom_smooth(method="lm", se=FALSE)+ #Regr.gerade
  geom_smooth(method="gam", se=FALSE, color="red") #Kurve


'Farbe nach einer kategorialen Drittvariablen'
mtcars %>% 
  ggplot(aes(wt, mpg,colour = factor(cyl)))+
  geom_point(aes(colour = factor(cyl)), size=3) #aes = local mapping, hier neue Variable

'...und Gruppenspezifsichen Regressionslinien/kurven'
mtcars %>% 
  ggplot(aes(wt, mpg,colour = factor(cyl)))+
  geom_point(aes(colour = factor(cyl)), size=3) + #Hier muss aes(.) in das geom Und nicht ggplot!
  geom_smooth(method="lm", se=FALSE)


'Kontinuilierche Drittvariablen durch Punkte-Groe?e kennzeichnen'
mtcars %>% 
  ggplot(aes(wt, mpg)) +
  geom_point(aes(size = qsec), alpha=.3)

'Kontinuierliche Drittvariablen farblich kennzeichnen'
mtcars %>% 
  ggplot(aes(wt, mpg) )+
  geom_point(aes(colour=qsec), size=3)


'Aufdr?seln von Gruppen mit facet wrap'
mtcars %>% 
  ggplot(aes(wt, mpg)) +
  geom_point(size=3)+
  facet_wrap(~ cyl, nrow = 2) 







################################################################>
# Typische EDA Funktionen----
#<###############################################################>


# Haeufigkeitsverteilungen und Kreuztabellen
'1) Einfacher count
 2) Sortieren nach Haeufigkeit
 3) spread() bei Kreuztabellen macht sie intuitiver'



# summary stats: mean, sd, median, min, max, range
'Siehe oben'


# plots: Histogram, scatterplot (with geom_smooth), barplot (geom_col)
'Siehe oben'

# Korrelationen



#Korrelationen
'Einfache Korrelationen mit dplyr'

...


'Korrelationsmatrizen mit Ns und Signfikanztests'
library(Hmisc)
mtcars = as.matrix(mtcars)
class(mtcars)
rcorr(mtcars)


































################################################################>
# SEM mit lavaan: Ein einfaches Pfaddiagramm----
#<###############################################################>

install.packages("tidyverse")
library(tidyverse)

pmdata <- read_csv2("D://pmdata.csv") #Eigenen Pfad waehlen


'Mittels read_csv2 werden die Variablen leider als char eingelesen.
Ergo muessen sie rekodiert werden:'
pmdata <- pmdata %>% 
  mutate(X = as.numeric(X),
         M = as.numeric(M),
         Y1 = as.numeric(Y1),
         Y2 = as.numeric(Y2))


'Diskutierte Alternativen zum Einlsen ?ber read_csv2 war
 ?ber das files-Fenster in Rstudio (Rstudio-Explorer)
    -- Auf das Datenfile klicken und dann im Mikro-Menue "Import Dataset
    -- Dann oeffnet sich ein Vorschaufenster. Sollten dort die Variablen
       nicht in Spalten sein, stimmt das Trennzeichen nicht. Dies kann im
       unteren Teil ?ber "deliminiter" auf "Semikolon" ge?ndert werden.
    Achtung: Anstatt jetzt auf "Import" zu klicken, kann man den Code 
    im Code preview auch herauskopiert werden (Halte ich fuer sinnvoller
    wegen der Replizierbarkeit). Dies hab ich hier mal gemacht:
'

library(readr)
pmdata <- read_delim("Daten/pmdata.csv", 
                     ";", escape_double = FALSE, trim_ws = TRUE)


'Wie man sieht ist dies eine tidyverse-Funktion (read_delim) aus dem
readr-package. Dies m?sst ihr aber nicht (wie hier) nochmal gesondert
laden (mittels library()--Es ist bereits durch library(tidyverse) mitgeladen!'




#Nicht vergessen: Lavaan laden
library(lavaan)


# Fall 1: Einfaches Modell (siehe Folien)
#<########################################################>

# Step 1: Modelspezifikation
pmmodel1 <- '
  M ~ X
  Y1 ~ M
  Y2 ~ M
  Y1~~.5*Y2
'

# Step 2: Sch?tzung
est1 <- sem(pmmodel1, data= pmdata, fixed.x = FALSE)

# Step 3: Summary/Output
summary(est1, standardized=T, fit.measures = T)




# Fall 2: Error covariances zwischen Y1 und Y2 auf 0 fixieren
#<########################################################>

# Step 1: Modelspezifikation
pmmodel2 <- '
  M ~ X
  Y1 ~ M
  Y2 ~ M
  Y1~~.0*Y2
'

# Step 2: Sch?tzung
est2 <- sem(pmmodel2, data= pmdata, fixed.x = FALSE)

# Step 3: Summary/Output
summary(est2, standardized=T, fit.measures = T)




# Fall 3: Error covariances zwischen Y1 und Y2 auf .5 fixieren
#<########################################################>

# Step 1: Modelspezifikation
pmmodel2 <- '
  M ~ X
  Y1 ~ M
  Y2 ~ M
  Y1~~.0*Y2
'


# Step 2: Sch?tzung
est2 <- sem(pmmodel2, data= pmdata, fixed.x = FALSE)


# Step 3: Summary/Output
summary(est2, standardized=T, fit.measures = T)






#<###############################################################>
# Fallbeispiel aus der Aufgabe----
#<###############################################################>

'Anm. Hintergrund war das Modell, in dem Gewissenhaftigkeit einen Mediator-
effekt auf Depression ?ber Therapie-compliance haben sollte'

#Daten einlesen
compliance = read_csv2("./compliance_data.csv")


#Ursprungs-/Mediatormodell testen
model1 <- '
    Compl ~ Gew
    Dep ~ Compl + NAff
'

fit <- sem(model1, compliance)

summary(fit)


#Diagnostik: Gegen?berstellung von S und Sigma
compliance %>% 
  select(Dep, Compl, NAff, Gew) %>% 
  cov(.) %>% 
  round(.,3)

fitted(fit)


#Test des ver?nderten Modells
model2 <- '
    Compl ~ Gew + Dep
    Dep ~ NAff
'

fit2 <- sem(model2, compliance)

summary(fit2)









#<##########################################################################>
# CFA WFC----
#<##########################################################################>

library(tidyverse)
library(lavaan)



semdata <- read_csv2("./SEMdata.csv") %>% 
  select(w01:km03)


# Step 1: Model structure
cfa1 <- '
  WFC =~ w01+ w02+ w03
  AFZ =~ az01 + az02
  KMOT =~ km01+km02+km03
'


# Step 2: Estimation
fit1 <- sem(cfa1, semdata)

fit1 <- sem(cfa1, semdata, estimator="mlr", missing="fiml")

#Step 3: Summary
summary(fit1, standardized=TRUE)




#
#<##########################################################################>
# SEM WFC----
#<##########################################################################>

library(tidyverse)
library(lavaan)



semdata <- read_csv2("./SEMdata.csv") %>% 
  select(w01:km03)


# Step 1: Model structure
sem1 <- '
  #Messmodell
  WFC =~ w01+ w02+ w03
  AZF =~ az01 + az02
  KMOT =~ km01+km02+km03
  
  #Strukturmodell
  KMOT ~ WFC+ AZF
  AZF ~ WFC
'


# Step 2: Estimation
fit2 <- sem(sem1, semdata, estimator="mlr", missing="fiml")

#Step 3: Summary
summary(fit2, standardized=TRUE, fit.measures=TRUE)
