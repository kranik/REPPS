# REPPS Demo

The aim of this Demo is to provide a means to troubleshoot the methodology functionality as well as demonstrate some of the key features. The goal of this demo is to generate some example models from data available in the [Data](Data/) folder using the specified commands in this tutorial. The output files can be checked against the files in the [Check](Check/) folder. **Some of the output models might not be the same, since some of the input parameters cause a random split of the n-folds cross-validation sets. If that happens - don't panic, but carefully check that the output file is in the correct format and the model events make sense.**

All the commands listed in this document are meant to be run from the [Scripts](../Scripts/) directory where the [`octave_makemodel.sh`](../Scripts/octave_makemodel.sh) and [`MODELDATA_plot.py`](../Scripts/MODELDATA_plot.py) scripts are.

First test the model generation script but running the following command:
```
./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -l 9,14,24 -d 2 -i 2 -m 1 -c 1 -n 3 -o 2
```

The `-r` flag specified the data file with the model samples used for generation; the `-t` flag specifies the file used for the test/validation data samples; the `-b` flag specifies the file with the benchmark split for training and testing/validation; the `-p` flag specifies the column number used for the regressand (predicted) value -> in this example column __6 - Power(W)__; the `-l` specifies the list of columns of PMU events used to build the model with -> in this example columns __9,14 and 24 - icmiss,ainst and store__; the `-d` flag specifies the specific model fitting function used by the `octave` back-end -> in this example __2 - OLS from octave library__; the `-i` flag specifies the number of folds to use in cross-validation when building the model using the training set samples -> in this example __2 Folds__; the `-m` flag specifies the specific automatic search algorithm -> in this example __Bottom-Up Search__; the `-c` flag specifies the optimisation criteria -> in this case the model __Mean Absolute Percentage Error__; the `-n` flag specifies the limit of events to include in the model -> in this example __3 Events__;and finally the `-o` flag specifies the output type -> in this example __2 -> Model detailed performance and coefficients__. However, since we don't have an output file the output format will be the default CLI one.

The script should output to the terminal something similar to:
```
...
********************
All events checked!
********************
--------------------
********************
Add best event to final list and remove from pool:
9 -> icmiss
********************
New events list:
24,14,9 -> store,ainst,icmiss
New mean model mean absolute percent error -> 1.4617550000
New mean model relative stdandart deviation -> 86508.2534350000
New mean model average event cross-correlation -> 48.8842500000
New mean model max event cross-correlation -> 78.4501700000
New model max event cross-correlation 78.45017 is at 80 MHz between ainst,icmiss
********************
Reached specified number of model events.
********************
--------------------
Mean model mean absolute percentage error -> 2.95919
Mean model maximum relative error -> 18.43591
Mean model minimum relative error -> 0.00078
Relative Standart Deviation -> 133.92518
Mean model average event cross-correlation -> 47.08075
Mean model max event cross-correlation -> 66.49936
Model max event cross-correlation 66.49936 is at 80 MHz between store,ainst
--------------------
====================
Script Done!
====================
```

Do not worry if the events used in the final list are different. As explained in the beginning the `-i` flag specifies the number of folds but the benchmarks for each fold are randomly selected in order to achieve greater statistical robustness of the event selection process so the final event list might differ slightly depending of the specific split that was generated by the script. If you use `-i 50` which is the maximum number of folds (1 for each benchmark in the training sample set) the output would be the same, but it would take much longer to compute.

Once this initial commands runs successfully we can actually start making some example models using different input parameters and plot the output.

## Generating the 2-Folds Bottom-Up Search Model
This is the same model as the first example, but we are using the `-s` flag to specify the save location of the final data in the [Demo](../Demo/) folder. 
```
./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -l 9,14,24 -d 2 -o 2 -i 2 -m 1 -c 1 -n 3 -s ../Demo/leon3_botup_2folds.data
```

The `leon3_botup_2folds.data` file should look like this:
```
====================
Using events list:
14 -> ainst
====================
CPU Frequency	Average Predicted Power[W]	Predicted Power Range[%]	Mean Error[W]	Standard Deviation of Error[W]	Mean Absolute Percentage Error[%]	Relative Standart Deviation[%]	Maximum Relative Error[%]	Minimum Relative Error[%]	Model coefficients
80	2.57957	32.823	0.03767	0.09736	2.19653	258.46785	18.38240	0.00007	3.42472	-1.12696E-06
```

We can also generate a model per-sample breakdown file that we can plot using the [`MODELDATA_plot.py`](../Scripts/MODELDATA_plot.py) script. In that case we need to use `-o 6` flag to specify the 6th output option -> __Model per-sample performance (for comprehensive plots)__. We can use the `-e` flag to specify the events list to use directly without the need to do the automatic event search. The following commands is used to generate the per-sample model performance breakdown:
```
./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents_1run.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -e 24,14 -d 2 -o 6 -s ../Demo/leon3_botup_2folds_breakdown.data
```

The `leon3_botup_2folds_breakdown.data` file should look like this:
```
#Sample[#]	Predicted Power[W]	Error[W]	Absolute Percentage Error[%]
1	2.98412	-0.16837	5.97946
2	2.91186	0.22968	7.31109
3	2.89142	0.24005	7.66576
4	2.75330	0.39007	12.40933
5	2.68832	-0.06566	2.50366
...
```

After generating the first type of model we can generate another two types differing by the event list used, the automatic search algorithm and the number of folds used in event selection by changing the inputs to the `-l`, `-m`, `-n` and `-i` flags. 

## Generating the 2-Folds Top-Down Search Model
```
./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -l 9,11,19 -d 2 -o 2 -i 2 -m 2 -c 1 -n 1 -s ../Demo/leon3_topdown_2folds.data && ./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents_1run.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -e 11,19 -d 2 -o 6 -s ../Demo/leon3_topdown_2folds_breakdown.data
```

## Generating the 5-Folds Bottom-Up Search Model
```
./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -l 19,23,24 -d 2 -o 2 -i 5 -m 1 -c 1 -n 3 -s ../Demo/leon3_botup_5folds.data && ./octave_makemodel.sh -r ../Demo/Data/LEON3_BEEBS_trimmed_20200610_fixed_energy_allevents.data -t ../Demo/Data/LEON3_use_case_core_trimmed_20200610_fixed_energy_allevents_1run.data -b ../Demo/Data/LEON3_nobubblesort_onlyusecaseopt_20200610_split.data -p 6 -e 24,19 -d 2 -o 6 -s../Demo/leon3_botup_5folds_breakdown.data
```

## Plotting the per-sample model performance data for all three models
Finally we can plot all the resulting per-sample data using the following command:
```
./MODELDATA_plot.py -p 1 -x 'Samples[#]' -t 10 -y 'Power[W]' -b ../Demo/Data/LEON3_use_case_opt_trimmed_20200610_superfixed_energy_time_1run.data -l 'Sensor Measurements'  -i ../Demo/leon3_botup_2folds_breakdown.data -a 'Bottom-Up 2folds' -i ../Demo/leon3_topdown_2folds_breakdown.data -a 'Top-Down 2folds' -i ../Demo/leon3_botup_5folds_breakdown.data -a 'Bottom-Up 5folds' -o ../Demo/leon3_models_breakdown.pdf
```

The `-p` flag specifies the plot type -> currently only one type, but the script will be extended in the future to have other useful plot types; the `-x` flag specifies the label of the X axis -> in this example __Samples[#]__; the `-t` flag specifies the number of __ticks__ to use in the X axis -> in this example __10 ticks__; the `-y` flag specifies the Y axis label -> in this example __Power[W]__; the `-b` flag is used to specify the file containing the physical measurements breakdown data (actual data from sensors) to plot; the `-l` flag is used to specify the name for the physical measurements plot line -> in this example __Sensor Measurements__; the `-i` flag is used to specify the file containing the model per-sample performance breakdown data to plot; the `-a` flag is used to specify the name for the model we are plotting, referring to the previous model data selected with an `-i` flag; and the `-o` flag is used to specify the output .pdf file for the plot. There can be only one physical measurements file specified with the `-b` flag and it must be followed by a `-l` flag specifying the name. There can be as many `-i` flag specifying model data as needed but each must be followed by an `-a` flag specifying the model name.

The final `leon3_models_breakdown.pdf` plot can be checked against [leon3_models_breakdown.pdf](Check/leon3_models_breakdown.pdf)
