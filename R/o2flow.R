library(lubridate)
library(MLmetrics)
library(dplyr)
library(ggplot2)


o2flow_raw_df <- read.csv('data/patients_with_flow.csv', stringsAsFactors = TRUE)
o2flow_df<- data.frame(o2flow_raw_df, flow_timestamp = ymd_hms(o2flow_raw_df$flow_time))


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

o2flow_avg_df <- o2flow_df %>%  
  group_by(subject_id, race_category) %>%
  group_modify(~ data.frame(o2_flow = avg_flow(.x$flow_timestamp, .x$o2_flow))) %>%
  filter(o2_flow < 20) # remove outliers TODO: fix in the data export

print(o2flow_avg_df)


print(
  ggplot(o2flow_avg_df, aes(x=race_category, y=o2_flow, colour = race_category)) + geom_boxplot()
)

# Compute IQR, median etc

iqr_df <- o2flow_avg_df %>% 
  group_by(race_category) %>% 
  summarize( 
            count = n(),
             Q1 = quantile(o2_flow, .25),
             median = quantile(o2_flow, .5),
             Q3 = quantile(o2_flow, .75),
             IQR = IQR(o2_flow, na.rm = TRUE)
  )


print(iqr_df)


# Unpaired Wilson-Cox test


res_w_b <- wilcox.test(o2_flow ~ race_category, 
    data = o2flow_avg_df %>% filter(race_category %in% c('WHITE', 'BLACK') ))
print('WC Test: White/Black')
print(res_w_b)

res_w_a <- wilcox.test(o2_flow ~ race_category, 
                       data = o2flow_avg_df %>% filter(race_category %in% c('WHITE', 'ASIAN') ))
print('WC Test: White/Asian')
print(res_w_a)

res_w_h <- wilcox.test(o2_flow ~ race_category, 
                       data = o2flow_avg_df %>% filter(race_category %in% c('WHITE', 'HISPANIC') ))
print('WC Test: White/Hispanic')
print(res_w_h)









