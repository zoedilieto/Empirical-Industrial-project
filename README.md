# Empirical Industrial Organization — Group Project

This repository contains our group work on Google Play app markets for two Empirical Industrial Organization problem sets. We study app characteristics and estimated downloads, estimate demand, and examine markups, marginal costs, and merger counterfactuals.

**Group members:** Giovanni Cecchi, Zoe Di Lieto, David Herskovits, Lorenzo Morandi, and Jakub Przewoski.

## Project overview

- **PS1 — Data collection and descriptive analysis:** scrape a top-500 paid-apps list, collect app characteristics from Google Play, construct alternative download proxies, group app genres and define an outside option, and produce summary statistics and plots.
- **PS2 — Demand and supply estimation:** estimate Berry logit and nested logit models using OLS and instrumental variables, recover markups and marginal costs under alternative ownership structures, and simulate potential acquisitions by Mojang using PyBLP.

PS2 uses the dataset supplied for the assignment, `final_dataset.dta`; it does not require rerunning PS1. The PS2 analysis excludes Canada, as explained in our write-up.

## Repository contents

| Location | Contents |
| --- | --- |
| [PS1/PS1.ipynb](PS1/PS1.ipynb) | Data collection, cleaning, download proxies, summary statistics, and plots. |
| [PS1/PS1_eio.pdf](PS1/PS1_eio.pdf) | PS1 PDF. |
| [PS1/ai_usage.md](PS1/ai_usage.md) | Our PS1 AI-use disclosure. |
| [PS2 /final_dataset.dta](PS2%20/final_dataset.dta) | Dataset supplied for PS2. |
| [PS2 /ps2.do](PS2%20/ps2.do) | Stata demand estimation, supply analysis, and table exports. |
| [PS2 /PS2.ipynb](PS2%20/PS2.ipynb) | PyBLP estimation checks and merger simulations. |
| [PS2 /ps2.tex](PS2%20/ps2.tex) | LaTeX source for our PS2 write-up. |
| [PS2 /ps2.pdf](PS2%20/ps2.pdf) | Compiled PS2 write-up. |
| [PS2 /README.txt](PS2%20/README.txt) | Original PS2 run instructions. |
| [PS2 /ai_usage.md](PS2%20/ai_usage.md) | Our PS2 AI-use disclosure. |

**Folder naming:** the current `PS2 ` directory has a trailing space. Use quotes around its name in terminal commands, for example `cd "PS2 "`.

## Requirements

- Python 3 and Jupyter Notebook or JupyterLab.
- Python packages: `numpy`, `pandas`, `matplotlib`, `requests`, `beautifulsoup4`, `google-play-scraper`, and `pyblp`.
- Stata for the PS2 `.do` file. The script installs `estout` if it is missing, which requires internet access.
- A LaTeX distribution with `pdflatex` to rebuild the PS2 write-up. The compiled PDF is already included.

Install the Python dependencies in your chosen environment:

```sh
python3 -m pip install jupyterlab numpy pandas matplotlib requests beautifulsoup4 google-play-scraper pyblp
```

## Running PS1

1. Set the notebook working directory to `PS1` and create an `output` subdirectory:

   ```sh
   cd PS1
   mkdir -p output
   jupyter lab
   ```

2. Open `PS1.ipynb` and run the cells in order. Data collection requires internet access.
3. The notebook writes intermediate CSV files, `ps1_final.csv`, `summary_stats.csv`, and plots into `PS1/output/`. These generated files are not currently included in the repository.

**Current reproducibility limitation:** the notebook constructs `quantity1` and `floor_binds1`, while later cells reference `quantity` and `floor_binds`. These names need to be reconciled before a clean end-to-end run. Live Google Play results may also differ from those collected for our original analysis.

## Running PS2

Run the Stata analysis first, then the Python notebook, and finally compile the write-up if needed.

### 1. Stata estimation and table exports

Open `ps2.do` in Stata and change the `global PATH` at the top to the absolute path of your local PS2 directory, including the final slash. For example:

```stata
global PATH = "/absolute/path/to/Empirical Industrial project/PS2 /"
```

Run the complete file. It reads `final_dataset.dta` and generates:

- `final_dataset_up.dta`, used by the Python notebook;
- `berry_logit.tex` and `berry_firststage.tex`;
- `nested_logit.tex`;
- `markups_ownership.tex` and `costs_ownership.tex`.

### 2. PyBLP estimation and merger simulations

Start Jupyter with `PS2 ` as the working directory and open `PS2.ipynb`. Once the Python dependencies above are installed, run the main analysis cell; the first package-installation cell is optional.

The notebook reads `final_dataset_up.dta`, checks its simple-logit estimates against a manual 2SLS calculation, and simulates changes in US ownership and equilibrium prices. By default, it uses both instruments and selects three potential targets for Mojang. Adjust `instrument`, `target_firms`, and `n_targets` in the settings at the end of the analysis cell to change these choices.

Merger results are displayed in the notebook. Reported operating-profit gains hold marginal costs fixed and exclude acquisition payments and fixed costs.

### 3. Rebuild the write-up

After Stata has generated the LaTeX tables, run the following from inside `PS2 `:

```sh
pdflatex ps2.tex
pdflatex ps2.tex
```

Alternatively, read the included `ps2.pdf` directly.

## AI-use disclosures

Our assignment-specific disclosures describe where AI tools supported our work, example prompts, and mistakes identified during review. See [PS1/ai_usage.md](PS1/ai_usage.md) and [PS2 /ai_usage.md](PS2%20/ai_usage.md).
