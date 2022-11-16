# RLWC2021
A project for analysis and capturing of data for the Rugby League World Cup 2021.

This repository will consist of the following compontents each within their own folders.

- DATA (Containing all data as structured below)
- Code (all code used to scrape the data from the RLWC2021 website)
- Visualisations (all visualisation code)

## Data Folder Structure 

The data in the data folders are structured as so. This is to enable simpified partition management. Our Partitions are rounds as they should never need to be updated once captured here.

![image](https://user-images.githubusercontent.com/315909/202063012-38373e3f-3632-4cb8-a3bb-022b661b06b5.png)

An example of this would be DATA/Rugby League World Cup  Round 1/England-Samoa.csv"

The data has been seperated into these files
- Player Stats
- Team Stats
- GAME TIMELIME
- Line Up
- Game Details

## Code

### Data Scraping R script

Uses the rvest library to select html contents from the RLWC report website e.g. [https://www.rlwc2021.com/report/63](https://www.rlwc2021.com/report/63) so that it can be parsed into dataframes to save as the above data entities.
