library(tidyverse)
options(tibble.print_min = 30) # Manuele Setzung der Anzahl der Zeilen in einem tibble



#<#############################################################################>
# Aggregation von Daten----
#<#############################################################################>

library(gapminder)
data(gapminder)



# Beispiel 1: Aggregation auf country-level (d.h. über die Zeit)

gapminder %>% 
  group_by(country) %>% 
  summarise(mean_LE = mean(lifeExp, na.rm=TRUE))


# Beispiel 2: Aggregation auf Jahres-level (d.h. über L#nder)

gapminder %>% 
  group_by(year) %>% 
  summarise(mean_LE = mean(lifeExp, na.rm=TRUE)) %>% 
  ggplot(aes(year, mean_LE))+
  geom_line()+
  geom_point()







#<#############################################################################>
# Pivoting----
#<#############################################################################>

# Bedeutet, dass Tibbles oder Teile davon um 90 Grad von "wide format " in "longformat"
# oder umgekehrt


mtcars %>% 
  select(cartype, disp, qsec, mpg) %>% 
  pivot_longer(2:4, names_to = "variable", values_to = "value") %>% 
  ggplot(aes(variable, value))+
  geom_boxplot(width=.4, fill = "steelblue")+
  coord_flip()+
  theme_light()+
  labs(x = "Variable", y= "Wert der Variable", title = "Beispielplot durch pivot longer")








#<#############################################################################>
# Joining (Zusammenfügen von Datensätzen)----
#<#############################################################################>


#> Herstellung eines kleinen Datensatzes----
#<#############################################################################>

# Table 1: Employees
employee_id <- c(1, 2, 3, 4, 5)
employee_name <- c("Alice", "Bob", "Charlie", "Dave", "Eve")
department_id <- c(101, 102, 103, 104, 105)

(employees <- tibble(employee_id, employee_name, department_id))

# Table 2: Departments
department_id <- c(101, 102, 104, 106)
department_name <- c("Marketing", "Sales", "IT", "HR")

(departments <- tibble(department_id, department_name))





#> Arten von joins----
#<#############################################################################>

# Inner Join: Schnittmenge (-> "A" AND "B")
inner_join(employees, departments, by = "department_id")

# Left Join: Das linke table ist fix und das rechte wird passend hinzugefügt
left_join(employees, departments, by = "department_id")
# --> Der linke Datensatz bleibt vollständig; ge-jointe werden ggfl. NA

# Right Join: Das rechte table ist nun der Maßstab, die überschüssigen im linken 
# fallen raus (!)
right_join(employees, departments, by = "department_id")

# Full Join: Alles wird zusammengemischt
full_join(employees, departments, by = "department_id")

# Anti-Joins: Explizite Suchen nach den Nicht-Übereinstimmungen
anti_join(employees, departments, by = "department_id") #--> Welche Mitarbeiter haben keine Department-Zuweisung?
anti_join(departments, employees, by = "department_id") #--> Welche Departments haben keine Mitarbeiter-Zuweisung?



#<---------------------------------------------------->
# FAZIT: 
# 1) Ich persönlich nehme fast ausschließlich left_join und wähle die tables entsprechend aus
# 2) left_join etc. geht natürlich auch in einer pipeline:
      employees %>% 
        left_join(departments, by = "department_id")
# 3) Anti_join ist häufig sehr hilfreich, um die "misfits" zu finden
#<---------------------------------------------------->





#> Joins von Daten unterschiedlicher Dimensionalität----
#<#############################################################################>

# Herstellung zweier DatensÃ¤tze
#<============================================================>

# Generieren eines tibbles mit Ländern und Kultureigenschaften
country_level <- tibble(
  country = c("USA", "Canada", "UK", "Germany", "France", "Spain", "Japan", "China"),
  institution = c("democracy", "democracy", "monarchy", "democracy", "democracy", "monarchy", "monarchy", "communist"),
  culture = c("individualistic", "individualistic", "collectivistic", "individualistic", "individualistic", "collectivistic", "collectivistic", "collectivistic")
)
country_level


# Generierung einer gemessenen (time-varying) Variable
time_level <- tibble(
  country = rep(c("USA", "Canada", "UK", "Germany", "France", "Spain", "Japan", "China"), each = 10),
  year = rep(2010:2019, 8),
  y = sample(1:100, size = 80)
)
time_level %>% print(n=35) 



# Join
#<============================================================>

multilevel <- country_level %>% 
  left_join(time_level, by="country", multiple="all") 

multilevel %>% print(n=35)




#> Back-joining nach group_by & summarise
#<#############################################################################>

mtcars %>% 
  group_by(vs) %>% 
  summarise(mean_mpg = mean(mpg, na.rm=TRUE)) %>% 
  left_join(mtcars, multiple="all")

mtcars %>% 
  add_count(vs)



# Nested data----
#<#############################################################################>

# Quelle: https://www.youtube.com/watch?v=rz3_FDVt9eg&t=1883s (Video mit H. Wickham)

# Bedeutet, dass Teilstrukturen komprimiert verschachtelt in tables repräsentiert
# werden können

gapminder_nested <- gapminder %>% 
  group_by(country) %>% 
  nest()
gapminder_nested

gapminder_nested %>% 
  unnest(cols = data) # Welche Variable enthält die genesteten Daten?



# Jetzt kann man über jedes der genesteten tibbles ein eigenes Regressionsmodell
# rechnen:
gapminder_nested <- gapminder_nested %>% 
  mutate(model = map(data, ~ lm(lifeExp ~ year, data=.)),
         coef.info = map(model, broom::tidy))

#Das Ergebnis: Das genestete tibble wird erweitert um Regressionskoeffizienten

gapminder_nested %>% 
  unnest(cols=coef.info) %>% 
  select(term, estimate) %>% 
  filter(term == "year") %>% 
  select(-term) %>% 
  arrange(estimate)


# ---> Ergebnisse der tidymodels werden in einem solchen genesteten tibble
#       dargestellt (d.h. Daten, Modell-Metriken, und vorhergesagte Daten)
