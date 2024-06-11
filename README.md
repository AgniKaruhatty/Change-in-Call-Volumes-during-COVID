# CAHOOTS Call Volume Analysis During COVID-19 Pandemic

This project analyzes the change in call volume and types of emergency calls to CAHOOTS (a mobile crisis intervention program) during the COVID-19 pandemic.

## Project Description

*   **Research Question:** How did the volume and types of calls change during the first year of the pandemic?
*   **Data:** Anonymized CAHOOTS call records from 2021-2022 (sample data may be included in the 'data' folder).
*   **Methods:** Data cleaning, aggregation, time series analysis, and statistical testing.
  

## How to Run the Analysis
These are the external packages that extend R's functionality.

**tidyverse:** A collection of packages for data manipulation, transformation, and visualization (includes dplyr, ggplot2, etc.).\
**broom:** Converts statistical model output (like those from chisq.test) into tidy data frames.\
**readxl:** For reading Excel files (.xlsx).\
**reshape2:** Reshapes and aggregates data (e.g., from wide to long format using melt or dcast).\
**ggplot2:** Powerful data visualization library, part of tidyverse.\
**RColorBrewer:** Provides color palettes for better visuals.\
**tools:** Provides various tools for working with files, dates, etc.\
**scales:** Extends ggplot2 with tools for scaling and formatting axes and legends.\

## Functions(Arguments and Parameters)
**read_excel**("C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Cahoots 2021-2022.xlsx"):\
Argument: The path to your Excel file. Replace with the correct path or use a relative path if the data is within your project folder.\
**filter():**\
Arguments: Conditions to filter the data by (e.g., date ranges, specific dispatch reasons).\
**select():**\
Arguments: Column names to keep in the filtered dataset.\
**table():**\
Argument: A data frame or multiple vectors to create a frequency table.\
**as.data.frame():**\
Argument: An object (in this case, a table) to convert into a data frame.\
**mutate():**\
Arguments: New columns to create or existing columns to modify (e.g., converting to dates).\
**group_by():**\
Arguments: Columns to group the data by for calculations.\
**summarize():**\
Arguments: Summary functions to apply to the grouped data (e.g., mean, sum).\
**geom_line(), geom_col(), geom_bar():**\
These are ggplot2 functions to add lines, columns, or bars to a plot.\
**labs():**\
Arguments: Labels for the plot's title, x-axis, y-axis, and legend.\
**scale_color_manual(), scale_fill_manual():**\
Arguments: Custom colors for plot elements.\
**theme_minimal():**\
A ggplot2 theme for a clean plot appearance.\
**ggsave():**\
Arguments: Filename and dimensions for saving the plot.\


1.  **Install R and Required Libraries:** Ensure you have R installed. Then, install these libraries:

```R
install.packages(c("tidyverse", "broom", "readxl", "reshape2", "ggplot2", "RColorBrewer", "tools", "scales"))
setwd("C:/Users/Agni/OneDrive/Documents/Data Science for Social Justice/Cahoots 2021-2022.xlsx")
