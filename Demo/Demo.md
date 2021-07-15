#2 folds botup

```
./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -l 9,14,24 -d 2 -o 2 -i 2 -m 1 -c 1 -n 3
```

```
./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -l 9,14,24 -d 2 -o 2 -i 2 -m 1 -c 1 -n 3 -s ../Demo/Models/leon3_botup_2folds.data && ./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents_1run.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -e 24,14 -d 2 -o 6 -s ../Demo/Models/leon3_botup_2folds_breakdown.data
```
#2 folds topdown
```
./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -l 9,11,19 -d 2 -o 2 -i 2 -m 2 -c 1 -n 1 -s ../Demo/Models/leon3_topdown_2folds.data && ./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents_1run.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -e 11,19 -d 2 -o 6 -s ../Demo/Models/leon3_topdown_2folds_breakdown.data
```

#5 Folds
```
./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -l 19,23,24 -d 2 -o 2 -i 5 -m 1 -c 1 -n 3 -s ../Demo/Models/leon3_botup_5folds.data && ./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents_1run.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -e 24,19 -d 2 -o 6 -s../Demo/Models/leon3_botup_5folds_breakdown.data
```

#Plot the breakdown data
```
./MODELDATA_plot.py -p 1 -x 'Samples[#]' -t 10 -y 'Power[W]' -b ../Demo/Data/LEON3_use_case_opt_trimmed_20200610_superfixed_energy_time_1run.data -l 'Sensor Measurements'  -i ../Demo/Models/leon3_botup_2folds_breakdown.data -a 'Bottom-Up 2folds' -i ../Demo/Models/leon3_topdown_2folds_breakdown.data -a 'Top-Down 2folds' -i ../Demo/Models/leon3_botup_5folds_breakdown.data -a 'Bottom-Up 5folds' -o ../Demo/Plot/leon3_models_breakdown.pdf
```
