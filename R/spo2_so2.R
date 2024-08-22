library(lubridate)
library(MLmetrics)
library(dplyr)
library(ggplot2)


# SPO2

spo2_raw_df <- read.csv('data/patients_with_spo2.csv', stringsAsFactors = TRUE)
spo2_df<- data.frame(spo2_raw_df, read_timestamp = ymd_hms(spo2_raw_df$read_time))


avg_flow <-function(times, data) {
  
  data_size = length(data)
  if (data_size == 1) {
    data  
  } else {
    numeric_times <- as.numeric(times)
    auc <- Area_Under_Curve(numeric_times, data)
    time_diff <- numeric_times[data_size] - numeric_times[1]
    auc/time_diff
  }
}

spo2_avg_df <- spo2_df %>%  
  group_by(subject_id, race_category) %>%
  group_modify(~ data.frame(spo2 = avg_flow(.x$read_timestamp, .x$spo2)))  %>%
  ungroup()

print(spo2_avg_df)


print(
  ggplot(spo2_avg_df, aes(x=race_category, y=spo2, colour = race_category)) + geom_boxplot()
)

# Compute IQR, median etc

iqr_df <- spo2_avg_df %>% 
  group_by(race_category) %>% 
  summarize( 
    count = n(),
    Q1 = quantile(spo2, .25),
    median = quantile(spo2, .5),
    Q3 = quantile(spo2, .75),
    IQR = IQR(spo2, na.rm = TRUE)
  )


print(iqr_df)


# SO2

so2_raw_df <- read.csv('data/patients_with_so2.csv', stringsAsFactors = TRUE)
so2_df<- data.frame(so2_raw_df, read_timestamp = ymd_hms(so2_raw_df$read_time))


so2_avg_df <- so2_df %>%  
  filter(so2 > 70) %>%
  group_by(subject_id, race_category) %>%
  group_modify(~ data.frame(so2 = avg_flow(.x$read_timestamp, .x$so2)))  %>%
  ungroup()
print(so2_avg_df)


print(
  ggplot(so2_avg_df, aes(x=race_category, y=so2, colour = race_category)) + geom_boxplot()
)

# Compute IQR, median etc

iqr_df <- so2_avg_df %>% 
  group_by(race_category) %>% 
  summarize( 
    count = n(),
    Q1 = quantile(so2, .25),
    median = quantile(so2, .5),
    Q3 = quantile(so2, .75),
    IQR = IQR(so2, na.rm = TRUE)
  )


print(iqr_df)

## JOINED analysis


# Perform the join
joined_df <- inner_join(so2_avg_df, spo2_avg_df, by = c("subject_id", "race_category"))

# Print the joined data frame to verify
print(joined_df)


print(
  ggplot(joined_df, aes(x=so2, y=spo2)) 
    + geom_point()
    + geom_smooth(aes(colour = race_category), se = FALSE, method='gam')
)


