avg_reading <-function(times, data) {

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

load_subject <- function(file_path) {
  read.csv(file_path, stringsAsFactors = FALSE) %>% mutate(
    subject_id = as.character(subject_id),
    gender = factor(gender, levels=c('F', 'M')),
    race_category = factor(race_category, levels = c('WHITE', 'ASIAN','BLACK', 'HISPANIC' ))
  )
}

load_reading <- function(file_path) {
  read.csv(file_path) %>% mutate(
    subject_id = as.character(subject_id),
    chart_time = ymd_hms(chart_time)
  )
}