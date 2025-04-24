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
if ((c32_adjCost eq 0),  !! No adjustment costs
  p32_capCostwAdjCost(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) or teStoreTransPy32(te))) = 
    vm_costTeCapital.l(t,regi,te) + EPS;
elseif (c32_adjCost eq 1),  !! Average adjustment costs
  p32_capCostwAdjCost(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) or teStoreTransPy32(te))) = 
    max(0, vm_costTeCapital.l(t,regi,te) + o_avgAdjCostInv(t,regi,te)$( sum(te2rlf(te,rlf), vm_deltaCap.l(t,regi,te,rlf)) ge 1e-5 )) + EPS;
elseif (c32_adjCost eq 2),  !! Marginal adjustment costs
  p32_capCostwAdjCost(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) or teStoreTransPy32(te))) = 
    max(0, vm_costTeCapital.l(t,regi,te) + o_margAdjCostInv(t,regi,te)$( sum(te2rlf(te,rlf), vm_deltaCap.l(t,regi,te,rlf)) ge 1e-5 )) + EPS;
);


!! HACK: Disincentivise oil and nuclear by increasing capital costs by factor 2
!! Oil and nuclear are sometimes used by PyPSA in 2025 only, which doesn't make sense as the investment wouldn't be profitable
!! TODO: Find a way to properly include foresight of key metrics (capacity factors, markups) into capital cost
p32_capCostwAdjCostScaled(t,regi,te) = p32_capCostwAdjCost(t,regi,te);
p32_capCostwAdjCostScaled(t,regi,te)$(tPy32(t) and regPy32(regi) and (sameas(te,"dot") or sameas(te,"tnrs") or sameas(te, "fnrs")) ) = 
    2 * p32_capCostwAdjCost(t,regi,te) + EPS;


!! Export REMIND data for PyPSA (REMIND2PyPSAEUR.gdx)
Execute_Unload "REMIND2PyPSAEUR.gdx",
  !! -- REMIND to PyPSA-Eur --
  !! Coupled time steps, regions and technologies
  tPy32, regPy32, tePy32,
  !! Electricity load
  p32_load,
  !! Additional electrolytic hydrogen demand (from outside power sector)
  p32_ElecH2Demand,
  !! Capital cost components
  p32_capCostwAdjCost, pm_data, p32_discountRate, p32_capCostwAdjCostScaled,
  !! Marginal cost components
  pm_eta_conv, pm_dataeta, p32_PEPriceAvg, pe2se, p_priceCO2, f_dataemiglob,
  !! Weights to calculate weighted averages
  p32_weightGen, p32_weightStor, p32_weightPEprice,
  !! Pre-installed capacities
  p32_preInvCapAvg,
  !! Hydro capacities and generation (special treatment in PyPSA)
  p32_hydroCap, p32_hydroGen,
  !! -- PyPSA-Eur to REMIND -- 
  !! Generation shares in REMIND to downscale generation shares in PyPSA
  v32_shPe2seel
;
option epsToZero=off;

!! Temporarily store and then set numeric round format and number of decimals
sm_tmp  = logfile.nr;
sm_tmp2 = logfile.nd;
logfile.nr = 1;
logfile.nd = 0;

*** EOF ./modules/32_power/IntCwPyPSAexport/postsolve.gms