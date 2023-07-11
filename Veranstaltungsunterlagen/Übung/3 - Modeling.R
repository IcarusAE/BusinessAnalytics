library(tidyverse)
theme_set(theme_light())


#<#############################################################################>
# LS Regression----
#<#############################################################################>


# Import Sales Data
library(ISLR)

ad_data <-   
  read_csv("https://www.statlearning.com/s/Advertising.csv") %>% 
  select(-1)

ad_data


# EDA
#<#############################################################################>

# Scatterplot mit "radio" und "sales" und einer Regressionsgerade

ad_data %>% 
  ggplot(aes(x = radio, y=sales))+
  geom_point()+
  geom_smooth(method="lm", se=FALSE)






# Modell
#<#############################################################################>

# Ziele / Inhalte
# 1) Traditionelles Training eines LS models
# 2) Extraktion von predicted values und prediction errors (mittels broom package)
# 3) Illustration der performance Metriken (MAE, MSE etc. )
# 4) Out-of-sample prediction mittels predict()-Funktion



lin_reg <- lm(sales ~ TV + newspaper + radio,
              data = ad_data)
summary(lin_reg)

plot(lin_reg)

library(broom)
# 
# tidy()
# glance()
# augment()

tidy(lin_reg)






# Performance mit broom's glance() und augment() Funktionen
#<#############################################################################>

# R-Quadrat
glance(lin_reg)




#Extraktion der predicted values und prediction errors
model_rs <- augment(lin_reg, ad_data) %>% 
  select(TV, radio, newspaper, sales, .fitted, .resid)

model_rs


# Mean absolute error (MAE): Mittelwert des Betrags der Fehler
MAE <- model_rs %>% 
  summarise(mae = mean(abs(.resid)))
MAE

# Mean squared error (MSE): Mittelwert der quadrierten Fehler
MSE <- model_rs %>% 
  mutate(error_sq = .resid^2) %>% 
  summarise(mse = mean(error_sq))
MSE

# Root mean squared error (RMSE): Wurzel aus MSE 
RMSE <- MSE %>% 
  summarise(rmse = sqrt(mse))
RMSE

# Mean absolute percentage error
MAPE <- model_rs %>% 
  rowwise() %>% 
  summarise(ind_dev_prop = abs(.resid)/abs(sales)) %>% 
  ungroup() %>% 
  summarise(mape = (mean(ind_dev_prop)*100))
MAPE


# Finale Frage: Gibt es systematische Fehler?
model_rs %>% 
  ggplot(aes(sales, .fitted))+
  geom_point()+
  geom_smooth(method="lm")







# Out-of-sample prediction: Neue Daten voraussagen
#<#############################################################################>

# Fiktionales Datenset mit neuen X-Werten anlegen

future_data <- tribble(~TV, ~radio, ~newspaper,
                       140, 24, 80,
                       5,   35, 45,
                       250,   42, 15)
future_data



future_data <- predict(lin_reg, future_data, interval = "predict") %>% 
  bind_cols(future_data, .)


# Integration mit dem ursprünglichen Trainingsmodell
ad_data %>%
  ggplot(aes(TV, radio))+
  geom_point(aes(colour=sales), size=2.5)+
  scale_color_gradient(low="green",
                        high = "blue")+
  geom_point(data = future_data, shape=15, size=5, aes(color=fit))





#<#############################################################################>
# GAMs----
#<#############################################################################>


library(ISLR)

# Load the Wage dataset
data(Wage)

wage = as_tibble(Wage)

wage %>% 
  ggplot(aes(age, wage))+
  geom_point(alpha=.3)+
  geom_smooth()


# GAM fitten mit Alter als nicht-linearem Prädiktor
library(mgcv)
model <- gam(wage ~ s(age) + s(year, k=5) + education + race + maritl, 
                   data = wage,
             family= poisson)
summary(model)




#Visualisierung einer größeren Anzahl von Scatterplots
library(GGally)
ad_data %>% 
  ggpairs(
    lower = list(continuous = "smooth_loess"),
  )






#<#############################################################################>
# Logistische Regression----
#<#############################################################################>


# Import Sales Data
#<#############################################################################>
library(ISLR)
data("Default")

# Als tibble 
default <- as_tibble(Default) 



# EDA
#<#############################################################################>

default %>% 
  ggplot(aes(default))+
  geom_bar()

default %>% 
  count(default)

# Rekonstruktion des plots auf S. 131 im Buch
default %>% 
  #sample_n(3000) %>% 
  ggplot(aes(x = balance, y=income, col=default, shape=default))+
  geom_point()+
  scale_shape_manual(values = c(1, 3)) +
  scale_color_manual(values = c("deepskyblue", "red"))



# Logistische Regression
#<#############################################################################>

options(scipen= 9)

default <- default %>% 
  mutate(income_rsc = income/1000)

logit_model <- glm(default ~ student + balance + income_rsc, 
                   data = default,
                   family=binomial(link="logit"))
summary(logit_model)
tidy(logit_model) # Analog über tidy()


# Vorhersage mit dem Modell treffen
predictions <- predict(logit_model, newdata = default, type = "response")  %>% 
  as_tibble() %>% 
  rename(pvalue = value)
  #Hinweis: type=response führt dazu dass p's in die Daten geschrieben werden


# Den predicted p-value in die Daten schreiben
default_aug1 <- bind_cols(predictions, default) 
   

default_aug1



# Klassifikation manuell vornehmen
default_aug1 <- default_aug1 %>% 
  mutate(.pred_class = case_when(pvalue > .5 ~ "Yes",
                                 TRUE ~ "No"))

# confusion matrix
( 
  conf_mat <- default_aug1 %>% 
  count(default, .pred_class) %>% 
  spread(.pred_class, n)
  )

#Labeling
(TN <- conf_mat[1,2])
(TP <- conf_mat[2,3])
(FN <- conf_mat[2,2])
(FP <- conf_mat[1,3])


# Accuracy: Gesamtgenauigkeit
(accuracy <- (TP + TN)/(TP+TN+FP+FN))

# Sensitivität / Recall: Wie viele "defaulter" werden entdeckt?
(recall <- TP / (TP + FN))

# Spezifität: Wie viele Nicht-defaulter werden entdeckt?
(specificity <- TN / (TN + FP))

# Precision: Wie hoch ist der Anteil der entdeckten defaulter an den als-defaulter-klassifizierten?
(precision <- TP / (TP + FP))

#F1 score
(F1score <- 2* (precision * recall / (precision + recall) ) )






# Generierung der logistischen Funktion und mehrerer TP/FP -Kombinationen
# entlang verschiedener thresholds
#<########################################################################>

logit_model <- glm(default ~ balance, 
                   data = default,
                   family=binomial(link="logit"))

# Den predicted p-value in die Daten schreiben
default_aug1 <- bind_cols(predictions, default) 




# Klassifikation manuell vornehmen
default_aug1 <- default_aug1 %>% 
  mutate(.pred_class = case_when(pvalue > .90 ~ "Yes",
                                 TRUE ~ "No"))
# confusion matrix
(
  conf_mat <- default_aug1 %>% 
    count(default, .pred_class) %>% 
    spread(.pred_class, n)
)
#Labeling
TP <- as_tibble(conf_mat[2,3]) %>% rename(TP = Yes)
FP <- as_tibble(conf_mat[1,3]) %>% rename(FP = Yes)
TN <- conf_mat[1,2]
FN <- conf_mat[2,2]


# Sensitivität / Recall: Wie viele "defaulter" werden entdeckt?
Sens <- TP / (TP + FN)
# False positive rate: Wie viele Fehlalarme?
FPR <- 1 - (TN / (TN + FP))


# In Daten schreiben
roc005 = tibble(Sens, FPR) %>% 
  rename(Sens = Yes, FPR = No) %>% 
  mutate(p = .005)


ROC <- bind_rows(roc005, roc01, roc05,roc1,roc2,roc3,roc4,roc5,roc7,roc8, roc9,roc95)

ROC %>% 
  ggplot(aes(FPR, Sens, label=p))+
  geom_point()+
  geom_line()+
  geom_abline(lty = 2, color="gray80", size=1)+
  labs(x = "False positive rate", y="Sensitivity")+
  xlim(0,1)+
  ylim(0,1)+
  ggrepel::geom_text_repel()

