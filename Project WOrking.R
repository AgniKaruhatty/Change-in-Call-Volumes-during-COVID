library(tidyverse)
library(broom)
library(readxl)
library(reshape2)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(tools)
library(scales)


#This is for finding the dates and understanding the volume of the different reasons of dispatches within the Springfield
#and Eugene area
new_data <- read_excel("C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Cahoots 2021-2022.xlsx")

view(new_data)
new_data$Date <- as.Date(new_data$Date)

covid_year <- new_data %>% 
  filter(Date >= as.Date("2021-03-21") & Date <= as.Date("2022-03-22"))

view(covid_year)

cleaned_data_for_dispatches <- covid_year %>%
  select("Date", "Reason for Dispatch", "City")

view(cleaned_data_for_dispatches)

#Table the data above to provide frequency for the amount of times each happened during each day of each month, 
volume_dispatch <- table(cleaned_data_for_dispatches)

view(volume_dispatch)

volume_dispatch_df <- as.data.frame(volume_dispatch) %>%
  mutate(Date = as.Date(Date))


view(volume_dispatch_df)


monthly_averages_before_march <- filtered_agg_df %>%
  filter(Date < as.Date("2022-03-01")) %>%
  group_by(Reason.for.Dispatch, Month = format(Date, "%Y-%m")) %>%  # Group by month
  summarize(Avg_Calls = mean(Total_Calls), .groups = "drop")


# Calculate the average change for each dispatch reason
average_change_by_reason <- monthly_averages_before_march %>%
  group_by(Reason.for.Dispatch) %>%
  summarize(Avg_Change = (last(Avg_Calls) - first(Avg_Calls)) / first(Avg_Calls) * 100) %>%
  ungroup()

# Overall average change 
overall_average_change <- monthly_averages_before_march %>%
  summarize(Avg_Change = (last(Avg_Calls) - first(Avg_Calls)) / first(Avg_Calls) * 100)



# Convert Month to date format for plotting
filtered_agg_df$Date <- as.Date(paste0(filtered_agg_df$Date, "-01"))

# Create line graph with separate lines for each dispatch reason
ggplot(filtered_agg_df, aes(x = Date, y = Total_Calls, color = `Reason.for.Dispatch`)) +
  geom_line() +
  labs(title = "Monthly Trends for 'Check Welfare' and 'Public Assist' Calls",
       x = "Month",
       y = "Total Calls") +
  scale_color_manual(values = c("Check Welfare" = "blue", "Public Assist" = "red")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

##


welfare_dispatch_df <- volume_dispatch_df %>%
  filter(`Reason.for.Dispatch` == "Check Welfare") 


welfare_agg_df <- welfare_dispatch_df %>%
  group_by(Date) %>%
  summarise(Total_Welfare_Checks = sum(Freq))

view(welfare_agg_df)
welfare_agg_dd_avg_summary <- welfare_agg_df%>%
  summarise(Average_Welfare_Checks = mean(Total_Welfare_Checks)) 

print(welfare_agg_dd_avg_summary)


# Aggregate by date, summing frequencies (in case there are multiple checks on a day)
welfare_agg_df <- welfare_dispatch_df %>%
  group_by(Date) %>%
  summarise(Total_Welfare_Checks = sum(Freq))

# Create the line graph
ggplot(welfare_agg_df, aes(x = Date, y = Total_Welfare_Checks)) +
  geom_line() +
  labs(title = "Frequency of 'Check Welfare' Dispatches Over Time",
       x = "Date",
       y = "Total Welfare Checks") +
  theme_minimal()  # Or any other theme you prefer


## Public Assist

public_assist <- volume_dispatch_df %>%
  filter(`Reason.for.Dispatch` == "Public Assist")

public_agg_df <- public_assist %>%
  group_by(Date) %>%
  summarise(Total_Public_Assists = sum(Freq))

public_agg_dd_avg_summary <- public_agg_df%>%
  summarise(Average_Public_Assists = mean(Total_Public_Assists)) 

print(public_agg_dd_avg_summary)
  

view(public_agg_df)

ggplot(public_agg_df, aes(x = Date, y = Total_Public_Assists)) +
  geom_line() +
  labs(title = "Frequency of 'Public Assist' Dispatches Over Time",
       x = "Date",
       y = "Total Public Assits") +
  theme_minimal()  # Or any other theme you prefer

#Joining two graphs
combined_df <- welfare_agg_df %>%
  full_join(public_agg_df, by = "Date")

# Reshape data
combined_df_long <- combined_df %>%
  pivot_longer(cols = -Date, names_to = "Dispatch_Type", values_to = "Total_Dispatches")
view(combined_df_long)

ggplot(combined_df_long, aes(x = Date, y = Total_Dispatches, color = Dispatch_Type)) +
  geom_line() +
  labs(title = "Frequency of 'Check Welfare' and 'Public Assist' Dispatches Over Time",
       x = "Date",
       y = "Total Dispatches") +
  scale_color_manual(values = c("Total_Welfare_Checks" = "blue", "Total_Public_Assists" = "red")) +  # Set custom colors
  theme_minimal()



#March 2021
march_2022_data <- filtered_agg_df %>%
  filter(Date >= as.Date("2022-03-01") & Date < as.Date("2022-04-01"))

view(march_count)

#Adding a month for easier grouping
volume_dispatch_df <- volume_dispatch_df %>%
  mutate(Month = format(Date, "%Y-%m"))

unique_months <- unique(volume_dispatch_df$Month)

view(unique_months)
#Creating a plot for each month
for (month in unique_months) {
  month_data <- volume_dispatch_df %>%
    filter(Month == month)
  month_data <- month_data %>%
    mutate(Week = ceiling(as.numeric(format(Date, "%d")) / 7))

  # Create the plot
  print(  # Add print() to display each plot
    ggplot(month_data, aes(x = Date, y = Freq, fill  = `Reason.for.Dispatch`)) +
      geom_col(position = "dodge") +
      labs(
        title = paste("Dispatch Reasons for", month),
        x = "Date",
        y = "Frequency"
      ) +
      scale_x_date(date_breaks = "1 day", date_labels = "%d") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      guides(fill = guide_legend(title = "Reason for Dispatch"))   # Remove the extra '}'
  ) 
  ggsave(paste0("dispatch_reasons_", month, ".png"), width = 10, height = 6)  # Save plot after print
}

# Stacked Bar graph
ggplot(volume_dispatch_df, aes(x = Month, y = Freq, fill = `Reason.for.Dispatch`)) +
  geom_bar(stat = "identity") +  # Stack the bars
  labs(title = "Dispatch Reasons by Month", x = "Month", y = "Frequency") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#Pie chart for every month in the given time frame
unique(volume_dispatch_df$Month)
volume_dispatch_df %>% group_by(Month) %>% summarize(total_freq = sum(Freq))

monthly_totals <- volume_dispatch_df %>%
  group_by(Month) %>%
  summarize(total_freq = sum(Freq))

view(monthly_totals)

monthly_totals_df <- as.data.frame(monthly_totals)


pie_chart <- ggplot(monthly_totals_df, aes(x = "", y = total_freq, fill = Month)) +
  geom_bar(stat = "identity", width = 1) +  
  coord_polar("y", start = 0) +
  labs(title = "Total Dispatches by Month") +
  theme_void() +
  scale_fill_brewer(palette = "Set3")# Minimal theme for the pie chart

# Display the pie chart
pie_chart


# Filter data for March 2022 and the 12 months before
march_and_prior_year_data <- filtered_agg_df %>%
  filter(Date >= as.Date("2021-03-01") & Date < as.Date("2022-04-01")) %>%
  mutate(Time_Period = ifelse(Date >= as.Date("2022-03-01"), "March 2022", "Prior 12 Months"))

# Aggregate and create contingency table
agg_data_march_comparison <- march_and_prior_year_data %>%
  group_by(Reason.for.Dispatch, Time_Period) %>%
  summarize(Total_Calls = sum(Total_Calls), .groups = "drop") %>%
  pivot_wider(names_from = Time_Period, values_from = Total_Calls, values_fill = 0)

# Chi-squared test
chi2_result_march <- chisq.test(agg_data_march_comparison[, -1])  # Exclude the first column

# Print results for March comparison
cat("\nChi-squared test results (March 2022 vs. Prior 12 Months):\n")
cat(sprintf("Chi-squared statistic: %.4f\n", chi2_result_march$statistic))
cat(sprintf("P-value: %.4f\n", chi2_result_march$p.value))
cat(sprintf("Degrees of freedom: %d\n", chi2_result_march$parameter))
cat("Expected frequencies:\n")
print(chi2_result_march$expected)


# Calculate Percentage Change for Each Call Type in March 2022

# Calculate average calls per month from March 2021 to February 2022
monthly_averages_before_march <- filtered_agg_df %>%
  filter(Date < as.Date("2022-03-01")) %>%
  group_by(Reason.for.Dispatch) %>%
  summarize(Avg_Calls_Before_March = mean(Total_Calls), .groups = "drop")

# Get total calls for March 2022
march_2022_totals <- filtered_agg_df %>%
  filter(Date >= as.Date("2022-03-01") & Date < as.Date("2022-04-01")) %>%
  group_by(Reason.for.Dispatch) %>%
  summarize(Total_Calls_March = sum(Total_Calls), .groups = "drop")

# Combine and calculate percentage changes
percentage_change_march <- monthly_averages_before_march %>%
  left_join(march_2022_totals, by = "Reason.for.Dispatch") %>%
  mutate(Percent_Change_March = (Total_Calls_March - Avg_Calls_Before_March) / Avg_Calls_Before_March * 100)

# Print percentage changes
cat("\nPercentage change in call volume for each reason in March 2022:\n")
print(percentage_change_march)




# Calculate average change BEFORE March 2022 for each reason and overall

# Filter to dates before March 2022 and calculate monthly averages
monthly_averages_before_march <- filtered_agg_df %>%
  filter(Date < as.Date("2022-03-01")) %>%
  group_by(Reason.for.Dispatch, Month = format(Date, "%Y-%m")) %>%  
  summarize(Avg_Calls = mean(Total_Calls), .groups = "drop")

# Calculate average change by reason (percentage)
average_change_by_reason <- monthly_averages_before_march %>%
  group_by(Reason.for.Dispatch) %>%
  summarize(Avg_Change = (last(Avg_Calls) - first(Avg_Calls)) / first(Avg_Calls) * 100) %>%
  ungroup()

# Overall average change 
overall_average_change <- monthly_averages_before_march %>%
  summarize(Avg_Change = (last(Avg_Calls) - first(Avg_Calls)) / first(Avg_Calls) * 100)

cat("\nAverage change in call volume by reason before March 2022:\n")
print(average_change_by_reason)

cat("\nOverall average change in call volume before March 2022:\n")
print(overall_average_change)



# Filter for March 2022
march_2022_data <- filtered_agg_df %>%
  filter(Date >= as.Date("2022-03-01") & Date < as.Date("2022-04-01"))

# Examine March 2022 data
cat("\nCall volumes in March 2022:\n")
print(march_2022_data)

view(march_2022_data)

#RQ13, Which is how environmental factors such as AQI, temperature, percipitation and humidity affect
#call volume. 


weather_data <- c(
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/March 2021.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/April 2021.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/May 2021.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/June 2021.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/July 2021.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/August 2021.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/September.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/October 2021.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/November.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/December 2021.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/January 2022.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/February 2022.xlsx",
  "C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Project/March 2022.xlsx"
  
)
weather_data_list <- list()

# Loop through the file paths
for (path in weather_data) {
  # Read the Excel file
  df <- read_excel(path)
  
  # Convert numeric dates to R dates
  df$Time <- as.Date(df$Time, origin = "1899-12-30")  
  
  # Assign standardized column names
  colnames(df) <- c("Time", "Average Humidity (%)", "Average Temperature (F)", "Average Precipitation (in)")
  
  # Extract the month name from the file name
  month <- tools::file_path_sans_ext(basename(path))  
  
  # Add a Month column
  df$Month <- month 
  
  # Add the data frame to the list
  weather_data_list[[month]] <- df 
}

# Combine all data frames from the list into a single data frame
merged_weather_data <- do.call(rbind, weather_data_list)

view(merged_weather_data)




# Filter for March 2022 data
march_2022_data <- merged_weather_data %>% filter(Month == "March 2022")
view(march_2022_data)
# Convert precipitation to percentages for the graph
march_2022_data$`Average Precipitation (%)` <- march_2022_data$`Average Precipitation (in)` * 100

view(march_2022_data)
# Melt data for ggplot
melted_data <- march_2022_data %>% 
  select(Time, `Average Humidity (%)`, `Average Temperature (F)`, `Average Precipitation (%)`) %>%
  tidyr::pivot_longer(-Time, names_to = "Variable", values_to = "Value")

view(melted_data)
# Create the plot
ggplot(melted_data, aes(x = Time, y = Value, color = Variable)) +
  geom_line() +
  labs(title = "Average Temperature, Humidity, and Precipitation for March 2022",
       x = "Date",
       y = "Percentage (%)") +
  scale_y_continuous(limits = c(0, 100)) +  # Set y-axis limits to 0-100
  theme_minimal() +
  scale_color_manual(values = c("Average Humidity (%)" = "blue", 
                                "Average Temperature (F)" = "red",
                                "Average Precipitation (%)" = "green"))











