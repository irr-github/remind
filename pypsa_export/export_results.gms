$Ontext
Very ugly script to export full.gdx results to PyPSA
Emulator of Adrian's Power32 implementation for 1 way coupling and without equations
$Offtext


* remind sets 
Sets
c_model_version
all_regi
rlf
tall
tott(tall)
all_te
all_enty
entyPe(all_enty)
all_in
char /
    "lifetime"
    "omf"
    "omv"
    /
teCCS2rlf(all_te,rlf)     "mapping for CCS technologies to grades"
entySe(all_enty)
entyFe(all_enty)
rlf  "cost levels of fossil fuels"
se2fe(all_enty,all_enty,all_te)
pe2se(all_enty,all_enty,all_te)
pe2rlf(all_enty,rlf)
pm_ts(tall)                                          "(t_n+1 - t_n-1)/2 for a timestep t_n"
iteration
te2rlf(all_te,rlf)
pc2te(all_enty,all_enty,all_te,all_enty)
all_emiMkt      "emission markets"
/
    ETS     "ETS emission market"
    ES      "Effort sharing emission market"
    other   "other market configurations"
/
emi_sectors  "comprehensive sector set used for more detailed emissions accounting (REMIND-EU) and for CH4 tier 1 scaling - potentially to be integrated with similar set all_exogEmi"
/
    power   "public electricity and heat production"
    refining "petroleum refining"
    solids  "manufacture of solid fuels and other energy industries"
    extraction "fugitive emissions from fuel extraction"
    build   "Commercial sector, institutional sector and households"
    indst   "industry (including industrial processes)"
    trans   "transportation"
    agriculture "agriculture (plus forestry and fishing energy use)"
    waste   "waste management"
    cdr     "Transport, capture and storage of CO2"
    lulucf  "Land use,  land use change,  and forestry (LULUCF)"
    bunkers "International bunkers (maritime and aviation)"
    other   "other sectors and multilateral operations"
    indirect
/
cesParameter   "parameters of the CES functions and for calibration"
/
  quantity          "quantity of CES function input/output"
  price             "price of CES function input/output"
  eff               "baseyear efficiency of CES function input/output"
  effgr             "multiplicative efficiency growth of CES function input/output"
  rho               "CES function elasticity parameter rho = 1 - (1 / sigma)"
  xi                "baseyear income share of CES function input/output"
  offset_quantity   "quantity offset for the CES tree if the quantity is null"
  compl_coef        "coefficients for the perfectly complementary factors"
/

;
alias(all_enty,all_enty2);
alias(all_enty,enty);
alias(enty,enty2,enty3,enty4,enty5,enty6,enty7);
alias(rlf,rlf2);
alias(all_regi, regi)
alias(all_te,te)

* vanilla remind variables and parameters
Variables
    vm_co2CCS(ttot,all_regi,all_enty,all_enty,all_te,rlf)
    vm_prodPe(ttot,all_regi,all_enty)                    "pe production. [TWa, Uranium: Mt Ur]"
    vm_demSe(ttot,all_regi,all_enty,all_enty,all_te)     "se demand. [TWa]"
    vm_prodSe(tall,all_regi,all_enty,all_enty,all_te)    "se production. [TWa]"
    vm_prodFe(ttot,all_regi,all_enty,all_enty,all_te)    "fe production. [TWa]"
    vm_fuExtr(ttot,all_regi,all_enty,rlf)                "fuel use [TWa]"
    vm_demFeSector(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt)          "fe demand per sector and emission market. Taxes should be applied to this variable or variables closer to the supply side whenever possible so the marginal prices include the tax effects. [TWa]"
    vm_cesIO(tall,all_regi,all_in)                                  "Production factor"
    vm_deltaCap(tall,all_regi,all_te,rlf)                "capacity additions"
    vm_cap(tall,all_regi,all_te,rlf)                     "net total capacities"
    vm_capEarlyReti(tall,all_regi,all_te)
    vm_cons
    vm_costTeCapital(ttot,all_regi,all_te)               "investment costs"
;
parameters
    sm_PyPSA_eq                                                                                                                          
    pm_data(all_regi,char,all_te)  
    pm_eta_conv(ttot,all_regi,all_te) 
    pm_dataeta(ttot,all_regi,all_te) 
    p_priceCO2(ttot, all_regi)
    f_dataemiglob
    pm_emifac(ttot,all_regi,all_enty,all_enty,all_te,all_enty)
    pm_taxCO2eq(ttot,all_regi)
    pm_taxCO2eq(ttot,all_regi)
    pm_fuExtrOwnCons(all_regi, all_enty, all_enty) "Own consumption of fuel extraction in region regi for final energy enty2 from primary energy enty3"
    pm_prodCouple(all_regi,all_enty,all_enty,all_te,all_enty)       "own consumption"
    pm_cesdata(tall,all_regi,all_in,cesParameter)
    pm_PEPrice(ttot,all_regi,all_enty)                    "parameter to capture all PE prices [tr$2005/TWa]"
    pm_prodPe
    pm_pop
    pm_ies
    pm_ttot_val
    pm_prtp
    o_avgAdjCostInv
    o_margAdjCostInv
;

* load the gdx file with the results

$gdxin "/home/ivanra/downloads/fulldata_normal_run_ssp21000.gdx"
*$gdxin "/home/ivanra/downloads/REMIND2PyPSAEUR_IR.gdx"
$load  c_model_version=c_model_version
$load  tall=tall
$load  ttot=ttot
$load rlf=rlf
$load all_in=all_in
$load all_enty=all_enty
$load entySe=entySe
$load entyFe=entyFe
$load all_te = all_te
$load entyPe=entyPe
$load pe2se=pe2se
$load pm_ts=pm_ts
$load pm_pop
$load vm_cons
$load pm_ies
$load te2rlf
$load    pm_ttot_val
$load    pm_prtp
$load     o_avgAdjCostInv
$load    o_margAdjCostInv
$load teCCS2rlf=teCCS2rlf
*$load  tPy32=tPy32
$load  all_regi=all_regi
$load  pm_data=pm_data
$load  pm_eta_conv=pm_eta_conv
$load  pm_dataeta=pm_dataeta
$load pm_PEPrice=pm_PEPrice
$load  p_priceCO2=p_priceCO2
$load  f_dataemiglob=f_dataemiglob
$load  pm_emifac=pm_emifac
$load  pm_taxCO2eq=pm_taxCO2eq
$load  pm_fuExtrOwnCons=pm_fuExtrOwnCons
$load  se2fe=se2fe
$load  pe2rlf=pe2rlf
$load  iteration=iteration
$load  vm_demSe=vm_demSe
$load  vm_prodFe=vm_prodFe
$load  vm_prodSe=vm_prodSe
$load  vm_co2CCS = vm_co2CCS
$load  vm_fuExtr = vm_fuExtr
$load  vm_cesIO=vm_cesIO
$load vm_cap = vm_cap
$load vm_costTeCapital
$load vm_deltaCap=vm_deltaCap
$load  vm_demFeSector=vm_demFeSector
$load  pm_prodCouple=pm_prodCouple
$load vm_capEarlyReti=vm_capEarlyReti
$load  pc2te=pc2te
$load pm_cesdata=pm_cesdata
$load vm_prodPe=vm_prodPe
$gdxin

alias(all_emiMkt,emiMkt,emiMkt2);

** DECLARE ALL SYMBOLS FOR COUPLING
sets
tePy32(all_te)  "Electricity generation technologies coupled to PyPSA" /
    biochp
    bioigcc
    bioigccc
    ngcc
    ngccc
    gaschp
    igcc
    igccc
    pc
    coalchp
    tnrs
    fnrs
    ngt
    windoff
    dot
    windon
    hydro
    spv
    /  
tePyDisp32  "Dispatchable electricity technologies coupled to PyPSA (without grades) used for peak residual gdx"
        /
        biochp
        bioigcc
        bioigccc
        ngcc
        ngccc
        gaschp
        igcc
        igccc
        pc
        coalchp
        tnrs
        fnrs
        ngt
        dot
        /
tePyVRE32(te)          "Variable renewable electricity technologies coupled to PyPSA (with grades) used for potentials if applicable"
        /
        windoff
        windon
        hydro
        spv
        /

entyPePy32(entyPe)       "Primary energy carriers for which prices are coupled to PyPSA"
        /
        peoil
        pegas
        pecoal
        peur
        pebiolc
        /

teStoreTransPy32   "Storage and transmission technologies coupled to PyPSA"
        /
        elh2
        h2turb
        h2stor
        btin
        btout
        btstor
        /

teStorePy32      "Storage technologies coupled to PyPSA (not conversion but size of store in TWh)"
        /
        h2stor
        btstor
        /
        
tPy32(ttot) "time"
    /
    2020
    2025
    2030
    2035
    2040
    2045
    2050
    2055
    2060
    2070
    2080
    2090
    2100
    /
regPy32 /"CHA"/
rep32                       "Generic set for PyPSA reporting"
        /1*20/
;
Scalars
    sm_TWa_2_MWh                 "tera Watt year to Mega Watt hour"                    /8.76e+9/
;
parameters
    p32_load(ttot,all_regi)                                         "PyPSA export: Electricity load [TWa]"
    p32_load_EVs(ttot,all_regi)                                     "PyPSA export: Electricity load for EVs, corrected to corresponding SE electricity load [TWa]"
    p32_load_heating(ttot,all_regi)                                 "PyPSA export: Electricity load for buildings heating, corrected to corresponding SE electricity load [TWa]"
    p32_ElecH2Demand(ttot,all_regi)                                 "PyPSA export: Electrolytic hydrogen demand outside the power sector [TWa]"
    p32_preInvCap(ttot,all_regi,all_te)                             "PyPSA export: Pre-investment capacities [TW for generation/link, TWh for storage]"
    p32_preInvCap_iter(iteration,ttot,all_regi,all_te)              "PyPSA export: Pre-investment capacities in iterations [TW for generation/link, TWh for storage]"
    p32_preInvCapAvg(ttot,all_regi,all_te)                          "PyPSA export: Pre-investment capacities averaged over iterations [TW for generation/link, TWh for storage]"
    p32_discountRate(ttot)                                          "PyPSA export: Interest rate / discount rate aggregated across all regions in regPy32 [1]"
    p32_cap(ttot,all_regi,all_te)                                   "PyPSA export: Pre-investment capacities [TW for generation/link, TWh for storage]"
    p32_cap_iter(iteration,ttot,all_regi,all_te)                    "PyPSA export: Pre-investment capacities in iterations [TW for generation/link, TWh for storage]"
    p32_capCost(ttot,all_regi,all_te)                               "PyPSA export: Specific capital costs w/o adj costs [T$/TW_out for generation/link, T$/TWh for storage]"
    p32_capCostScaled(ttot,all_regi,all_te)                         "PyPSA export: Specific capital costs w/o costs. Nuclear and oild disencentivised for PyPSA"   
    p32_capCostwMargAdjCost(ttot,all_regi,all_te)                   "PyPSA export: Specific capital costs plus marginal adjustment costs [T$/TW_out for generation/link, T$/TWh for storage]"
    p32_capCostwMargAdjCostScaled(ttot,all_regi,all_te)             "PyPSA export: Specific capital costs + marginal adj costs. Nuclear and oild disencentivised for PyPSA"   
    p32_capCostwAvgAdjCost(ttot,all_regi,all_te)                    "PyPSA export: Specific capital costs plus avg adjustment costs [T$/TW_out for generation/link, T$/TWh for storage]"
    p32_capCostwAvgAdjCostScaled(ttot,all_regi,all_te)              "PyPSA export: Specific capital costs + avg adj costs. Nuclear and oild disencentivised for PyPSA"   
    p32_PEPrice_iter(iteration,ttot,all_regi,all_enty)              "PyPSA export: PE price in iterations [T$/TWa, nuclear: T$/Mt]"
    p32_ElecH2Demand(ttot,all_regi)                                 "PyPSA export: Electrolytic hydrogen demand outside the power sector [TWa]"
    p32_PEPriceAvg(ttot,all_regi,all_enty)                          "PyPSA export: PE price averaged over iterations [T$/TWa, nuclear: T$/Mt]"
    p32_weightGen(ttot,all_regi,all_te)                             "PyPSA export: Weights for generation technologies [TWa]"
    p32_weightStor(ttot,all_regi,all_te)                            "PyPSA export: Weights for storage technologies, currently electrolysis and hydrogen turbines [TWa]"
    p32_weightPEprice(ttot,all_regi,all_enty)                       "PyPSA export: Weights for primary energy prices [TWa]"
    p32_hydroCap(ttot,all_regi)                                     "PyPSA export: Hydro capacity [TW]"
    p32_hydroGen(ttot,all_regi)                                     "PyPSA export: Hydro generation [TWa]"
    p32_PyPSA_CF(ttot,all_regi,all_te)                              "PyPSA import: Capacity factors [1]"
    p32_PyPSA_CF_iter(iteration,ttot,all_regi,all_te)               "PyPSA import calc: Capacity factors in iterations [1]"
    p32_PyPSA_CFAvg(ttot,all_regi,all_te)                           "PyPSA import calc: Capacity factors averaged over iterations [1]"
    p32_PyPSA_MarkupSupply(ttot,all_regi,all_te)                    "PyPSA import: Markups for electricity technologies according to PyPSA-Eur [$/MWh]"
    p32_PyPSA_MarkupSupply_iter(iteration,ttot,all_regi,all_te)     "PyPSA import calc: Markups in iterations [$/MWh]"
    p32_PyPSA_MarkupSupplyAvg(ttot,all_regi,all_te)                 "PyPSA import calc: Markups averaged over iterations [$/MWh]"
    p32_PyPSA_PeakResLoadRel(ttot,all_regi)                         "PyPSA import: Peak residual load relative to average load [1]"
    p32_PyPSA_shPe2seel(ttot,all_regi,all_te)                       "PyPSA import: Electricity generation share by technology within region [1]"
    p32_PyPSA_H2TurbRel(ttot,all_regi)                              "PyPSA import: Hydrogen turbine supply relative to total load [1]"
    p32_PyPSA_BatteryDischargeRel(ttot,all_regi)                    "PyPSA import: Battery discharge relative to total load [1]"
    p32_PyPSA_Trade(ttot,all_regi,all_regi)                         "PyPSA import: Electricity exports from region 1 to region 2 [MWh]" 
    p32_PyPSA_TradePriceImport(ttot,all_regi,all_regi)              "PyPSA import: Price for electricity imports paid by region 2 due to trade with region 1 [$/MWh]"
    p32_PyPSA_TradePriceExport(ttot,all_regi,all_regi)              "PyPSA import: Price for electricity exports received by region 1 due to trade with region 2 [$/MWh]"
    p32_PyPSA_Potential(ttot,all_regi,all_te)                       "PyPSA import: VRE potentials by technology within region [MW]"
    p32_PyPSA_shPe2seelRegi(ttot,all_regi)                          "PyPSA import: Electricity generation share across coupled regions [1]"
    p32_PyPSA_AF(ttot,all_regi,all_te)                              "PyPSA import: Availability factors [1]"
    p32_PyPSA_GridLossesRel(ttot,all_regi)                          "PyPSA import: Transmission losses relative to total load [1]"
    p32_PyPSA_OptCap(ttot,all_regi,all_te)                          "PyPSA import: Optimal capacities [MW for generators/links, MWh for stores]. Attention: Links w.r.t. input!"
    p32_PyPSA_DQ_CF(ttot,all_regi,all_te,all_te)                    "PyPSA import: Difference quotient of capacity factors w.r.t perturbations of capacity [1/MW]"
    p32_PyPSA_DQ_MarkupSupply(ttot,all_regi,all_te,all_te)          "PyPSA import: Difference quotient of supply-side markups w.r.t perturbations of capacity [($/MWh)/MW]"
    p32_capAvg(ttot,all_regi,all_te)                                "PyPSA export: Average capacity of generation and storage technologies"
    p32_PyPSA_AdjCost(ttot,all_regi,all_te)                         "PyPSA import: Adjustment costs for generation and storage technologies [T$/TW_out for generation/link, T$/TWh for storage]"
    p32_anticipation_CF(ttot, all_regi,all_te)                      "PyPSA coupling: Manual anticipation factor for the capacity factor [1]"
    p32_anticipation_MV(all_regi,all_te)                            "PyPSA coupling: Manual cnticipation factor for the market value [1]"
    p32_usableSeDispForeign(ttot,all_regi)                          "PyPSA coupling: Foreign usable SE electricity generation, without own consumption, without imports/exports [TWa]"
    p32_hydroCorrectionFactor(ttot,all_regi)                        "PyPSA coupling: Hydro correction factor, defined as availability factor / capacity factor of previous iteration [1]"
    sm_PyPSA_eq                                                     "PyPSA coupling: Boolean that activates PyPSA coupling equations (1 = on, 0 = off)"
    s32_checkPrice                                                  "PyPSA coupling: Boolean that checks if budget equation is binding (1 = yes, 0 = no)"
    s32_checkPrice_iter(iteration)                                  "PyPSA coupling: s32_checkPrice in iterations"
    s32_anticipationFactorFadeOut                                   "PyPSA coupling: Multiplicative factor to fade out ancitipation factors [1]"
    s32_PyPSA_called(iteration)                                     "PyPSA coupling: Boolean that tracks if PyPSA was called over iterations, necessary for averaging (1 = yes, 0 = no)"
    c32_iter_fullCap
    c32_adjCost                                                     "PyPSA coupling: Switch controlling whether adj costs added to CAPEX (0 = off, 1= avg, 2 = marg)"
    c32_avg_rm2py                                                   "PyPSA coupling: Switch for averaing over iters (1 = on, 0 = off)"
    c32_NucOilDisincentivFac                                        "PyPSA coupling: Factor for disincentivising nuclear and oil, set automatically (1 = on, 0 = off)"
    p32_PeakResLoadShadowPrice(ttot,all_regi,all_te)                "PyPSA reporting: Shadow price of peak residual load constraint, used for plotting LCOEs vs. market values [T$/TWa]"
    p32_ElecBalance(ttot,all_regi,rep32)                            "PyPSA reporting: Electricity balance [TWa]"
    p32_pe2seelTe(ttot,all_regi,all_te)                             "PyPSA coupling: Domestic generation of SE electricity from primary energy carriers by coupled technology [TWa]"  
    p32_pe2seel(ttot,all_regi)                                      "PyPSA coupling/export: Share of domestic generation of SE electricity from primary energy carriers by coupled technology [1]"
    p32_shPe2seel(ttot,all_regi,all_te)                             "PyPSA coupling/export: Share of domestic generation of SE electricity from primary energy carriers by coupled technology [1]"
    pm_prodSe(ttot,all_regi,enty,enty3,te)
    pm_cesIO(ttot,all_regi,all_in)
;

*** Positive variables for the PyPSA coupling
positive variables
    v32_load(ttot,regi)                                         "PyPSA coupling: Electricity load [TWa]"
    v32_pe2seel(ttot,all_regi)                                      "PyPSA coupling: Domestic generation of SE electricity from primary energy carriers for all coupled technologies [TWa]"
    v32_pe2seelTe(ttot,all_regi,all_te)                             "PyPSA coupling: Domestic generation of SE electricity from primary energy carriers by coupled technology [TWa]"
* v32_shPe2seel(ttot,all_regi,all_te)                             "PyPSA coupling/export: Share of domestic generation of SE electricity from primary energy carriers by coupled technology [1]"
    v32_gridLosses(ttot,all_regi)                                   "PyPSA coupling: Grid losses [TWa]"
;



alias(ttot, t);



* ============== EMULATE Switches ============= *

c32_adjCost = 0            ;
c32_avg_rm2py  = 0          ;
c32_NucOilDisincentivFac = 1;
c32_iter_fullCap = 5;

* ========= derived params for coupling ================== *

*pm_prodSe(t,regi,enty,enty3,te)$(tall(t)) = vm_prodSe.l(t,regi,enty,enty3,te);
pm_prodSe(t,regi,enty,enty3,te) = 
  sum(tall$sameas(t,tall), vm_prodSe.l(tall,regi,enty,enty3,te));
  

pm_cesIO(ttot,regi,all_in) =
    sum(tall$sameas(ttot,tall), vm_cesIO.l(tall,regi,all_in));



*** Get electricity load after Adrian
p32_load(t,regi)$(tPy32(t) and regPy32(regi)) =
  sum(se2fe("seel",enty3,te), vm_demSe.l(t,regi,"seel",enty3,te))
  + sum(pe2rlf(enty3,rlf2), 
         (pm_fuExtrOwnCons(regi, "seel", enty3) * vm_fuExtr.l(t,regi,enty3,rlf2))
         $(pm_fuExtrOwnCons(regi, "seel", enty3) > 0)
       )$(t.val > 2005)
  - sum(pc2te(enty,entySe(enty3),te,"seel"), 
         pm_prodCouple(regi,enty,enty3,te,"seel") * pm_prodSe(t,regi,enty,enty3,te) )
  - sum(pc2te(enty4,entyFe(enty5),te,"seel"), 
         pm_prodCouple(regi,enty4,enty5,te,"seel") * vm_prodFe.l(t,regi,enty4,enty5,te) )
  - sum(pc2te(enty,enty3,te,"seel"),
        sum(teCCS2rlf(te,rlf),
            pm_prodCouple(regi,enty,enty3,te,"seel") * vm_co2CCS.l(t,regi,enty,enty3,te,rlf)) )
;
            



*** Get additional electrolytic hydrogen demand (from outside power sector)
*** (1) vm_prodSe.l(t,regi,"seel","seh2","elh2") is the production of hydrogen from electrolysis (TWa hydrogen)
*** (2) vm_demSe.l(t,regi,"seh2","seel","h2turb") is the demand of hydrogen for electricity production (TWa hydrogen)
*** Note that electrolyser efficiency is taken into account in PyPSA
p32_ElecH2Demand(t,regi)$(tPy32(t) AND regPy32(regi)) =
    max(1E-8, pm_prodSe(t,regi,"seel","seh2","elh2") - vm_demSe.l(t,regi,"seh2","seel","h2turb")) + EPS;

*** Calculate electricity load of electric vehicles
*** Take pm_eta_conv (transmission & distribution losses) into account
*** in order to yield the corresponding electricity load on the SE level. Tdelt is tech charging
p32_load_EVs(t,regi)$(tPy32(t) AND regPy32(regi)) = 
  sum(emiMkt, vm_demFeSector.l(t,regi,"seel","feelt","trans",emiMkt)) / pm_eta_conv(t,regi,"tdelt");


*** Calculate electricity load of buildings heating
*** Take pm_eta_conv (transmission & distribution losses) into account

p32_load_heating(t,regi)$(tPy32(t) AND regPy32(regi)) = 
  sum(all_in$(sameas(all_in, "feelhpb") or sameas(all_in, "feelrhb")),
      pm_cesIO(t,regi,all_in)
      + sum(tall$sameas(t,tall), pm_cesdata(tall,regi,all_in,"offset_quantity"))
  ) / pm_eta_conv(t,regi,"tdels");

*** Calculate free capacities that are passed to PyPSA
*** Calculate free capacities that are passed to PyPSA
*  !! Use full capacitiesfro 1 way coupling
  p32_cap(t,regi,te)$(tPy32(t) AND regPy32(regi) AND (tePy32(te) OR teStoreTransPy32(te)) AND NOT sameas(te, "hydro")) =
    max(sum(tall$sameas(t,tall),vm_cap.l(tall,regi,te,"1")), 1E-6);
*  !! Minimum capacity of 1 MW to avoid issues in PyPSA-Eur's RCL implementation


** Primary energy
p32_pe2seel(t,regi) =   sum(pe2se(enty,"seel",tePy32), pm_prodSe(t,regi,enty,"seel",tePy32));

*** Weights (supply or cap) for disaggregation (of n->1 generators and fuel mappings)
p32_pe2seelTe(t,regi,te) = sum(pe2se(all_enty,"seel",te), pm_prodSe(t,regi,all_enty,"seel",te) );
* spacer = for debug
p32_weightGen(t,regi,te)$(tPy32(t) AND regPy32(regi) AND tePy32(te)) = p32_pe2seelTe(t,regi,te) + EPS;
p32_weightPEprice(t,regi,entyPe)$(tPy32(t) AND regPy32(regi) AND entyPePy32(entyPe)) = vm_prodPe.l(t,regi,entyPe) + EPS;
* TODO weight CAP

** Primary energy shares
p32_shPe2seel(t, regi, te) = p32_pe2seelTe(t,regi,te)/(p32_pe2seel(t,regi)+ EPS);
*** Track PE price over iterations
p32_PEPrice_iter(iteration,ttot,regi,entyPe) = pm_PEPrice(ttot,regi,entyPe);

*** Track pre-investment capacities over iterations
p32_cap_iter(iteration,t,regi,te) = p32_cap(t,regi,te);

*!! REMIND to PyPSA-Eur: Calculate averages to reduce oscillations
*!! (i) Capacities
*!! (ii) Primary energy (PE) prices
*!! The idea behind averaging follows three steps:
*!! (1) Allow at least x iterations (until max(c32_startIter_PyPSA, x)) without averaging
*!! (2) Allow another y iterations (until max(c32_startIter_PyPSA, x) + y) without averaging 
*!! (3) Afterwards take the average of the previous y iterations, where y should be an even number
*!! Currently set x to 3 and y to 2
*
*!! Implement step (1) and (2): Use non-averaged values always if c32_avg_rm2py = 0

p32_capAvg(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) OR teStoreTransPy32(te))) = p32_cap(t,regi,te) + EPS;
*  !! Non-averaged PE prices, limited to 0 and 200 EUR/MWh (for uranium 200 T$/Mt corresponds to 1752 $/kg)
p32_PEPriceAvg(t,regi,entyPe)$(tPy32(t) and regPy32(regi) and entyPePy32(entyPe)) = 
      min(200 * sm_TWa_2_MWh/1E12, max(0, pm_PEPrice(t,regi,entyPe))) + EPS;



*!! Capital interest rate aggregated for all regions in regPy32 (PyPSA-Eur has no regional costs yet)
*!! Also see calculation of p_r in core/postsolve.gms
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
  
*!! Set the interest rate to 3% after 2100
p32_discountRate(ttot)$(ttot.val gt 2100) = 0.03;

*!! Specific capital costs plus adjustment costs
*!! w/o adjustment costs
p32_capCost(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) or teStoreTransPy32(te)))
 = vm_costTeCapital.l(t,regi,te) + EPS;
*!! w Average adjustment costs
p32_capCostwAvgAdjCost(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) or teStoreTransPy32(te))) 
 = 
 max(0, vm_costTeCapital.l(t,regi,te) + o_avgAdjCostInv(t,regi,te)$( sum(te2rlf(te,rlf), sum(tall$sameas(tall,t), vm_deltaCap.l(tall,regi,te,rlf))) ge 1e-5 )) + EPS;
*!! Marginal adjustment costs
p32_capCostwMargAdjCost(t,regi,te)$(tPy32(t) and regPy32(regi) and (tePy32(te) or teStoreTransPy32(te))) = 
  max(0, vm_costTeCapital.l(t,regi,te) + o_margAdjCostInv(t,regi,te)$( sum(te2rlf(te,rlf), sum(tall$sameas(tall,t), vm_deltaCap.l(tall,regi,te,rlf))) ge 1e-5 )) + EPS;


*!! HACK: Disincentivise oil and nuclear by increasing capital costs by factor 2
*!! Oil and nuclear are sometimes used by PyPSA in 2025 only, which doesn't make sense as the investment wouldn't be profitable
*!! TODO: Find a way to properly include foresight of key metrics (capacity factors, markups) into capital cost
*!! Possible solution: use intertemp weighed carbon cost
p32_capCostwMargAdjCostScaled(t,regi,te) = p32_capCostwMargAdjCost(t,regi,te);
p32_capCostwMargAdjCostScaled(t,regi,te)$(tPy32(t) and regPy32(regi) and (sameas(te,"dot") or sameas(te,"tnrs") or sameas(te, "fnrs")) ) = 
    2 * p32_capCostwMargAdjCost(t,regi,te) + EPS;
p32_capCostwAvgAdjCostScaled(t,regi,te) = p32_capCostwAvgAdjCost(t,regi,te);
p32_capCostwAvgAdjCostScaled(t,regi,te)$(tPy32(t) and regPy32(regi) and (sameas(te,"dot") or sameas(te,"tnrs") or sameas(te, "fnrs")) ) = 
    2 * p32_capCostwAvgAdjCost(t,regi,te) + EPS;
p32_capCostScaled(t,regi,te) = p32_capCost(t,regi,te);
p32_capCostScaled(t,regi,te)$(tPy32(t) and regPy32(regi) and (sameas(te,"dot") or sameas(te,"tnrs") or sameas(te, "fnrs")) ) = 
    2 * p32_capCost(t,regi,te) + EPS;


* ==== EXPORT TO CSV ====
EmbeddedCode Python:
"""
Programatic loop over gams connect CSV export
"""
import yaml, os
from gams.connect import ConnectDatabase
cdb = ConnectDatabase(gams._system_directory, ecdb=gams)

PARAMS = ["tPy32", "regPy32", "tePy32", "p32_load", "p32_ElecH2Demand", "p32_capCost", "ttot", "p32_cap",
 "p32_capCostScaled", "p32_capCostwMargAdjCost", "p32_capCostwMargAdjCostScaled", "p32_capCostwAvgAdjCost",
  "p32_capCostwAvgAdjCostScaled", "pm_data", "p32_discountRate", "c32_adjCost", "pm_eta_conv", "pm_dataeta", 
  "p32_PEPriceAvg", "pe2se", "p_priceCO2", "f_dataemiglob", "p32_weightGen", "p32_weightStor", "p32_weightPEprice", 
  "p32_preInvCapAvg", "p32_hydroCap", "p32_hydroGen", "v32_shPe2seel", "pm_emifac", "c_model_version",
  "c_expname", "pm_taxCO2eq"]

# TODO get this from config/gams globals
# TODO add iter
dir = "./pypsa_export3"
if not os.path.isdir(dir):
    os.mkdir(dir)

# single gams connect yaml nstruction
connect_inst = '''
    - GAMSReader:
        symbols:
          - name: {par}
    - CSVWriter:
        file: {dir}/{par}.csv
        name: {par}
        valueSubstitutions: {'EPS': 0}
    '''

# Loop
for par in PARAMS:
    instr = yaml.safe_load(connect_inst.replace("{par}",par).replace("{dir}",dir))
    try:
        # the gams connect export
        cdb.execute(instr)
    except Exception as e:
        gams.printLog(f"Error par {par} skipped: {e}")

endEmbeddedCode
