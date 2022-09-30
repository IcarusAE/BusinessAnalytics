library(tidyverse); options(tibble.print_min = 20)
library(lubridate)
library(tidymodels)

theme_set(theme_minimal())

turbines <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-10-27/wind-turbine.csv")
turbines


turbines_df <- turbines %>%
  transmute(
    turbine_capacity = turbine_rated_capacity_k_w,
    rotor_diameter_m,
    hub_height_m,
    commissioning_date = parse_number(commissioning_date),
    province_territory = fct_lump_n(province_territory, 10),
    model = fct_lump_n(model, 10)
  ) %>%
  filter(!is.na(turbine_capacity)) %>%
  mutate_if(is.character, factor)


set.seed(123)
wind_split <- initial_split(turbines_df, strata = turbine_capacity)
wind_train <- training(wind_split)
wind_test <- testing(wind_split)

set.seed(234)
wind_folds <- vfold_cv(wind_train, strata = turbine_capacity)
wind_folds


#Specify the model
tree_spec <- decision_tree(
  cost_complexity = tune(),
  tree_depth = tune(),
  min_n = tune()
) %>%
  set_engine("rpart") %>%
  set_mode("regression")


#generate grid
tree_grid <- grid_regular(cost_complexity(), tree_depth(), min_n(), levels = 4)


#Create workflow
tree_wf <- workflow() %>% 
  add_model(tree_spec) %>% 
  add_formula(turbine_capacity ~ .)


#Tune model
doParallel::registerDoParallel()
set.seed(345)
tree_rs <- tune_grid(
  tree_spec,
  turbine_capacity ~ .,
  resamples = wind_folds,
  grid = tree_grid,
  metrics = metric_set(rmse, rsq, mae, mape),
  control = control_resamples(save_pred = TRUE, verbose=TRUE))


#Collect metrics
tree_rs %>% 
  collect_metrics()


#Plot Metrics with Autoplot
autoplot(tree_rs)+
  theme_light()

# Show the best MAPE values
tree_rs %>% 
  show_best("mape")

#Finalize workflow
final_tree_wf <- tree_wf %>% 
  finalize_workflow(select_best(tree_rs, "rmse"))



#Fit once more over the training set
final_fit <-  fit(final_tree_wf, wind_train)

#...and predict a arbitrary case in the training Set
predict(final_fit, wind_train[44,])

#Note that this fit + predict combination can also be run on hte whole data and
#help to predict completely new cases




