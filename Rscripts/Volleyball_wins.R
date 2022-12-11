library(tidyverse)
library(tidymodels)

theme_set(theme_minimal())



## Data import----
#<#############################################################################>
vb_matches <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-05-19/vb_matches.csv', guess_max = 76000)

vb_matches



## Data wrangling / Proprocessing--
#<#############################################################################>
vb_parsed <- vb_matches %>%
  transmute(
    circuit,
    gender,
    year,
    w_attacks = w_p1_tot_attacks + w_p2_tot_attacks,
    w_kills = w_p1_tot_kills + w_p2_tot_kills,
    w_errors = w_p1_tot_errors + w_p2_tot_errors,
    w_aces = w_p1_tot_aces + w_p2_tot_aces,
    w_serve_errors = w_p1_tot_serve_errors + w_p2_tot_serve_errors,
    w_blocks = w_p1_tot_blocks + w_p2_tot_blocks,
    w_digs = w_p1_tot_digs + w_p2_tot_digs,
    l_attacks = l_p1_tot_attacks + l_p2_tot_attacks,
    l_kills = l_p1_tot_kills + l_p2_tot_kills,
    l_errors = l_p1_tot_errors + l_p2_tot_errors,
    l_aces = l_p1_tot_aces + l_p2_tot_aces,
    l_serve_errors = l_p1_tot_serve_errors + l_p2_tot_serve_errors,
    l_blocks = l_p1_tot_blocks + l_p2_tot_blocks,
    l_digs = l_p1_tot_digs + l_p2_tot_digs
  ) %>%
  na.omit()


winners <- vb_parsed %>%
  select(circuit, gender, year,
         w_attacks:w_digs) %>%
  rename_with(~ str_remove_all(., "w_"), w_attacks:w_digs) %>%
  mutate(win = "win")

losers <- vb_parsed %>%
  select(circuit, gender, year,
         l_attacks:l_digs) %>%
  rename_with(~ str_remove_all(., "l_"), l_attacks:l_digs) %>%
  mutate(win = "lose")

vb_df <- bind_rows(winners, losers) %>%
  mutate_if(is.character, factor)


## EDA  ----
#<#############################################################################>
vb_df %>%
  pivot_longer(attacks:digs, names_to = "stat", values_to = "value") %>%
  ggplot(aes(gender, value, fill = win, color = win)) +
  geom_boxplot(alpha = 0.4) +
  facet_wrap(~stat, scales = "free_y", nrow = 2) +
  labs(y = NULL, color = NULL, fill = NULL)


## Split data----
#<#############################################################################>
set.seed(123)
vb_split <- initial_split(vb_df, strata = win)
vb_train <- training(vb_split)
vb_test <- testing(vb_split)

set.seed(123)
vb_folds <- vfold_cv(vb_train, strata = win) #hab ich hochkopiert um konsistent zu sein

vb_folds


#Model spec----
#<#############################################################################>
xgb_spec <- boost_tree(
  trees = 1000, 
  tree_depth = tune(), 
  min_n = tune(), 
  loss_reduction = tune(),                     
  sample_size = tune(), 
  mtry = tune(),         
  learn_rate = tune(),                         
) %>% 
  set_engine("xgboost") %>% 
  set_mode("classification")

xgb_spec


# Grid anlegen----
#<#############################################################################>
xgb_grid <- grid_latin_hypercube(
  tree_depth(),
  min_n(),
  loss_reduction(),
  sample_size = sample_prop(),
  finalize(mtry(), vb_train),
  learn_rate(),
  size = 30
)

xgb_grid


## Add to workflow----
#<#############################################################################>
xgb_wf <- workflow() %>%
  add_formula(win ~ .) %>%
  add_model(xgb_spec)

xgb_wf


# Run model (ACHTUNG: Dauert sehr lange! Fast 1 h!)

# Hier daher der gefittete workflow zum Download
xgb_res <- read_rds("https://github.com/IcarusAE/BusinessAnalytics/raw/main/Rscripts/Volleyball%20workflow.RDS")


# doParallel::registerDoParallel()
# 
# set.seed(234)
# xgb_res <- tune_grid(
#   xgb_wf,
#   resamples = vb_folds,
#   grid = xgb_grid,
#   control = control_grid(save_pred = TRUE)
# )
# 
# xgb_res



# Evaluate on Training Set
#<#############################################################################>

xgb_res %>%  collect_metrics()


xgb_res %>%
  collect_metrics() %>%
  filter(.metric == "roc_auc") %>%
  select(mean, mtry:sample_size) %>%
  pivot_longer(mtry:sample_size,
               values_to = "value",
               names_to = "parameter"
  ) %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(alpha = 0.8, show.legend = FALSE) +
  facet_wrap(~parameter, scales = "free_x") +
  labs(x = NULL, y = "AUC")


## Bestes set
best_auc <- select_best(xgb_res, "roc_auc")
best_auc



## Finalize workflow
#<#############################################################################>
final_xgb <- finalize_workflow(
  xgb_wf,
  best_auc
)

final_xgb


## Variable importance plot
#<#############################################################################>
library(vip)

final_xgb %>%
  fit(data = vb_train) %>%
  pull_workflow_fit() %>%
  vip(geom = "point")

# Diese Form des codes weicht vom Skript ab. Grund ist, dass sie den Plot f?r die
# Trainingdaten haben will 
# Daher l?sst sei es in der Funktion noch mal ?ber die Trainingsdaten laufen




  
## Modell final (mit dem best set) fitten und am Test Set evaluaieren
#<#############################################################################>

final_res <- last_fit(final_xgb, vb_split)

collect_metrics(final_res)  


# Ich wiederhol hie rnoch mla den VIP um den code konsistent zu dem im Skript zu 
# machen. D.h. hier wird die Funkton auf den gefitteten worfklow angewendet 
# (der mittels extract... ) extrahier wird
final_res %>% 
  extract_fit_parsnip() %>% 
  vip::vip(num_features = 10, geom="point")



final_res %>%
  collect_predictions() %>%
  roc_curve(win, .pred_win) %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity)) +
  geom_line(size = 1, color = "midnightblue") +
  geom_abline(
    lty = 2, alpha = 0.5,
    color = "gray50",
    size = 1.2
  )
