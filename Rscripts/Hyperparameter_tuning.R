library(tidyverse)
library(tidytext)
library(tidymodels)
theme_set(theme_bw())


# 5.2.1 Import der Daten
#<############################################################################>

library(ISLR)
data("Default")
default <- as_tibble(Default)


# 5.2.2 Split the data
#<############################################################################>

set.seed(123)
default_split <- initial_split(default, strata = default)
default_train <- training(default_split)
default_test <- testing(default_split)

default_cv <- vfold_cv(default_train)


# 5.2.3 Create recipe
#<############################################################################>

default_rec <- recipe(default ~ ., data=default_train) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_dummy(all_nominal_predictors())

#Check
default_rec %>% 
  prep() %>% 
  juice()


# 5.2.4 NEU: Specify the model
#<############################################################################>

# Hier jetzt ein KNN

knn_spec <- nearest_neighbor(
  neighbors = tune()
) %>% 
  set_engine("kknn") %>% 
  set_mode("classification")


# 5.2.5 Add to workflow
#<############################################################################>

default_wf <- workflow() %>% 
  add_recipe(default_rec) %>% 
  add_model(knn_spec) 


# 5.3.2	NEU: Wertebereich für den/die HP anlegen (ein sog. "Tuning Grid")
#<############################################################################>

# Version 1: Tidymodels die Wahl überlassen)
knn_grid1 <- grid_regular(
  neighbors(),
  levels=10
)
knn_grid1 


# Version 2
knn_grid2 <- grid_regular(
  neighbors(range(5, 50)), 
  levels=10
)
knn_grid2

# Achtung bei der Kombination von HPs!
knn_grid3 <- grid_regular(
  neighbors(range(5, 50)), 
  weight_func(),
  levels=10
)
knn_grid3
# Hier wird ein weiter HP hinzugefügt: Die Gewichtung der Nachbarn um den Ziel-Fall.
# Der ist eine kategoriale Variable, die aus verschiednen Gewichtungstypen besteht.
# Wie zu sehen ergibt es 100 Kombinationen, die alle gefittet werden.
# Empfehlenswert in diesen Fällen: grid_latin_hypercube() anstelle von grid_regular.
# Diese zieht zufällige Stichproben aus dem grid.

# Achtung: Hier erstezt das "size"-Argument das vorherige "levels-Argument"!

knn_grid3 <- grid_latin_hypercube(
  neighbors(range(15, 15)), 
  weight_func(),
  size=10
)
knn_grid3



#	5.4	NEU: Fit the data mit tune_grid()
#<############################################################################>

# Hier nun anstelle fit_resamples" die Funktion tune_grid()

default_rs <-  
  tune_grid(
    default_wf,
    grid = knn_grid2,
    resamples = default_cv,
    control = control_resamples(save_pred = TRUE, verbose=TRUE))



# 5.5	Evaluate the models
#<############################################################################>

default_rs %>% 
  collect_metrics()
# Wie zu sehen, wurde für JEDEN Nachbaren-Wert das Modell über 10 CV folds gefittet
# Die Metriken zeigen die *durchschnittlichen* performance-Werte über die 10 folds
# Es zeigt sich: Der roc_auc wird immer besser:

default_rs %>% 
  autoplot()

# Wie man sieht, wird der Fit immer besser, je simpler (hohe Anzahl von Nachbarn) 
# das Modell wird (Hinweis: Grund ist schlicht die Einfachheit / Linearität des 
# Zusammenhangs zwischen speziell balance und default!)


# Anzeige der 5 besten Modelle:
default_rs %>% 
  show_best(n = 5)





# Extraktion der Klassifikationen des besten Modells
#<############################################################################>

#wahl des besten Models
best_knn <- default_rs %>% 
  select_best(metric="roc_auc")
best_knn
#Hinweis. Dieses Objekt dient zur Informtion über die beste Nachbarn-Zahl und wird
# im Schritt unten angesprochen/verwendet



# Confusion matrix
#<--------------------------->
default_rs %>% 
  collect_predictions() %>% 
  filter(neighbors==50) %>%  # Auswahl des besten Modells
  conf_mat(default, .pred_class)




# ROC Kurve
#<--------------------------->
default_rs %>% 
  collect_predictions() %>% 
  filter(neighbors==50) %>%  # Auswahl des besten Modells
  group_by(id) %>%   #id ist hier die die der bootraps: jeder kriegt eine line 
  roc_curve(default, .pred_No) %>% 
  ggplot(aes(1- specificity, sensitivity, color=id))+
  geom_abline(lty = 2, color="gray80", size=1.5)+
  geom_path(show.legend = FALSE, alpha = 0.6, size = 1.2)+
  coord_equal()




# 5.6	NEU: Finalisieren (updaten) des workflows für das finale Modell
#<############################################################################>

# Hier wrid nun der alte workflow (default_wf) benutzt und das oben angelegte
# Objekt mit dem besten Modell (best_knn)

final_default_wf <- finalize_workflow(
  default_wf,   #Alten Workflow wählen (in dem noch "tune()" steht)
  best_knn)     #Objekt mit dem besten HP angeben
final_default_wf




# 5.7 The final test
#<############################################################################>
final_default_rs <- final_default_wf %>% 
  last_fit(default_split)

# Extraktion der performance Metriken
final_default_rs %>% 
  collect_metrics()


# Confusion matrix
final_default_rs %>% 
  collect_predictions() %>% 
  conf_mat(default, .pred_class) 



#ROC curve TEST
final_default_rs %>%
  collect_predictions() %>% 
  roc_curve(default, .pred_No) %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity)) +
  geom_path(size = 1) +
  geom_abline(
    lty = 2, alpha = 0.5,
    color = "gray50",
    size = 1.2 ) +
  coord_equal()+
  theme_bw()
