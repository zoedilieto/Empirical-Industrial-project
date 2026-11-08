# AI Usage file

### Where AI was used

We used Claude Code and Codex for the main mechanical tasks of the assignment. It was used in the scraping of the table from the main page but not for setting up the `google-play-scraper` to get the characteristics of the individual apps. We also used it for brainstorming the functional form of the quantity proxy and for making the plots. We did not for the writeup.


### Prompts

1
````text
Hi Claude, today we're working on the first part of the assignment. Here's the plan: 
1. We will scrape the website https://sites.google.com/view/francescodecarolis/data/apps-dataset?authuser=0
2. Our target is the table that is available on the website. I believe that the table is not generated on the user's side, so we don't need to use selenium, however we must check. If that's the case, we will proceed with requests and bs4 and just extract the html. It may be useful to use html.unescape in our code to parse it. 
3. You will put the code in PS1.ipynb. This is not a production pipeline, we do not need extra type checks, robust functions, etc. We need a simple process that can be easily checked for mistakes such as missing values, or mistakes in the scraping. 
4. We will rely on a single request, we don't need parallelization etc. Don't overcomplicate this task. 
5. this dataset is small. we can verify (by looking at a random subset of rows) whether we have most likely acquired all of the data correctly. We will do so ex-post. 
6. Ask me any questions related to the task. Use the logging skill to log both this prompt and my answers to your questions.

Questions: 
PS1.ipynb currently has a placeholder 'hello world' code cell. What should I do with it?"="Replace it (Recommended)", "Should the scraped top-500 table also be saved to disk, or kept in memory only?"="Save raw CSV (Recommended)", "Which column names should the step-1 DataFrame use?"="rank, name, developer, app_id (Recommended)", "Which checks should the notebook print right after scraping?"="Row count & rank dupes, Missing / empty cells, Duplicate app_ids
````

2
````text
Okay, I wrote code that merges the scraped dataset with observations from a google-play-scraper api. It appears that we have lost 143 observations. I want you to look into the documentation of the package and verify whether my code has any mistakes that might be timing out the function. For example, it could be that the google play has a throttle on how many requests you can send every minute, and the scraper does not implement that. Verify whether there are any missing parameters/mechanisms that could potentially be the reason for the missing number of observations. Before testing, ask me all relevant questions. Log this prompt and any asked questions.

Questions:
May I send live requests to Google Play to test this? Which scope?"="Re-query only the 143 (Recommended)", "Should the test add a delay between requests?"="No delay (Recommended)", "Where should the diagnostic code live?"="Scratch script only (Recommended)", "Did anything unusual happen during your run (e.g. very slow cells, VPN/Tailscale exit node, run from a non-US location)?"="Nothing unusual
````

3
````text
Ok. Now I have to identify the outside option. To do so, I need to 

you can focus on the genre of the apps. The genres can be
aggregated in a smaller number of groups (around 10), and genres that can’t be aggregated and include
only a limited number of apps (let’s say less than 10) can composed the outside good. For reference,
a mapping along the following lines is reasonable (feel free to use a different one if you can justify it):
Games, Education, Productivity, Business, Health & Fitness, Lifestyle, Entertainment, Music & Audio,
Photography, Other/Outside.

 --> How do you thinki I can do so? Does the variable genre already exist in the dataset ? can I create it by using the apps descriptions in play_res.csv?
````

4
````text
Your last task is to produce a nicely looking table of summary statistics, providing the mean, median,
SD, min, max and number of observation of each variable in the dataset. Then create a scatterplot
showing together the price and quantity variables. --> ok now do a new cell that does this
````

### Mistakes of the AI

During the selection of formula for the quantity proxy the model proposed using a formula that did not have a clear economic justification, and it did not reflect on this fact. It proposed using $\text{max}\{20 \cdot \text{revenue}, \sqrt{LU}\}$. This formula essentially always uses the $\sqrt{LU}$, since the $20 \cdot \text{revenue}$ almost never applies (is killed by the lower bound) and instead is misleading to the person reading the code. Then, this implies that it doesn't use the variation in the number of reviews and the number of ratings, just uses the variable minInstalls.
