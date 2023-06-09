# Data Science at TUHH ------------------------------------------------------
# SALES ANALYSIS ----

# 1.0 Load libraries ----
library(tidyverse)
library(readxl)
library(lubridate)
library("writexl")
# 2.0 Importing Files ----
bikes_tbl      <- read_excel(path = "Data_bikes/01_bike_sales/01_raw_data/bikes.xlsx")
orderlines_tbl <- read_excel("Data_bikes/01_bike_sales/01_raw_data/orderlines.xlsx")
bikeshops_tbl  <- read_excel("Data_bikes/01_bike_sales/01_raw_data/bikeshops.xlsx")

# 3.0 Examining Data ----
#orderlines_tbl
#glimpse(orderlines_tbl)

# 4.0 Joining Data ----
bike_orderlines_joined_tbl <- orderlines_tbl %>% 
  left_join(bikes_tbl, by =c("product.id"="bike.id")) %>%
  left_join(bikeshops_tbl, by =c("customer.id"="bikeshop.id"))


# 5.0 Wrangling Data ----

bike_state_wrangled_tbl <- bike_orderlines_joined_tbl%>%
  separate(col=location,
           into= c("city","state"),
           sep= ",")%>%
mutate(total.price= price * quantity)%>%
select(-...1, -gender)%>%
 select(order.id,city,state,order.date, total.price, contains("model"), contains("category"),
         price, quantity,
         everything()) %>%
  rename(bikeshop = name) %>%
  set_names(names(.) %>% str_replace_all("\\.", "_"))

  

# 6.0 Business Insights ----
# 6.1 Sales by Location ----

# Step 1 - Manipulate

state_sales <- bike_state_wrangled_tbl%>%
  select(state,total_price)%>%
  group_by(state)%>%
  summarize(sales=sum(total_price))%>%
  mutate(sales_text = scales::dollar(sales, big.mark = ".", 
                                     decimal.mark = ",", 
                                     prefix = "", 
                                     suffix = " €"))
# Step 2 - Visualize
state_sales %>%
  
  # Setup canvas with the columns year (x-axis) and sales (y-axis)
  ggplot(aes(x = state, y = sales)) +
  
  # Geometries
  geom_col(fill = "#2DC6D6") + # Use geom_col for a bar plot
  geom_label(aes(label = sales_text)) + # Adding labels to the bars
  geom_smooth(method = "lm", se = FALSE) + # Adding a trendline
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  + 
  # Formatting
  scale_y_continuous(labels = scales::dollar_format(big.mark = ".", 
                                                    decimal.mark = ",", 
                                                    prefix = "", 
                                                    suffix = " €")) +
  labs(
    title    = "Revenue by States",
    x = "", # Override defaults for x and y
    y = "Revenue"
  )

# 6.2 Sales by Location and Year----

# Step 1 - Manipulate
sales_by_location_year <- bike_state_wrangled_tbl %>%
  
  # Select columns and add a year
  select(order_date, total_price,state) %>%
  mutate(year = year(order_date)) %>%
  
  # Group by and summarize year and state
  group_by(year,state) %>%
  summarise(sales = sum(total_price)) %>%
  ungroup() %>%
  
  # Format $ Text
  mutate(sales_text = scales::dollar(sales, big.mark = ".", 
                                     decimal.mark = ",", 
                                     prefix = "", 
                                     suffix = " €"))

# Step 2 - Visualize
sales_by_location_year %>%
  
  # Set up x, y, fill
  ggplot(aes(x = year, y = sales, fill = state)) +
  
  # Geometries
  geom_col() + # Run up to here to get a stacked bar plot
  
  # Facet
  facet_wrap(~ state) +
  
  # Formatting
  scale_y_continuous(labels = scales::dollar_format(big.mark = ".", 
                                                    decimal.mark = ",", 
                                                    prefix = "", 
                                                    suffix = " €")) +
  labs(
    title = "Revenue by year and State",
    fill = "Main category" # Changes the legend name
  )



