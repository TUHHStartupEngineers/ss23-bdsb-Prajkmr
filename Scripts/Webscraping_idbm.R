url  <- "https://www.imdb.com/chart/top/?ref_=nv_mv_250"
html <- url %>% 
  read_html()
rank <-  html %>% 
  html_nodes(css = ".titleColumn") %>% 
  html_text() %>% 
  # Extrag all digits between " " and ".\n" The "\" have to be escaped
  # You can use Look ahead "<=" and Look behind "?=" for this
  stringr::str_extract("(?<= )[0-9]*(?=\\.\\n)")%>% 
  # Make all values numeric
  as.numeric()

title <- html %>% 
  html_nodes(".titleColumn > a") %>% 
  html_text()

year <- html %>% 
  html_nodes(".titleColumn .secondaryInfo") %>%
  html_text() %>% 
  # Extract numbers
  stringr::str_extract(pattern = "[0-9]+") %>% 
  as.numeric()

rating <- html %>% 
  html_nodes(css = ".imdbRating > strong") %>% 
  html_text() %>% 
  as.numeric()

num_ratings <- html %>% 
  html_nodes(css = ".imdbRating > strong") %>% 
  html_attr('title') %>% 
  # Extract the numbers and remove the comma to make it numeric values
  stringr::str_extract("(?<=based on ).*(?=\ user ratings)" ) %>% 
  stringr::str_replace_all(pattern = ",", replacement = "") %>% 
  as.numeric()

people <- html %>% 
  html_nodes(".titleColumn > a") %>% 
  html_attr("title")

imdb_tbl <- tibble(rank, title, year, people, rating, num_ratings)
