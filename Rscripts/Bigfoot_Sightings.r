library(tidyverse)
library(tidymodels)



bigfoot_raw <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-09-13/bigfoot.csv')


# Target als binaere Variable anlegen
bigfoot <-
  bigfoot_raw %>%
  filter(classification != "Class C", !is.na(observed)) %>%
  mutate(
    classification = case_when(
      classification == "Class A" ~ "sighting",
      classification == "Class B" ~ "possible"
    )
  )



# Vor-Analyse mit log-Odds

library(tidytext)
library(tidylo)

bigfoot %>%
  unnest_tokens(word, observed) %>%
  count(classification, word) %>%
  filter(n > 100) %>%
  bind_log_odds(classification, word, n) %>%
  arrange(-log_odds_weighted)


# Split the data
#<#############################################################################>
set.seed(123)
bigfoot_split <-
  bigfoot %>%
  select(observed, classification) %>%
  initial_split(strata = classification)

bigfoot_train <- training(bigfoot_split)
bigfoot_test <- testing(bigfoot_split)

set.seed(234)
bigfoot_folds <- vfold_cv(bigfoot_train, strata = classification)
bigfoot_folds



library(textrecipes)


# Create Recipe
#<#############################################################################>
bigfoot_rec <-
  recipe(classification ~ observed, data = bigfoot_train) %>%
  step_tokenize(observed) %>%
  step_tokenfilter(observed, max_tokens = tune()) %>% #Von mir hinzugefuegt**
  step_tfidf(observed) %>% 
  step_normalize(all_predictors())


# Anmerkung. Sie setzt die Anazhl der tokens auf 2000 und sagt, dass ein so hoher Wert
# oft nötig ist, wenn es sich um natural language handelt.
# Gleichzeitig werden die Token mittels step_tfidf *gewichtet*--dadurch bekommen
# "unique" tokens einen höheren Einfluss (man muss also nix filtern).
# Konkret bewirkt das (siche nächste line), dass anstelle es N eines Wortes der TF-IDF-
# Wert genommen wird.

# ** ich wollte mal aus proberieren, wie das mit dem N tokens als HP tuning
# geht. 

bigfoot_rec %>% prep() %>% juice()


# Model spec
#<#############################################################################>
glmnet_spec <- 
  logistic_reg(mixture = 1, penalty = tune()) %>%
  set_engine("glmnet")


# Workflow
#<#############################################################################>

bigfoot_wf <- workflow(bigfoot_rec, glmnet_spec)


# Create grid
#<#############################################################################>

# Diesen Teil hab ich selbst hinzugefuegt, um den Code konsistent zu halten. Sie 
# hat den grid-command in die tune_grid-Funktion eingefuegt (siehe nächste 
# Pipeline)--geht also auch so!

bigfoot_grid = tibble(penalty = 10 ^ seq(-3, 0, by = 0.3))

bigfoot_token_grid = seq(1000, 3000, by=500)

# Außerdem tune ich mal die 
bigfoot_grid <-expand.grid(
  max_tokens = seq(500, 1500, by=250),
  penalty = 10 ^ seq(-3, 0, by = 0.6)
)

# Run model
#<#############################################################################>

# Anmerkung. hier habe ich mit dem range der range der N tokens rumgespielt und 
# interessanterweise waren 1000 tokens völlig ausreichend, weil die LASSO
# penalty die unnuetzen eh rauswirft!

doParallel::registerDoParallel()
start_time <- Sys.time()
set.seed(123)
bigfoot_res <- tune_grid(
    bigfoot_wf, 
    bigfoot_folds, 
    grid = bigfoot_grid
  )
end_time <- Sys.time()
end_time - start_time



autoplot(bigfoot_res) +
  theme_minimal()


bigfoot_res %>%
  show_best("accuracy") 
  

# Workflow updaten und neu laufen lassen
#<#############################################################################>

bigfoot_final <-
  bigfoot_wf %>%
  finalize_workflow(
    select_by_pct_loss(bigfoot_res, desc(penalty), metric = "roc_auc")
  ) %>%
  last_fit(bigfoot_split)

bigfoot_final


# Collect metrics

collect_metrics(bigfoot_final)


collect_predictions(bigfoot_final) %>%
  conf_mat(classification, .pred_class)  


# VIP plot
#<#############################################################################>

# Anm. Sie listet im Video einfach nur die VIP-Werte auf. Ich hab ihren Code aus
# dem "the office"-Video hier verwendet um einen plot zu machen

library(vip)
bigfoot_final %>%
  extract_fit_engine() %>%
  vi() %>%
  slice(1:20) %>% 
  mutate(Variable = str_remove_all(Variable, "tfidf_observed_")) %>% 
  mutate(
    Importance = abs(Importance),
    Variable = fct_reorder(Variable, Importance)
  ) %>%
  ggplot(aes(x = Importance, y = Variable, fill = Sign)) +
  geom_col() +
  scale_x_continuous(expand = c(0, 0)) +
  labs(y = NULL)+
  theme_light()

