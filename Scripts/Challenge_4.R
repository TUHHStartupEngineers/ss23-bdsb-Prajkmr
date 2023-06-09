---
  author: Prajwal Kumar Koretagere Vijay Kumar
title: "04 Data Visualization"
date: "2023-05"
output:
  html_document:
  toc: true
toc_float: true
df_print: paged
collapsed: false
number_sections: true
toc_depth: 3
code_folding: hide
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(message=FALSE,warning=FALSE, cache=TRUE)
```

# Fourth Assignment : Data Visualization

### Map the time course of the cumulative Covid-19 cases

```{r, echo = TRUE}
library(tidyverse)
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)
covid_data_tbl <- read_csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv")
covid_data_tbl <- covid_data_tbl[order(as.Date(covid_data_tbl$dateRep, format="%d/%m/%Y")),]

covid_data_tbl2 <- covid_data_tbl %>%
  filter(countriesAndTerritories %in% c('Spain', 'United_Kingdom', 'France', 'Germany','United_States_of_America')) %>%
  select(dateRep, countriesAndTerritories, cases) %>%
  group_by(countriesAndTerritories) %>%
  mutate(cumulativeCases = cumsum(cases))  %>%
  select(dateRep, countriesAndTerritories, cumulativeCases) %>%
  rename(countries = countriesAndTerritories)
# Plotting the values 
ticks = c("Dec","Jan", 'Feb','March', 'April', 'May', 'June','July',
          'Aug','Sept','Oct','Nov','Dec')
y_ticks = seq(0,max(covid_data_tbl2$cumulativeCases),1250000)
covid_data_tbl2 %>%
  ggplot(aes(x = as.POSIXct(dateRep, format = '%d/%m/%Y'), y = cumulativeCases)) +
  geom_line(aes(color = countries), size = 1) +
  labs(x = 'Year 2020', y='Cumulative Cases', fill = 'Countries') +
  scale_x_datetime(date_breaks = 'month', labels = label_date_short()) +
  scale_y_continuous(breaks = c(y_ticks))
```
### Visualize the distribution of the mortality rate (deaths / population)

```{r, echo = TRUE}
library(tidyverse)
library(dplyr)
library(lubridate)
library(ggplot2)
theme_set(
  theme_dark()
)
covid_data_tbl <- read_csv("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv")

world <- map_data('world') %>%
  rename(countries = region) %>%
  dplyr::select(countries,long,lat,group) 

covid_data_tbl <- covid_data_tbl %>%
  mutate(across(countriesAndTerritories, str_replace_all, "_", " ")) %>%
  mutate(countriesAndTerritories = case_when(
    
    countriesAndTerritories == "United Kingdom" ~ "UK",
    countriesAndTerritories == "United States of America" ~ "USA",
    countriesAndTerritories == "Czechia" ~ "Czech Republic",
    TRUE ~ countriesAndTerritories
    
  ))
population <- covid_data_tbl %>%
  group_by(countriesAndTerritories) %>%
  dplyr::select(countriesAndTerritories, popData2019) %>%
  unique() %>%
  rename(countries = countriesAndTerritories)

mortality_rate_tbl <- covid_data_tbl %>%
  group_by(countriesAndTerritories) %>%
  summarise( 
    total_deaths = sum(deaths)
  ) %>%
  rename(countries = countriesAndTerritories)
useful_map <- left_join(population,mortality_rate_tbl, by = "countries")
final_tbl <- left_join(world, useful_map, by = 'countries') %>%
  mutate(mort_rate = total_deaths / popData2019)
#plotting the values
ggplot(final_tbl, aes(long, lat, group = group))+
  geom_polygon(aes(fill = mort_rate), color = "white")+
  scale_fill_gradient(low = 'orange', high = 'red', na.value = 'white')

```
