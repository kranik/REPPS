#Generating the models from the LEON3 sample data

##Generate models trained on BEEBS and validated on the use_case_core application

###ASIC Only Model
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -t /PATH/TO/ESL_paper_data/data/LEON3_use_case_finegrain.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_use_case_split.data -p 6 -e 4 -d 2 -o 2 -s 20210421_leon3_beebs_ucc_pwr_fngr_nocyc_nocth_asicdata_avgrelerr_nfolds_ools.data

###Bottom-Up Search
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -t /PATH/TO/ESL_paper_data/data/LEON3_use_case_finegrain.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_use_case_split.data -p 6 -l 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24 -m 1 -n 16 -c 1 -g -i 50 -d 2 -o 2 -s 20210425_leon3_beebs_ucc_pwr_fngr_allev_nocyc_nocth_botup_avgrelerr_nfolds_ools.data

###Top-Down Search
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -t /PATH/TO/ESL_paper_data/data/LEON3_use_case_finegrain.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_use_case_split.data -p 6 -l 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24 -m 2 -n 1 -c 1 -g -i 50 -d 2 -o 2 -s 20210425_leon3_beebs_ucc_pwr_fngr_allev_nocyc_nocth_topdown_avgrelerr_nfolds_ools

##Validate the previous models on BEEBS as well (no need to redo all the event selection, just use same events)

###ASIC Only Model
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_BEEBS_split.data -p 6 -e 4 -d 2 -o 2 -s 20210421_leon3_beebs_beebs_pwr_fngr_nocyc_nocth_asicdata_avgrelerr_nfolds_ools.data

###Bottom-Up Search
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_BEEBS_split.data -p 6 -e 24 -d 2 -o 2 -s 20210421_leon3_beebs_beebs_pwr_fngr_allev_nocyc_nocth_botup_avgrelerr_nfolds_ools.data

###Top-Down Search
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_BEEBS_split.data -p 6 -e 9,10,12,13,14,15,16,18,19,20,22,23 -d 2 -o 2 -s 20210421_leon3_beebs_beebs_pwr_fngr_allev_nocyc_nocth_topdown_avgrelerr_nfolds_ools.data

#Visualise the data

##Generate model per-sample breakdown files for the 1st run of the use_case_opt application

###ASIC Only Model
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -t /PATH/TO/ESL_paper_data/data/LEON3_use_case_finegrain_1run.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_onlyusecaseopt_split.data -p 6 -e 4 -d 2 -o 6 -s /PATH/TO/ESL_paper_data/20210421_leon3_beebs_uco_pwr_fngr_nocyc_nocth_asicdata_avgrelerr_nfolds_ools_1r.data

###Bottom-Up Search
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -t /PATH/TO/ESL_paper_data/data/LEON3_use_case_finegrain_1run.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_onlyusecaseopt_split.data -p 6 -e 24 -d 2 -o 6 -s /PATH/TO/ESL_paper_data/20210427_leon3_beebs_uco_pwr_fngr_allev_nocyc_nocth_botup_avgrelerr_nfolds_ools_1r.data

###Top-Down Search
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -t /PATH/TO/ESL_paper_data/data/LEON3_use_case_finegrain_1run.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_onlyusecaseopt_split.data -p 6 -e 9,10,12,13,14,15,16,18,19,20,22,23 -d 2 -o 6 -s /PATH/TO/ESL_paper_data/20210427_leon3_beebs_uco_pwr_fngr_allev_nocyc_nocth_topdown_avgrelerr_nfolds_ools_1r.data

##Generate model per-sample breakdown files for the 1st run of the BEEBS benchmarks

###ASIC Only Model
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -t /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain_1run.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_BEEBS_split.data -p 6 -e 4 -d 2 -o 6 -s /PATH/TO/ESL_paper_data/20210423_leon3_beebs_beebs_pwr_fngr_nocyc_nocth_asicdata_avgrelerr_nfolds_ools_1r.data

###Bottom-Up Search
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -t /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain_1run.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_BEEBS_split.data -p 6 -e 24 -d 2 -o 6 -s /PATH/TO/ESL_paper_data/20210427_leon3_beebs_beebs_pwr_fngr_allev_nocyc_nocth_botup_avgrelerr_nfolds_ools_1r.data

###Top-Down Search
./octave_makemodel.sh -r /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain.data -t /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain_1run.data -b /PATH/TO/ESL_paper_data/split/LEON3_BEEBS_BEEBS_split.data -p 6 -e 9,10,12,13,14,15,16,18,19,20,22,23 -d 2 -o 6 -s /PATH/TO/ESL_paper_data/20210427_leon3_beebs_beebs_pwr_fngr_allev_nocyc_nocth_topdown_avgrelerr_nfolds_ools_1r.data

##Plot the model per-sample breakdwon data using `MODELDATA_plot.py`

###Plot the use_case_opt 1st run per-sample physical measurements and model errors
./MODELDATA_plot.py -p 1 -x "Samples[#]" -t 10 -y "Power[W]" -b /PATH/TO/ESL_paper_data/data/LEON3_use_case_opt_finegrain_1run.data -l "Sensor Data" -i /PATH/TO/ESL_paper_data/20210421_leon3_beebs_uco_pwr_fngr_nocyc_nocth_asicdata_avgrelerr_nfolds_ools_1r.data -a 'ASIC Data Only' -i /PATH/TO/ESL_paper_data/20210427_leon3_beebs_uco_pwr_fngr_allev_nocyc_nocth_botup_avgrelerr_nfolds_ools_1r.data -a "Bottom-Up Search" -i /PATH/TO/ESL_paper_data/20210427_leon3_beebs_uco_pwr_fngr_allev_nocyc_nocth_topdown_avgrelerr_nfolds_ools_1r.data -a "Top-Down Search"

###Plot the BEEBS 1st run per-sample physical measurements and model errors
./MODELDATA_plot.py -p 1 -x "Samples[#]" -t 10 -y "Power[W]" -b /PATH/TO/ESL_paper_data/data/LEON3_BEEBS_finegrain_1run_physicaldata.data -l "Sensor Data" -i /PATH/TO/ESL_paper_data/20210423_leon3_beebs_beebs_pwr_fngr_nocyc_nocth_asicdata_avgrelerr_nfolds_ools_1r.data -a 'ASIC Data Only' -i /PATH/TO/ESL_paper_data/20210427_leon3_beebs_beebs_pwr_fngr_allev_nocyc_nocth_botup_avgrelerr_nfolds_ools_1r.data -a "Bottom-Up Search" -i /PATH/TO/ESL_paper_data/20210427_leon3_beebs_beebs_pwr_fngr_allev_nocyc_nocth_topdown_avgrelerr_nfolds_ools_1r.data -a "Top-Down Search"