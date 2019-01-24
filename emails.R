library(tidyverse)
library(compare)

# Fill in where you've downloaded the CSV files from Google
edw2017 <- read_csv("")
edw2018 <- read_csv("")

# Count the number of unique email addresses
n_occur17 <- data.frame(table(edw2017$`Contact Email`))
n_occur18 <- data.frame(table(edw2018$`Contact Email`))

# Combine the tables and output a single file with all unique emails
emails <- bind_rows(n_occur17, n_occur18)
emails$Freq <- NULL
emails_final <- emails %>% group_by(Var1) %>% 
  summarise_all(funs(first(na.omit(.))))

write_csv(emails_final, "~/Desktop/emails.csv")
