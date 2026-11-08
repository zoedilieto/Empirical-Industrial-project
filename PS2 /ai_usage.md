# AI Usage
## Where AI was used
In part 1 and parts 2a-b, we assigned LLMs some uninteresting coding tasks on importing tables, and used it for help on deriving markup formulas and transcribe handwriting. We used it more extensively for Part 2.3.
We used GPT-6 Astra (Extra High) to generate Stata code exporting tables, for guidance on deriving the formulas for markups, to transcribe handwritten notes on the derivation to LaTeX and for code debugging.
We used GPT-6.1 Sol to create some more code for the tables and to check for potential mistakes on the comments of the results
We used ⁠GitHub Copilot Chat in VS Code to review the project context, help develop and explain the PyBLP estimation and merger counterfactual code, and clarify how to run the script.
We used ⁠Claude Opus 5.5 to review the worked files context, correct typos, syntactical errors and to flag sentences whose phrasing had to be revised, as well as to double-check the obtained results.

## Some important prompts
•⁠  ⁠“Set up a PyBLP Problem with only a linear demand component (X1, matching the Part I logit specification and instrument, no random coefficients), which reproduces the Part I estimates while having access to PyBLP's equilibrium solver.”

•⁠  ⁠“For the candidate target(s), build the post-merger ownership matrix ... and use results.compute_prices(ownership=...) to simulate the new equilibrium prices.”

•⁠  "Please produce a table reporting the markups under the three scenarios (current ownership, single-product firms and monopolist). Let's consider markup= p-c as from the start. Give me the code to produce a table. See attached the do file to which I'll add it."

•⁠  "Please transcribe my handwriting (attached) to latex very nicely and output the tex file."
## An example for a mistake
The initial output showed the first five entries of the market price vector, which could be apps unrelated to the merger. I caught this by noticing the output was not identifying products by developer. The code was corrected to build a product-level price comparison and filter it by the original developer ID for the acquirer and target, so it reports apps belonging to the merger parties with pre- and post-merger prices and price changes.
