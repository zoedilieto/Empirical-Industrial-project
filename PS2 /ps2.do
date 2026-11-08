clear 

global PATH =  "/Users/hersk/Documents/EIO/PS2/"
* Install the table-export package if needed
capture which esttab
if _rc ssc install estout

use "${PATH}final_dataset.dta", clear
drop if country=="Canada"
encode appgenre, g(genre)
encode app_id, g(id)
encode country, g(country_id)
*** 1a Berry Logit
** Constructing market size

g outside=newgroup=="OUTSIDE"
bys country: egen total_ms=sum(new_est)
g market_share=new_est/total_ms
bys country outside: egen ms_outside2=sum(new_est) if outside==1
bys country: egen ms_outside=min(ms_outside2)
g market_share_outside=ms_outside/total_ms
drop ms_outside2
g lhs=ln(market_share)-ln(market_share_outside)
** No instruments
reg lhs price iap averagescore if outside==0, robust
scalar bp1 = _b[price]
estimates store bl_ols
** Instrument 1: number of competing apps in same category in same country
bys country genre: g comp_apps=_N-1
ivregress 2sls lhs (price=comp_apps) iap averagescore if outside==0, robust first
scalar bp2 = _b[price]
estimates store bl_iv1
** Instrument 2: iap of other apps
bys country genre: egen sum_iap=total(iap)
g other_iap=(sum_iap-iap)/comp_apps if comp_apps!=0
ivregress 2sls lhs (price=other_iap) iap averagescore if outside==0, robust first
scalar bp3 = _b[price]
estimates store bl_iv2
** Combined instruments
ivregress 2sls lhs (price=other_iap comp_apps) iap averagescore if outside==0, robust first
scalar bp4 = _b[price]
estimates store bl_iv3

** Combined instruments + country FE
ivregress 2sls lhs (price=other_iap comp_apps) iap averagescore i.country_id if outside==0, robust first
scalar bp5 = _b[price]
estimates store bl_iv4


* ============================================================
* TABLE 1: Demand estimates — price only, ticks for controls
* ============================================================

esttab bl_ols bl_iv1 bl_iv2 bl_iv3 bl_iv4 ///
    using "${PATH}berry_logit.tex", replace booktabs ///
    title("Berry logit: demand estimates") ///
    mtitles("OLS" "IV: count" "IV: other IAP" "IV: both" "IV: both + country FE") ///
    keep(price) ///
    coeflabels(price "Price") ///
   cells(b(star fmt(4)) se(par fmt(4))) ///
   star(* 0.10 ** 0.05 *** 0.01) ///
    collabels(none) ///
    indicate("IAP control = iap" ///
             "Average score control = averagescore" ///
			 "Country fixed effects = *.country_id", ///
             labels("\(\checkmark\)" "")) ///
    stats(N r2, fmt(0 3) ///
          labels("Observations" "\(R^{2}\)")) ///
    nonotes ///
    addnotes("Robust standard errors in parentheses." ///
             "\(* p<0.10,\ ** p<0.05,\ *** p<0.01\).")


* ============================================================
* Estimate and store the three first stages
* Each uses the estimation sample of its corresponding IV model
* ============================================================

local z1 comp_apps
local z2 other_iap
local z3 other_iap comp_apps
local z4 other_iap comp_apps

forvalues j = 1/4 {

    estimates restore bl_iv`j'

    local controls iap averagescore
    if `j' == 4 local controls `controls' i.country_id

    quietly regress price `z`j'' `controls' ///
        if e(sample), vce(robust)

    * Robust joint test of excluded instruments only
    quietly test `z`j''
    local excluded_F = r(F)
    local excluded_p = r(p)

    estadd scalar F_excl = `excluded_F'
    estadd scalar p_excl = `excluded_p'

    estimates store bl_fs`j'
}


* ============================================================
* TABLE 2: First stages — all coefficients
* Dependent variable: price
* ============================================================

esttab bl_fs1 bl_fs2 bl_fs3 bl_fs4 ///
    using "${PATH}berry_firststage.tex", replace booktabs ///
    title("First-stage regressions: dependent variable is price") ///
    mtitles("Count" "Other IAP" "Both" "Both + country FE") ///
    order(comp_apps other_iap iap averagescore _cons) ///
	indicate(			 "Country fixed effects = *.country_id", ///
             labels("\(\checkmark\)" "")) ///
    coeflabels(comp_apps "Competing apps" ///
               other_iap "Other apps' IAP" ///
               iap "IAP" ///
               averagescore "Average score" ///
               _cons "Constant") ///
   cells(b(star fmt(4)) se(par fmt(4))) ///
   star(* 0.10 ** 0.05 *** 0.01) ///
    collabels(none) ///
    stats(N r2 F_excl, fmt(0 3 2) ///
          labels("Observations" ///
                 "\(R^{2}\)" ///
                 "F-value")) ///
    nonotes ///
    addnotes("Robust standard errors in parentheses." ///
             "\(* p<0.10,\ ** p<0.05,\ *** p<0.01\).")

* Return to final IV model
estimates restore bl_iv3
*** 1b Nested logit
bys country nest: egen total_nest=sum(new_est)
g ln_market_share_nest=ln(new_est/total_nest)

* Without instruments
reg lhs price iap averagescore ln_market_share_nest ///
    if outside == 0, robust

estimates store nl_ols

* Instrument both price and within-nest log share
ivregress 2sls lhs iap averagescore ///
    (price ln_market_share_nest = other_iap comp_apps) ///
    if outside == 0, robust first

estimates store nl_iv

* Instrument both price and within-nest log share + country FE
ivregress 2sls lhs iap averagescore i.country_id ///
    (price ln_market_share_nest = other_iap comp_apps) ///
    if outside == 0, robust first

estimates store nl_iv2

* ============================================================
* TABLE: Nested-logit demand estimates
* ============================================================

esttab nl_ols nl_iv nl_iv2 ///
    using "${PATH}nested_logit.tex", replace booktabs ///
    title("Nested logit: demand estimates") ///
    mtitles("OLS" "IV: both" "IV: both + country FE") ///
    keep(price ln_market_share_nest) ///
    order(price ln_market_share_nest) ///
    coeflabels(price "Price" ///
               ln_market_share_nest "Within-nest log share") ///
    cells(b(star fmt(4)) se(par fmt(4))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    collabels(none) ///
    indicate("IAP control = iap" ///
             "Average score control = averagescore" ///
			 	"Country fixed effects = *.country_id", ///
             labels("\(\checkmark\)" "")) ///
    stats(N r2, fmt(0 3) ///
          labels("Observations" "\(R^{2}\)")) ///
    nonotes ///
    addnotes("Robust standard errors in parentheses." ///
             "IV instruments both price and within-nest log share" ///
             "using competing-app count and other apps' IAP." ///
             "\(* p<0.10,\ ** p<0.05,\ *** p<0.01\).")



** 2a Cost estimation

** For the purpose of this exercise, apps in the outside group will not have developers. This only impacts 1 developer who has 1 app outside and 1 doesn't but it's more consistent this way as we think of outside option as not offered by a developer
g developer_2=developer if outside==0
bys country developer_2: egen market_size_developer=sum(new_est)
g market_share_developer=market_size_developer/total_ms
save "${PATH}final_dataset_up.dta", replace
keep if country=="United States"

g markup11=-1/(bp1*(1-market_share_developer)) if outside==0
g cost11=price-markup11 if   outside==0

g markup12=-1/(bp2*(1-market_share_developer)) if outside==0
g cost12=price-markup12 if   outside==0

g markup13=-1/(bp3*(1-market_share_developer)) if outside==0
g cost13=price-markup13 if   outside==0

g markup14=-1/(bp4*(1-market_share_developer)) if outside==0
g cost14=price-markup14 if   outside==0

g markup15=-1/(bp5*(1-market_share_developer)) if outside==0
g cost15=price-markup15 if   outside==0


** 2b Cost estimation: all apps are single-product firms

g markup21=-1/(bp1*(1-market_share)) if outside==0
g cost21=price-markup21 if   outside==0

g markup22=-1/(bp2*(1-market_share)) if outside==0
g cost22=price-markup22 if outside==0

g markup23=-1/(bp3*(1-market_share)) if outside==0
g cost23=price-markup23 if outside==0

g markup24=-1/(bp4*(1-market_share)) if outside==0
g cost24=price-markup24 if outside==0

g markup25=-1/(bp5*(1-market_share)) if outside==0
g cost25=price-markup25 if outside==0

** All apps owned by a monopolist (outside options are not!)

g markup31=-1/(bp1*(market_share_outside)) if  outside==0
g cost31=price-markup31 if  outside==0

g markup32=-1/(bp2*(market_share_outside)) if outside==0
g cost32=price-markup32 if outside==0

g markup33=-1/(bp3*(market_share_outside)) if outside==0
g cost33=price-markup33 if  outside==0

g markup34=-1/(bp4*(market_share_outside)) if outside==0
g cost34=price-markup34 if  outside==0

g markup35=-1/(bp5*(market_share_outside)) if outside==0
g cost35=price-markup35 if  outside==0

sum markup11 markup12 markup13 markup14 markup15 markup21 markup22 markup23 markup24 markup25  markup31 markup32 markup33 markup34 markup35


* ============================================================
* TABLE: Markups estimates
* ============================================================
* Rows: ownership scenarios
* Columns: demand specifications

matrix Markups = J(3, 5, .)

forvalues scenario = 1/3 {
    forvalues model = 1/5 {
        quietly summarize markup`scenario'`model' if outside == 0
        matrix Markups[`scenario', `model'] = r(mean)
    }
}

matrix rownames Markups = Current Single Monopoly
matrix colnames Markups = OLS IV_count IV_IAP IV_both IV_bothFE

esttab matrix(Markups, fmt(3)) ///
    using "${PATH}markups_ownership.tex", replace booktabs ///
    title("Average markups under alternative ownership structures") ///
    nomtitles nonumbers ///
    collabels("OLS" "IV: count" "IV: other IAP" "IV: both" "IV: both + Country FE") ///
    coeflabels(Current  "Current ownership" ///
               Single   "Single-product firms" ///
               Monopoly "Monopolist") ///
    addnotes("Mean absolute markup (price minus marginal cost)." ///
             "Unweighted averages across inside apps in the US." ///
             "Observed prices and market shares are held fixed.")
			 
* ============================================================
* TABLE: Cost estimates
* ============================================================
* Rows: ownership scenarios
* Columns: demand specifications

matrix Costs = J(3, 5, .)

forvalues scenario = 1/3 {
    forvalues model = 1/5 {
        quietly summarize cost`scenario'`model' if outside == 0
        matrix Costs[`scenario', `model'] = r(mean)
    }
}

matrix rownames Costs = Current Single Monopoly
matrix colnames Costs = OLS IV_count IV_IAP IV_both IV_bothFE

esttab matrix(Costs, fmt(3)) ///
    using "${PATH}costs_ownership.tex", replace booktabs ///
    title("Average marginal costs under alternative ownership structures") ///
    nomtitles nonumbers ///
    collabels("OLS" "IV: count" "IV: other IAP" "IV: both" "IV: both + Country FE") ///
    coeflabels(Current  "Current ownership" ///
               Single   "Single-product firms" ///
               Monopoly "Monopolist") ///
    addnotes("Mean marginal cost" ///
             "Unweighted averages across inside apps in the US." ///
             "Observed prices and market shares are held fixed.")
