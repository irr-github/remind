*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/32_power/IntCwPyPSAexport/postsolve.gms

*** calculation of SE electricity price (useful for internal use and reporting purposes)
pm_SEPrice(ttot,regi,entySe)$(abs (qm_budget.m(ttot,regi)) gt sm_eps AND sameas(entySe,"seel")) = 
       q32_balSe.m(ttot,regi,entySe) / qm_budget.m(ttot,regi);

loop(t,
  loop(regi,
    loop(pe2se(enty,enty2,te),
      if ( ( vm_capFac.l(t,regi,te) < (0.999 * vm_capFac.up(t,regi,te) ) ),
        o32_dispatchDownPe2se(t,regi,te) = round ( 100 * (vm_capFac.up(t,regi,te) - vm_capFac.l(t,regi,te) ) / (vm_capFac.up(t,regi,te) + 1e-10) );
      );
    );
  );
);


!! ================   PYPSA EXPORT =======================

!! Track iterations in which PyPSA was executed, this is necessary to calculate averages
s32_PyPSA_called(iteration) = 1;


*** Get electricity load
p32_load(t,regi)$(tPy32(t) and regPy32(regi)) = v32_load.l(t,regi);

*** Get additional electrolytic hydrogen demand (from outside power sector)
*** (1) vm_prodSe.l(t,regi,"seel","seh2","elh2") is the production of hydrogen from electrolysis (TWa hydrogen)
*** (2) vm_demSe.l(t,regi,"seh2","seel","h2turb") is the demand of hydrogen for electricity production (TWa hydrogen)
*** Note that electrolyser efficiency is taken into account in PyPSA
p32_ElecH2Demand(t,regi)$(tPy32(t) AND regPy32(regi)) =
    max(1E-8, vm_prodSe.l(t,regi,"seel","seh2","elh2") - vm_demSe.l(t,regi,"seh2","seel","h2turb")) + EPS;

*** Calculate electricity load of electric vehicles
*** Take pm_eta_conv (transmission & distribution losses) into account
*** in order to yield the corresponding electricity load on the SE level. Tdelt is tech charging
p32_load_EVs(t,regi)$(tPy32(t) AND regPy32(regi)) = 
  sum(emiMkt, vm_demFeSector.l(t,regi,"seel","feelt","trans",emiMkt)) / pm_eta_conv(t,regi,"tdelt")
;


*** Calculate electricity load of buildings heating
*** Take pm_eta_conv (transmission & distribution losses) into account
*** in order to yield the corresponding electricity load on the SE level
p32_load_heating(t,regi)$(tPy32(t) AND regPy32(regi)) = 
  sum(in$(sameas(in, "feelhpb") or sameas(in, "feelrhb")),
      vm_cesIO.l(t,regi,in)
      + pm_cesdata(t,regi,in,"offset_quantity")
  ) / pm_eta_conv(t,regi,"tdels")
;

*** Calculate free capacities that are passed to PyPSA
if (iteration.val lt c32_iter_fullCap,  !! Use pre-investment capacities
  p32_cap(t,regi,te)$(tPy32(t) AND regPy32(regi) AND (tePy32(te) OR teStoreTransPy32(te)) AND NOT sameas(te, "hydro")) =
      max((vm_cap.l(t,regi,te,"1")
    - vm_deltaCap.l(t,regi,te,"1") * pm_ts(t) * ( 1 - vm_capEarlyReti.l(t,regi,te) )),
        1E-6);  !! Minimum capacity of 1 MW to avoid issues in PyPSA-Eur's RCL implementation
else  !! Use full capacities
  p32_cap(t,regi,te)$(tPy32(t) AND regPy32(regi) AND (tePy32(te) OR teStoreTransPy32(te)) AND NOT sameas(te, "hydro")) =
    max(vm_cap.l(t,regi,te,"1"), 1E-6);  !! Minimum capacity of 1 MW to avoid issues in PyPSA-Eur's RCL implementation
);

** Primary energy
p32_pe2seel(t,regi) =	sum(pe2se(enty,"seel",tePy32), vm_prodSe.l(t,regi,enty,"seel",tePy32));

*** Weights (supply or cap) for disaggregation (of n->1 generators and fuel mappings)
p32_pe2seelTe(t,regi,te) = sum(pe2se(all_enty,"seel",te), vm_prodSe.l(t,regi,all_enty,"seel",te) );
* spacer = for debug
p32_weightGen(t,regi,te)$(tPy32(t) AND regPy32(regi) AND tePy32(te)) = p32_pe2seelTe(t,regi,te) + EPS;
p32_weightPEprice(t,regi,entyPe)$(tPy32(t) AND regPy32(regi) AND entyPePy32(entyPe)) = vm_prodPe.l(t,regi,entyPe) + EPS;

** Primary energy shares
p32_shPe2seel(t, regi, te) = p32_pe2seelTe(t,regi,te)/(p32_pe2seel(t,regi)+ EPS);
*** Track PE price over iterations
p32_PEPrice_iter(iteration,ttot,regi,entyPe) = pm_PEPrice(ttot,regi,entyPe);

*** Track pre-investment capacities over iterations
p32_cap_iter(iteration,t,regi,te) = p32_cap(t,regi,te);

!! REMIND to PyPSA-Eur: Calculate averages to reduce oscillations
!! (i) Capacities
!! (ii) Primary energy (PE) prices
!! The idea behind averaging follows three steps:
!! (1) Allow at least x iterations (until max(c32_startIter_PyPSA, x)) without averaging
!! (2) Allow another y iterations (until max(c32_startIter_PyPSA, x) + y) without averaging 
!! (3) Afterwards take the average of the previous y iterations, where y should be an even number
!! Currently set x to 3 and y to 2

!! Implement step (1) and (2): Use non-averaged values always if c32_avg_rm2py = 0
if (( c32_avg_rm2py eq 0 ) or ( iteration.val lt 4 ),  !!
  !! Non-averaged capacities
  p32_capAvg(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) OR teStoreTransPy32(te))) = p32_cap(t,regi,te) + EPS;
  !! Non-averaged PE prices, limited to 0 and 200 EUR/MWh (for uranium 200 T$/Mt corresponds to 1752 $/kg)
  p32_PEPriceAvg(t,regi,entyPe)$(tPy32(t) and regPy32(regi) and entyPePy32(entyPe)) = 
      min(200 * sm_TWa_2_MWh/1E12, max(0, pm_PEPrice(t,regi,entyPe))) + EPS;
!! Implement step (3): Use averaged values only if c32_avg_rm2py = 1 and (because of elseif) only if iteration >= c32_startIter_PyPSA + x + y - 1 
elseif (c32_avg_rm2py eq 1),
    !! Average capacities over past y iterations
    p32_capAvg(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) OR teStoreTransPy32(te))) =
      sum(iteration2$(iteration2.val gt (iteration.val - 4)), s32_PyPSA_called(iteration2) * p32_cap_iter(iteration2,t,regi,te)) /
      sum(iteration2$(iteration2.val gt (iteration.val - 4)), s32_PyPSA_called(iteration2)) + EPS;
    !! Average non-negative PE prices over past y iterations, limited to 0 and 200 EUR/MWh (for uranium 200 T$/Mt corresponds to 1752 $/kg)
    p32_PEPriceAvg(t,regi,entyPe)$(tPy32(t) and regPy32(regi) and entyPePy32(entyPe)) =
      sum(iteration2$(iteration2.val gt (iteration.val - 4)), s32_PyPSA_called(iteration2) * min(200 * sm_TWa_2_MWh/1E12, max(0, p32_PEPrice_iter(iteration2,t,regi,entyPe)))) /
      sum(iteration2$(iteration2.val gt (iteration.val - 4)), s32_PyPSA_called(iteration2)) + EPS;
);


!! Capital interest rate aggregated for all regions in regPy32 (PyPSA-Eur has no regional costs yet)
!! Also see calculation of p_r in core/postsolve.gms
p32_discountRate(ttot)$(tPy32(ttot) and ttot.val le 2100) =
  1 / ( sum(regPy32(regi), pm_ies(regi)) / card(regPy32) ) * 
    ( ( ( sum(regPy32(regi), vm_cons.l(ttot+1,regi)) / sum(regPy32(regi), pm_pop(ttot+1,regi)) )
        /
        ( sum(regPy32(regi), vm_cons.l(ttot-1,regi)) / sum(regPy32(regi), pm_pop(ttot-1,regi)) )
      )
      ** ( 1 / ( pm_ttot_val(ttot+1) - pm_ttot_val(ttot-1) ) )
      - 1
    )
  + sum(regPy32(regi), pm_prtp(regi)) / card(regPy32)
;
  
!! Set the interest rate to 3% after 2100
p32_discountRate(ttot)$(ttot.val gt 2100) = 0.03;

!! Specific capital costs plus adjustment costs
!! w/o adjustment costs
p32_capCost(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) or teStoreTransPy32(te)))
 = 
 vm_costTeCapital.l(t,regi,te) + EPS;
!! w Average adjustment costs
p32_capCostwAvgAdjCost(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) or teStoreTransPy32(te))) 
 = 
 max(0, vm_costTeCapital.l(t,regi,te) + o_avgAdjCostInv(t,regi,te)$( sum(te2rlf(te,rlf), vm_deltaCap.l(t,regi,te,rlf)) ge 1e-5 )) + EPS;
!! Marginal adjustment costs
p32_capCostwMargAdjCost(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) or teStoreTransPy32(te))) = 
  max(0, vm_costTeCapital.l(t,regi,te) + o_margAdjCostInv(t,regi,te)$( sum(te2rlf(te,rlf), vm_deltaCap.l(t,regi,te,rlf)) ge 1e-5 )) + EPS;


!! HACK: Disincentivise oil and nuclear by increasing capital costs by factor 2
!! Oil and nuclear are sometimes used by PyPSA in 2025 only, which doesn't make sense as the investment wouldn't be profitable
!! TODO: Find a way to properly include foresight of key metrics (capacity factors, markups) into capital cost
!! Possible solution: use intertemp weighed carbon cost
p32_capCostwMargAdjCostScaled(t,regi,te) = p32_capCostwMargAdjCost(t,regi,te);
p32_capCostwMargAdjCostScaled(t,regi,te)$(tPy32(t) and regPy32(regi) and (sameas(te,"dot") or sameas(te,"tnrs") or sameas(te, "fnrs")) ) = 
    2 * p32_capCostwMargAdjCost(t,regi,te) + EPS;
p32_capCostwAvgAdjCostScaled(t,regi,te) = p32_capCostwAvgAdjCost(t,regi,te);
p32_capCostwAvgAdjCostScaled(t,regi,te)$(tPy32(t) and regPy32(regi) and (sameas(te,"dot") or sameas(te,"tnrs") or sameas(te, "fnrs")) ) = 
    2 * p32_capCostwAvgAdjCost(t,regi,te) + EPS;
p32_capCostScaled(t,regi,te) = p32_capCost(t,regi,te);
p32_capCostScaled(t,regi,te)$(tPy32(t) and regPy32(regi) and (sameas(te,"dot") or sameas(te,"tnrs") or sameas(te, "fnrs")) ) = 
    2 * p32_capCost(t,regi,te) + EPS;


$call mkdir ./pypsa_export
EmbeddedCode Python:
  import os
  is_dir = os.path.isdir("./pypsa_export")
  gams.printLog(f"Is pypsa_export dir? {is_dir}")
  if not is_dir:
      os.mkdir("./pypsa_export")
      gams.printLog("Created pypsa_export dir")
endEmbeddedCode

!! Export REMIND data for PyPSA (REMIND2PyPSAEUR.gdx)
Execute_Unload "REMIND2PyPSAEUR.gdx",
  !! -- REMIND to PyPSA-Eur --
  !! Coupled time steps, regions and technologies
  c_model_version,
  tPy32, regPy32, tePy32,
  !! Electricity load
  p32_load, 
  !! Additional electrolytic hydrogen demand (from outside power sector)
  p32_ElecH2Demand,
  !! Capital cost components
  p32_capCost, p32_capCostScaled, p32_capCostwMargAdjCost, p32_capCostwMargAdjCostScaled,
  p32_capCostwAvgAdjCost, p32_capCostwAvgAdjCostScaled,
  pm_data, p32_discountRate, c32_adjCost
  !! Marginal cost components
  pm_eta_conv, pm_dataeta, p32_PEPriceAvg, pe2se, p_priceCO2, f_dataemiglob,
  !! co2
  pm_emifac,
  !! Weights to calculate weighted averages
  p32_weightGen, p32_weightStor, p32_weightPEprice,
  !! Pre-installed capacities
  p32_preInvCapAvg, p32_cap, p32_cap_iter
  !! Hydro capacities and generation (special treatment in PyPSA)
  p32_hydroCap, p32_hydroGen,
  !! -- PyPSA-Eur to REMIND -- 
  !! Generation shares in REMIND to downscale generation shares in PyPSA
  !! Share of el
  p32_pe2seelTe, p32_shPe2seel, p32_pe2seel
;

option epsToZero=off;



!! Temporarily store and then set numeric round format and number of decimals
sm_tmp  = logfile.nr;
sm_tmp2 = logfile.nd;
logfile.nr = 1;
logfile.nd = 0;





** EXPORT PyPSA relevant params/vars/other TO HDF5
embeddedCode Python:

import pandas as pd
from numpy import __version__
gams.printLog("=== Exporting PyPSA relevant data. Warning: export is to Pickle, which requires a matching numpy version ====")
gams.printLog(f"Gams numpy version is {__version__}")

PARAMS = ["c_model_version", "tPy32", "regPy32", "tePy32", "p32_load", "p32_ElecH2Demand", "p32_capCost",
 "p32_capCostScaled", "p32_capCostwMargAdjCost", "p32_capCostwMargAdjCostScaled", "p32_capCostwAvgAdjCost",
  "p32_capCostwAvgAdjCostScaled", "pm_data", "p32_discountRate", "c32_adjCost", "pm_eta_conv", "pm_dataeta", 
  "p32_PEPriceAvg", "pe2se", "p_priceCO2", "f_dataemiglob", "p32_weightGen", "p32_weightStor", "p32_weightPEprice", 
  "p32_preInvCapAvg", "p32_hydroCap", "p32_hydroGen", "p32_pe2seelTe", "p32_shPe2seel", "p32_pe2seel", "pm_emifac"]


def param_to_pandas(par_name:str)->pd.DataFrame:
    """ Convert GAMS parameter to pandas dataframe
    """
    par = gams.get(par_name)
   
    # need diff treatment for dimension 1 params
    if par._dim >1:
        df = pd.DataFrame(list(par), columns=['Index', 'Value'])
        df.set_index(pd.MultiIndex.from_tuples(df['Index']), inplace=True)
        df.drop(columns=['Index'], inplace=True)
        # add par_name to index
        df["variable"] = par_name
        df = df.set_index("variable", append=True)
        df.index = df.index.reorder_levels(order=[-1]+[i for i in range(len(df.index.levels)-1)])
    else:
        df = pd.DataFrame(par, columns = ["dim1", "Value"])
        df["variable"] = par_name
        df = df.set_index("variable", append=True)
    
    df.loc[:, "Value"] = df.Value.astype(float)

    return df

# loop over params and export to csv. Concat to giant pickle
df = pd.DataFrame()
for par in PARAMS:
    try:
        df_ = param_to_pandas(par)
        df_.to_csv(f"./pypsa_export/{par}.csv")
        df = pd.concat([df, df_], axis =0)
    except Exception as e:
        gams.printLog(f"Error {e} - param {par} was skipped")
df.to_pickle("./pypsa_export/REMIND_export.pkl")

endEmbeddedCode

* export region mappings
EmbeddedCode Connect:
- GAMSReader:
    symbols:
      - name: regi2iso
- CSVWriter:
    file: "pypsa_export/region_mappings.csv"
    name: regi2iso
    valueSubstitutions: {'EPS': 0}
endEmbeddedCode
*** EOF ./modules/32_power/IntCwPyPSAexport/postsolve.gms