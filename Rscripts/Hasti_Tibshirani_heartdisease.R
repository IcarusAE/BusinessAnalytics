library(tidyverse); options(tibble.print_min = 20)
library(lubridate)
library(tidymodels)
library(ISLR)

theme_set(theme_minimal())


#Data import from the ISLR book website
#<####################################################################>
(
heart = read_csv("https://book.huihoo.com/introduction-to-statistical-learning/Heart.csv") %>% 
  select(-1) %>% 
  janitor::clean_names() %>% 
  mutate(fbs = as_factor(fbs),
         ex_ang = as_factor(ex_ang),
         thal = as_factor(thal),
         ahd = as_factor(ahd),
         chest_pain = as_factor(chest_pain),
         ca = as_factor(ca),
         rest_ecg = as_factor(rest_ecg))
  )


# Split the data
#<####################################################################>
heart_split <- initial_split(heart)
heart_training <- training(heart_split)
heart_testing <- testing(heart_split)
heart_cv <- vfold_cv(heart_training, v=6)


#Create recipe
#<####################################################################>
heart_rec <- recipe(ahd ~ ., data= heart_training) %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_normalize(all_numeric_predictors())






#<####################################################################>
# LOGISTIC REGRESSION
#<####################################################################>
#Model-specific workflow from here on

#Specify model
#<####################################################################>

#Logreg
logreg_spec <- logistic_reg() %>% 
  set_engine("glm")


#Add to workflow
#<####################################################################>
logreg_wf <- workflow() %>%   #Note: THe name of the workflow refers to the model spec
  add_recipe(heart_rec) %>% 
  add_model(logreg_spec)


#Fit model
#<####################################################################>

logreg_rs <-
  fit_resamples(
    logreg_wf,
    resamples = heart_cv,
    control = control_resamples(save_pred = TRUE, verbose = TRUE)
  )

#Collect metrics Training Set
#<####################################################################>
logreg_rs %>% collect_metrics()


#Evaluate on TEST set
#<####################################################################>

logreg_test_rs <- logreg_wf %>% 
  last_fit(heart_split)


#Collect metrics TEST Set
#<####################################################################>
logreg_test_rs %>% collect_metrics()


# Confusion matrix TEST set
#<####################################################################>
logreg_test_rs %>% 
  unnest(.predictions) %>% 
  conf_mat(ahd, .pred_class)




#<####################################################################>
# DECISION TREE
#<####################################################################>

#Decision tree
tree_spec <- decision_tree(
  cost_complexity = tune()) %>%
  set_mode("classification") %>%    
  set_engine("rpart")


#Add to workflow
#<####################################################################>
tree_wf <- workflow() %>%   #Note: THe name of the workflow refers to the model spec
  add_recipe(heart_rec) %>% 
  add_model(tree_spec)



#Generate grid for decision tree
#<####################################################################>
tree_grid <- grid_regular(cost_complexity(range = c(-3, 1)), levels = 50)


#Tune model
#<####################################################################>

doParallel::registerDoParallel()
set.seed(123)
tree_rs <- tune_grid(
  tree_wf,  #Auch hier: Das modell wird temporär angefügt
  resamples = heart_cv,
  grid = tree_grid,
  control = control_resamples(save_pred = TRUE, verbose=TRUE)
)


#Collect metrics
#<####################################################################>

tree_rs %>% collect_metrics()
autoplot(tree_rs) +
  theme_light()

#Select best tree
best_tree <- select_best(tree_rs, "accuracy")

# Finalize workflow
final_tree_wf <- tree_wf %>% 
  finalize_workflow(best_tree)

#Show tree on training data
#<####################################################################>
# Trainin on whole training data
tree_trainfit <- final_tree_wf %>% 
  fit(heart_training)

library(rpart.plot)
tree_trainfit %>%
  extract_fit_engine() %>%
  rpart.plot()
#Looks rather different then in the ISLR book! One explanation could be that
#Hastie and Tibshirani do CV on the whole data



#Evaluate on TEST set
#<####################################################################>

tree_test_rs <- final_tree_wf %>% 
  last_fit(heart_split)


#Collect metrics TEST Set
#<####################################################################>
tree_test_rs %>% collect_metrics()


# Confusion matrix TEST set
#<####################################################################>
tree_test_rs %>% 
  unnest(.predictions) %>% 
  conf_mat(ahd, .pred_class)





