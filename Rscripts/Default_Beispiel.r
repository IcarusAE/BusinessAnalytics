library(tidyverse)
library(tidytext)
library(tidymodels)
theme_set(theme_bw())


# Import der Daten
#<############################################################################>

library(ISLR)
data("Default")
default <- as_tibble(Default)


# Split the data
#<############################################################################>

set.seed(123)
default_split <- initial_split(default, strata = default)
default_train <- training(default_split)
default_test <- testing(default_split)

default_cv <- vfold_cv(default_train)

# Create recipe
#<############################################################################>

default_rec <- recipe(default ~ ., data=default_train) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_dummy(all_nominal_predictors())

#Check
default_rec %>% 
  prep() %>% 
  juice()

# Specify the model
#<############################################################################>
logreg_spec <- logistic_reg() %>% 
  set_engine("glm") 


# Add to workflow
#<############################################################################>

default_wf <- workflow() %>% 
  add_recipe(default_rec) %>% 
  add_model(logreg_spec) 


#	Fit the Data
#<############################################################################>

default_rs <- default_wf %>% 
  fit_resamples(resamples = default_cv,
                control = control_resamples(save_pred = TRUE, verbose=TRUE))


# Evaluate the Model in the Assessment Set
#<############################################################################>

default_rs %>% collect_metrics()


# Extraktion der Klassifikationen
#<############################################################################>

# Confusion matrix
#<--------------------------->
default_rs %>% 
  collect_predictions() %>% 
  conf_mat(default, .pred_class)

default_rs %>% 
  unnest(.predictions) %>% 
  conf_mat(default, .pred_class)


# ROC Kurve
#<--------------------------->
default_rs %>% 
  collect_predictions() %>% 
  group_by(id) %>%   #id ist hier die die der bootraps: jeder kriegt eine line 
  roc_curve(default, .pred_No) %>% 
  ggplot(aes(1- specificity, sensitivity, color=id))+
  geom_abline(lty = 2, color="gray80", size=1.5)+
  geom_path(show.legend = FALSE, alpha = 0.6, size = 1.2)+
  coord_equal()


# The final test
#<############################################################################>
default_final <- default_wf %>% 
  last_fit(default_split)

# Extraktion der performance Metriken
default_final %>% collect_metrics()


# Confusion matrix
default_final %>% 
  collect_predictions() %>% 
  conf_mat(default, .pred_class) 


#ROC curve
default_final %>%
  collect_predictions() %>% 
  roc_curve(default, .pred_No) %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity)) +
  geom_line(size = 1.5) +
  geom_abline(
    lty = 2, alpha = 0.5,
    color = "gray50",
    size = 1.2 ) +
  coord_equal()+
  theme_bw()
