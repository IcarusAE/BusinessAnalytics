library(tidyverse)
library(tidymodels)
library(ISLR)


# 2.1 Split the data----
#<############################################################################>

advertising_data <-   
  read_csv("https://www.statlearning.com/s/Advertising.csv") %>% 
  select(-1)



# 2.1.1 Kleine Datensätze:"TT only" und Bootstrapping----
#<=======================================================>
set.seed(123)
advertising_split = initial_split(advertising_data, prop=.5)

advertising_split

# ziehen der Trainings- und Testdaten aus dem split-Objekt
advertising_train = training(advertising_split)
advertising_test = testing(advertising_split)




# 2.1.2 Große Datensätze: kfold crossvalidation----
#<=======================================================>

# Hier wird aus dem oben angelegten Training Set noch mal folds gebildet
advertising_cv <- vfold_cv(advertising_train, v=5)

advertising_cv


# 2.1.3 Bootstrapping als Approximation von CV in kleinen samples----
#<=======================================================>

advertising_boot = bootstraps(advertising_train, times = 5)

advertising_boot





# 2.2 Create the recipe: Set up the Data and Model Formula----
#<############################################################################>


# 2.2.1 Generieren des Recipes
#<=======================================================>

advertising_rec <- recipe(sales ~. , data = advertising_train)%>%
  step_normalize(all_predictors())

advertising_rec


# 2.2.2 Prep(), bake() und juice()----
#<=======================================================>

# Methode 1: bake() + Data set bestimmen (Kann auch das test set sein)
advertising_rec %>% 
  prep() %>% 
  bake(new_data= advertising_train)

# Methode 2: juice() (nimmt automatisch die Trainingsdaten)
advertising_rec %>%                              
  prep() %>%   
  juice()            


# 2.3 Model specification----
#<############################################################################>

lm_spec <- linear_reg() %>%
  set_engine("lm")




# 2.4 Fit the data----
#<############################################################################>

# 2.4.1 Einfaches Fitten auf einem einzigen Datensatz----
#<=======================================================>

# Hier wird die model spec über die Gesamtdaten gefittet
lm_spec %>% 
  fit(sales ~ ., data = advertising_data) %>% 
  broom::tidy()



# 2.4.2 Bei trainings- vs. testdata only ("TT only")----
#<=======================================================>

# 2.4.2.1 Training----

# Hier wird die last_fit() angewandet, um das Modell auf die Trainingsdaten zu fitten
# und an den Testdaten zu evaluieren. Ergebnis ist ein tibble mit vielen Infos
lm_fit_tt <- last_fit(lm_spec, 
                      advertising_rec,
                      advertising_split)

lm_fit_tt



# 2.4.2.2 Extraktion interessanter Informationen----

# Aus diesem tibble könne die performance Metriken extrahiert werden
lm_fit_tt %>% 
  collect_metrics()


# ....und die Predictions der Testdaten
lm_fit_tt %>% 
  collect_predictions()


# Visualisierung der Vorhersage (im hohen Bereich hat das Modell Probleme)
lm_fit_tt %>% 
  collect_predictions() %>% 
  ggplot(aes(sales, .pred))+
  geom_point()+
  geom_abline(color="red")+
  theme_light()

# Extraktion der Parameter 
lm_fit_tt %>% 
  extract_fit_parsnip() %>% 
  tidy()



# 2.4.3 Crossvalidation und Bootstrapping----
#<=======================================================>

# 2.4.3.1 Training----

lm_cv_rs <-    #rs = results
  fit_resamples(
    lm_spec,
    advertising_rec,
    resamples = advertising_cv,
    control = control_resamples(save_pred = TRUE, verbose = TRUE)
  )

lm_cv_rs



# 2.4.3.2 Extraktion relevanter Informationen----

# Einzeln
lm_cv_rs %>% 
  unnest(.metrics) %>% 
  filter(.metric=="rsq") %>% 
  select(id, .metric, .estimate)

# Gemittelt über die 5 folds
lm_cv_rs %>% 
  collect_metrics()


# Extraktion der Predictions
lm_cv_rs %>% 
  collect_predictions()
# Hinweis: Das sind die Preditions aus den 5x20 Test sets




# 2.5 The final test----
#<############################################################################>

# 2.5.1 Fitting des Modells----

# Ist identisch zum TT-only Prozess unter 2.4.2
lm_fit_tt <- last_fit(lm_spec, 
                      advertising_rec,
                      advertising_split)

# 2.5.2 Extraktion der Metriken aus dem Test Set----

lm_fit_tt %>% 
  collect_metrics()


# 2.5.3 Extraktion der Predictions um Test Set----

# Version 1
lm_fit_tt %>% 
  collect_predictions()

# Version 2 über predict()
lm_spec %>% 
  fit(sales ~ ., data = advertising_train) %>%  
  predict(., new_data = advertising_test) %>% 
  bind_cols(advertising_test)




