library(tidyverse)
library(tidytext)
library(tidymodels)
theme_set(theme_bw())


# 4.1 Import der Daten
#<############################################################################>

library(ISLR)
data("Default")
default <- as_tibble(Default)

default <- default %>% 
  mutate(default = fct_relevel(default, c("Yes", "No")))


# 4.2 Split the data
#<############################################################################>

set.seed(123)
default_split <- initial_split(default, strata = default)
default_train <- training(default_split)


default_cv <- vfold_cv(default_train)

# 4.3 Create the recipe
#<############################################################################>

default_rec <- recipe(default ~ ., data=default_train) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_dummy(all_nominal_predictors())

#Check
default_rec %>% 
  prep() %>% 
  juice()


# 4.4 Specify the model
#<############################################################################>
logreg_spec <- logistic_reg() %>% 
  set_engine("glm") 


# 4.5 Add to workflow
#<############################################################################>

default_wf <- workflow() %>% 
  add_recipe(default_rec) %>% 
  add_model(logreg_spec) 


#	4.6 Fit the Data
#<############################################################################>

default_rs <- default_wf %>% 
  fit_resamples(resamples = default_cv,
                metrics = metric_set(accuracy,roc_auc, sens, precision, f_meas, kap),
                control = control_resamples(save_pred = TRUE, verbose=TRUE))


# 4.7 Evaluieren der Klassifikationsgüte
#<############################################################################>

default_rs %>% 
  collect_metrics()


# 4.7.1 Extraktion der Klassifikationen
#<====================================================>

default_rs %>% 
  collect_predictions() 


# 4.7.2 Confusion matrix
#<====================================================>
default_rs %>% 
  collect_predictions() %>% 
  conf_mat(default, .pred_class)

default_rs %>% 
  unnest(.predictions) %>% 
  conf_mat(default, .pred_class)


# 4.7.3 Plot der ROC Kurve
#<====================================================>
default_rs %>% 
  collect_predictions() %>% 
  group_by(id) %>%   #id ist hier die die der bootraps: jeder kriegt eine line 
  roc_curve(default, .pred_Yes) %>% 
  ggplot(aes(1- specificity, sensitivity, color=id))+
  geom_abline(lty = 2, color="gray80", size=1.5)+
  geom_path(show.legend = FALSE, alpha = 0.6, size = 1.2)+
  coord_equal()


# 4.8 The final test
#<############################################################################>

# 4.8.1 Training und test
#<====================================================>
default_final <- default_wf %>% 
  last_fit(
    default_split,
    metrics = metric_set(accuracy,roc_auc, sens, precision, f_meas, kap)
    )


# 4.8.2 Extraktion der performance Metriken
#<====================================================>
default_final %>% 
  collect_metrics()


# 4.8.3 Confusion matrix
#<====================================================>
default_final %>% 
  collect_predictions() %>% 
  conf_mat(default, .pred_class) 


# 4.8.4 ROC curve
#<====================================================>
default_final %>%
  collect_predictions() %>% 
  roc_curve(default, .pred_Yes) %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity)) +
  geom_line(size = 1.5) +
  geom_abline(
    lty = 2, alpha = 0.5,
    color = "gray50",
    size = 1.2 ) +
  coord_equal()+
  theme_bw()
