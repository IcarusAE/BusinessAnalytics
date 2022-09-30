library(tidyverse); options(tibble.print_min = 20)
library(lubridate)
library(tidymodels)

theme_set(theme_minimal())



# load the Pima Indians dataset from the mlbench dataset
library(mlbench)
data(PimaIndiansDiabetes)
# rename dataset to have shorter name because lazy
diabetes_orig <- PimaIndiansDiabetes

diabetes_clean <- diabetes_orig %>%
  mutate_at(vars(triceps, glucose, pressure, insulin, mass), 
            function(.var) { 
              if_else(condition = (.var == 0), # if true (i.e. the entry is 0)
                      true = as.numeric(NA),  # replace the value with NA
                      false = .var # otherwise leave it as it is
              )
            })

set.seed(234589)
diabetes_split <- initial_split(diabetes_clean, 
                                prop = 3/4)

diabetes_train <- training(diabetes_split)
diabetes_test <- testing(diabetes_split)

diabetes_cv <- vfold_cv(diabetes_train)

# define the recipe
diabetes_recipe <- 
  recipe(diabetes ~ pregnant + glucose + pressure + triceps + 
           insulin + mass + pedigree + age, 
         data = diabetes_clean) %>%
  step_normalize(all_numeric()) %>%
  step_impute_knn(all_predictors())

rf_spec <- 
  rand_forest(
    mtry = tune()
  ) %>%
    set_engine("ranger", importance = "impurity") %>%
    set_mode("classification") 


# set the workflow for RF
rf_wf <- workflow() %>%
  add_recipe(diabetes_recipe) %>%
  add_model(rf_spec)


# Generate HP grid
rf_grid <- expand.grid(mtry = c(3, 4, 5))

# Tune model
rf_tune_rs <- rf_wf %>%
  tune_grid(
    resamples = diabetes_cv, 
    grid = rf_grid, 
    metrics = metric_set(accuracy, roc_auc),
    control = control_resamples(save_pred = TRUE, verbose=TRUE))
  

#collect metrics
rf_tune_rs %>%
  collect_metrics()


#Select best HP
best_rf <- rf_tune_rs %>%
  select_best(metric = "accuracy")

#Finalize the workflow
final_rf_wf <- rf_wf %>%
  finalize_workflow(best_rf)


#Run and evaluate on test fit
(rf_fit <- final_rf_wf %>%
  last_fit(diabetes_split))

#Evaluate on test set
rf_fit %>% 
  collect_metrics()


# generate predictions from the test set
(test_predictions <- rf_fit %>% 
    collect_predictions() )

#Use predictions from the test set to create confusion matrix
test_predictions %>% 
  conf_mat(truth = diabetes, estimate = .pred_class)


#Final simple fit on ALL data (training + test!)
final_model <- fit(final_rf_wf, diabetes_clean)


# Create new data (simulation)
new_woman <- tribble(~pregnant, ~glucose, ~pressure, ~triceps, ~insulin, ~mass, ~pedigree, ~age,
                     2, 95, 70, 31, 102, 28.2, 0.67, 47)

# Now use the final_model with new data
predict(final_model, new_data = new_woman) %>% 
  bind_cols(new_woman)


