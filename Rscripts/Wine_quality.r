library(tidyverse)
library(tidymodels)
library(janitor)
install.packages("here")
theme_set(theme_light())



#<#############################################################################>
## Data import----
#<#############################################################################>

raw_wine_white <- read_csv("https://github.com//thebioengineer//TidyX//raw//master//TidyTuesday_Explained//085-Tidy_Models_9//winequality_white.csv")%>%
  mutate(
    wine_type = "white"
  )

raw_wine_red <- read_csv("https://github.com//thebioengineer//TidyX//raw//master//TidyTuesday_Explained//085-Tidy_Models_9//winequality_red.csv") %>% 
  mutate(
    wine_type = "red"
  )

raw_wine <- bind_rows(raw_wine_white,raw_wine_red) %>% 
  clean_names()


#<#############################################################################>
## EDA----
#<#############################################################################>

## Simples Histogramm
raw_wine %>%
  ggplot(aes(x = quality)) +
  geom_histogram() + 
  facet_wrap(~wine_type)


## Netter density plot mittels pivot_longer
raw_wine %>% 
    mutate(wine_idx = seq_len(n())) %>% 
  pivot_longer(
    cols = -c(wine_idx,wine_type),
    names_to = "measure",
    values_to = "measurement") %>% 
  ggplot(aes(x = measurement))+
  geom_density() + 
  facet_wrap(
    measure ~ wine_type,
    scales = "free",
    ncol = 4
  )




#<#############################################################################>
## Split data----
#<#############################################################################>  

set.seed(42)
init_split <- initial_split(raw_wine, strat = "wine_type")
train <- training(init_split)
test <- testing(init_split)


set.seed(42)
cv_folds <- vfold_cv(
  data = train, 
  v = 5
) 
cv_folds



#<#############################################################################>  
## Create recipes----
#<#############################################################################>  

# Hier werden jetzt 2 verschiedene Recipes generiert

## Recipe #1: die beiden "Sulfur"-Variablen werden logarithmiert
log_sulfer_recipe <- recipe(quality ~ ., data = train) %>%
  step_log(contains("sulfur")) %>% 
  step_dummy(wine_type,one_hot = TRUE)

## Recipe #2. Die beiden Variablen werden standardisiert (warum nicht beides?)
scaling_sulfur_recipe <- recipe(quality ~ .,  data = train) %>%
  step_scale(contains("sulfur")) %>% 
  step_dummy(wine_type,one_hot = TRUE)




#<#############################################################################>  
## Specify the Model 
#<#############################################################################>  
# 1) Linear Regression
# 2) Random Forest
# 3) xgboost Regression


## (1) Standard regression
lm_spec <- linear_reg() %>% 
  set_engine("lm") %>%
  set_mode("regression") 

## (2) Random forest (1 HP)
rf_spec <- rand_forest(
  mtry = tune()
) %>%
  set_mode("regression") %>%
  set_engine("randomForest", importance = TRUE) 
# Importance =TRUE ist fuer die vip() Funktion später wichtig

## (3) XGBoost
xgb_spec <- boost_tree(
  trees = tune(),
  mtry = tune(),
  tree_depth = tune(),
  learn_rate = .01
) %>%
  set_mode("regression") %>% 
  set_engine("xgboost",importance = TRUE)




#<#############################################################################>  
## Creating Workflow Set----
#<#############################################################################>  

# Jetzt kommt das Novum: Die 2 Recipes und 3 model specs werden in ein workflow
# set integriert

wf_set <-workflow_set(
  preproc = list(log_sulfer_recipe, scaling_sulfur_recipe),
  models = list(lm_spec, rf_spec, xgb_spec),
  cross = TRUE
)
wf_set


#<#############################################################################>  
## Tune and fit the workflows---
#<#############################################################################>  

# A c h t  u n g : Dauert 22min.
# Hab es dher als RDS gespeichert. Dies ggfls. laden, andstatt die pipeline
# laufen zu lassen
fit_workflows <- readRDS(file = url("https://github.com/IcarusAE/BusinessAnalytics/raw/main/Rscripts/wine_workflow.rds"))


# doParallel::registerDoParallel()
# start_time <- Sys.time()
# 
# fit_workflows <- wf_set %>%  
#   workflow_map(        #Zentrale (neue) Funktion
#     seed = 22,         # für die Replizierbarkeit 
#     fn = "tune_grid",
#     grid = 10,        #siehe unten **
#     resamples = cv_folds
#   )
# end_time <- Sys.time()
# end_time - start_time
# 
# doParallel::stopImplicitCluster()

#**Hier die Billig-version: anstatt ein grid zu machen, nehmen sie einen
#  festen range. 





#<#############################################################################>  
## Evaluate models----
#<#############################################################################>  

# plot
autoplot(fit_workflows)

#Anforderung aller metrcs
collect_metrics(fit_workflows)



#Darstellung sortiert. Ergebnis recipe 1 + XGBoost gewinnt
rank_results(fit_workflows, rank_metric = "rmse", select_best = TRUE)
# BTW: Recipe 2 war exakt genauso gut! Das heißt, Logarithmierung hat nichts
# bewirkt


# ## Extract the best workflow

metric <- "rmse"

best_wf_id <- fit_workflows %>%
  rank_results(
    rank_metric = metric,
    select_best = TRUE
  ) %>%
  dplyr::slice(1) %>%
  pull(wflow_id)

wf_best <- extract_workflow(fit_workflows, id = best_wf_id)



## Extract tuning results from workflowset
#<#############################################################################>  

# Sehr unschöner code. Ich weiß nicht ob das nicht mittlerweile eleganter geht
# So wie ich das verstehe, ziehen sie erst alle XGBoost modelle aus dem set-Objekt
# um im nächsten Schritt mittels der altbekannten select_best() Funktion dann
# das beste daraus auszuwählen
wf_best_tuned <- fit_workflows[fit_workflows$wflow_id == best_wf_id,
                               "result"][[1]][[1]]
wf_best_tuned


collect_metrics(wf_best_tuned) %>% 
  filter(.metric=="rmse")

autoplot(wf_best_tuned) +
  geom_line()

select_best(wf_best_tuned, "rmse")


## Fit the final model
#<#############################################################################>  
wf_best_final <- finalize_workflow(wf_best, select_best(wf_best_tuned, "rmse"))

doParallel::registerDoParallel(cores = 8)
wf_best_final_fit <- wf_best_final %>% 
  last_fit(
    split = init_split
  )
doParallel::stopImplicitCluster()

wf_best_final_fit



## Extract Predictions on Test Data and evaluate model
#<#############################################################################>  

# Metriken: Sieht gut aus
wf_best_final_fit %>% 
  collect_metrics()

#Hinzuaddieren der predicted values zum testset
fit_test <- wf_best_final_fit %>% 
  collect_predictions()


#Boxplot, in dem die predicted values mit den wahren Werten verglichen werden
# (Streuung in einer Box zeigt die Streuung der predicted values)
fit_test %>% 
  bind_cols(test %>% 
              select(-quality)) %>% #Hinzuaddieren der predicted values zu den test daten
  ggplot() +
  aes(
    x = factor(quality),
    y = .pred
  ) +
  geom_boxplot() + 
  geom_jitter(alpha = .3, width=.1) + 
  facet_wrap(~ wine_type)


## confusion matrix
fit_test %>% 
  mutate(
    .pred_int = round(.pred) 
    ) %>% 
  select(quality, .pred_int) %>% 
  table()



fit_test %>% 
  mutate(
    .pred_int = round(.pred)
   ) %>% 
  ggplot() +
  aes(
    x = factor(quality),
    y = .pred_int
  ) +
  geom_violin()



## Variable importance plot
library(vip)
extract_workflow(wf_best_final_fit) %>%
  extract_fit_parsnip() %>%
  vip(geom = "col")
