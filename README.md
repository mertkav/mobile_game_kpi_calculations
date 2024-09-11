
## Project Overview
This project focuses on game data analysis, user segmentation, and revenue prediction modeling. The aim is to generate insights from user gameplay data, create meaningful visualizations, and build a user-level prediction model for D7 revenue based on users' first 24 hours of data. This project addresses four key questions:

1. **Q1 & Q2**: Create user segments based on revenue over time windows (D0, D3, D7, D14, D28), visualize the segments, and analyze the data to generate insights. 
2. **Q3**: Write a query to add session numbers to each user's event, with a session inactivity duration of 30 minutes.
3. **Q4**: Build a regression model to predict D7 revenue based on the first 24 hours' revenue data.

## Directory Structure

- **lookerstudiolink: https://lookerstudio.google.com/reporting/6b227b66-b270-4710-8155-9521b9e312fc**:

### SQL Files (Used for Q1, Q2, and Q3 Analysis)
- **`page-I.sql`**: SQL query for analyzing user revenue by time windows(D0, D3, D7, D14, D28). This query is designed to help with creating user segments for further analysis and visualization at page I of Looker Studio visualization. Aggregate data and overview of the dataset is represented.
- **`page-I-country_distribution_analysis.sql`**: SQL query for conducting a country distribution analysis of users. This helps to segment users geographically and understand how country distribution impacts revenue.
- **`page-II_ARPDAU_DAU.sql`**: SQL query for calculating **ARPDAU** (Average Revenue per Daily Active User) and **DAU** (Daily Active Users) over specific time windows, helping with the understanding of user behavior and monetization by specific time periods.
- **`page-III_retention.sql`**: SQL query for calculating retention metrics (D1, D3, D7, D14, D28) to assess how well the game retains its players over time and shows the transition between important days.
- **`page-III_LTV.sql`**: SQL query for calculating **Lifetime Value (LTV)**, a key performance indicator (KPI) used to understand user value over time.
- **`page-III_Level_average.sql`**: SQL query for calculating the average number of levels played by users over time windows (D0, D3, D7, D14, D28).
- **`Q3-add_each_event_session_number.sql`**: SQL query for assigning session numbers to user events, with a session inactivity duration of 30 minutes. This helps analyze user activity sessions.

### Jupyter Notebook (Used for Q4 - Predictive Modeling)
- **`Q4_regressionmodelford7revenue.ipynb`**: This notebook contains a regression model that predicts D7 revenue based on users' first 24 hours' revenue data. To conclude, model can be used for SKAN analysis.

## KPIs Calculated
During the analysis, the following KPIs were calculated:
- **Retention Rate** (D1, D3, D7, D14, D28): To assess the user engagement and how long users stay with the game.
- **Lifetime Value (LTV)**: To understand the total value a user brings over their lifetime in the game.
- **ARPDAU (Average Revenue per Daily Active User)**: A monetization metric that shows how much revenue is generated per active user per day.
- **DAU (Daily Active Users)**: The number of unique players who play the game each day.

## Visualizing the Insights
We used **Looker Studio** (formerly Google Data Studio) to visualize key segments and KPIs like revenue segmentation, retention, LTV, ARPDAU, and DAU.

## How to Run the SQL Queries
1. Use a BigQuery or any SQL-compatible environment to run the SQL files.
2. Load the queries into your SQL environment and execute them against your dataset.
3. Use Looker Studio for visualizing the results of these queries, especially for segmentations.

## How to Run the Regression Model
1. Open `Q4_regressionmodelford7revenue.ipynb` in Jupyter Notebook or JupyterLab.
2. You need to use your “ds-interview-sca (1).json” document to reach data (os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = '/path/to/your/service_account_key.json' # Update with the path to your service account key)
2. Please install relevant libraries
3. The notebook will load the data, preprocess it, and run a regression model to predict D7 revenue.

## Tools Used
- **BigQuery**: For running the SQL queries and analyzing large datasets.
- **Looker Studio**: For visualizing key metrics and insights.
- **Jupyter Notebook**: For building and running the D7 revenue prediction model.
- **Python**: For data processing and modeling (with libraries like pandas, sklearn, etc.).



