# REPPS
Robust Energy and Power Predictor Selection

Project continued from [ARMPB_BUILDMODEL](https://github.com/kranik/ARMPM_BUILDMODEL). This methodology has been extended for the purposes of the [Horizon2020 TeamPlay](https://www.teamplay-h2020.eu/) project.

## Publications

The REPPS methodology has been used to generate a number of power and energy models for relevant platforms in the TeamPlay project. The research findings are currently in the process of write-up and publication. Once accepted, relevant publications will be linked here.

## Getting Started

The scripts contained in this repo perform offline model generation and analysis. They work can work with any data in the required format, specified in the **Usage** section.

The whole model generation and validation process takes two general steps:
1. Data Collection and Synchronisation -Obtain the PMU event and power/energy sensor samples from the platform and process the data to fit the required format.
2. Model Generation and Validation - Analyse the data files and generate the required model using [`octave_makemodel.sh`](Scripts/octave_makemodel.sh).

The [`octave_makemodel.sh`](Scripts/octave_makemodel.sh) script does both the model generation and validation in a two-step process, but within the same code. All the scripts are written in bash, but use a lot of supporting linux commands to manipulate files and calculate model coefficients as well as using command line calls to [_Octave_](https://www.gnu.org/software/octave/) for more complex mathematical capabilities of the language.

This repo contains only the control scripts and does not include a version of octave. There is a Demo example in [Demo](Demo/Demo.md), where the methodology setup can be quickly tested by generating some example models from sample data.

### Prerequisites

The scripts use `GNU bash, version 5.0.17(1)-release` and the platform is built on `Ubuntu 20.04.1 LTS`, kernel version `5.8.0-59-generic`. However the methodology should be portable to other systems, since the scripts primarily use standard command line programs, such as `awk`, `sed`, `bc`, etc. and calls to `octave`. The project uses `GNU Octave, version 5.2.0 (2020-01-31)` and should work with higher versions as well. Please check with your distro package database for the appropriate octave version or download and compile from [here](https://ftp.gnu.org/gnu/octave/).

**DISCLAIMER - If you have any issues please don't hesitate to contact via [email](mailto:kris.nikov@bris.ac.uk).**

### Setup

Use `git clone git@github.com:TSL-UOB/TP-REPPS.git` to clone the repo. Make sure to do `chmod +x` on all the executable scripts so that they function correctly. Then install octave and make sure to update your `$PATH` to include the octave binary since the [`octave_makemodel.sh`](Scripts/octave_makemodel.sh) uses a call to `octave --silent --eval "load_build_model(...)"` to compute the models. 

## Usage

The model generation and validation script [`octave_makemodel.sh`](Scripts/octave_makemodel.sh) uses data in the following format:

```
#Timestamp	Benchmark	Run(#)	CPUFrequency(MHz)	Current[A]	Power[W]	Energy[J]	time	icmiss	ichold	dcmiss	dchold	wbhold	ainst	iinst	bpmiss	ahbutil	ahbtutil	branch	call	type2	ldst	load	store
1	aha-compress	1	80	0.854367678	2.819413336	0.00477101	135376	122	4232	27	23134	24027	172318	189724	2542	229722	245059	14617	547	103236	160069	114199	57276		
2	aha-compress	1	80	0.898460015	2.96491805	0.0319563	862251	0	0	0	79086	79515	525783	525144	5890	527382	528617	29287	1011	187494	274048	185690	87934		
3	aha-compress	1	80	0.905392772	2.987796149	0.0313746	840074	0	0	0	76837	77567	511731	512210	5575	513306	514469	27965	976	182795	265753	181540	85358		
4	aha-compress	1	80	0.902342359	2.977729785	0.0322434	866255	0	0	0	80050	79569	527780	527960	5927	531102	529787	29206	1016	187915	274965	186500	88511		
5	aha-compress	1	80	0.906502014	2.991456645	0.032441	867565	0	0	0	80097	79711	528365	528528	5931	530892	530309	29375	1016	188088	275747	186690	88577		
6	aha-compress	1	80	0.901787739	2.975899537	0.0300555	807970	0	0	0	74528	74298	492473	492350	5509	494448	494309	27322	946	175358	256748	174066	82467
...
```
The data file with the samples, must start with a header line, indicated by a `#` symbol and all the column names, followed by all the samples, one sample per line. All data columns must be separated by `\t`. `Timestamp`, `Benchmark` and `Freqeuncy` columns are mandatory and the physical measurement unit for the specific column can be put into square brackets for better output -> e.g. if modelling `Power[W]`, the script automatically picks up `[W]` as the measuring unit and will use that when outputting average and standard deviation values of predicted `Power`.

To assist in data formatting there is an additional assisting script - [`truncate_event_columns.sh`](Scripts/truncate_event_columns.sh), which helps remove specific columns from the data files in case you want to remove unusable or unwanted events from the analysis (or shrink filesize).

An important part of the methodology is the ability to specify the benchmarks used for training and testing the models, which need to be put in an input file passed to the script. Here is an example benchmark split:

```
#Train Set	Test Set
aha-compress	use_case_opt
aha-mont
ctl-stack
ctl-vector
ctl-string
dhrystone
fasta
dtoa
fir
edn
frac
...
```

The benchmark split file needs to have a specific header and two columns for the train and test set with the benchmark names distributed between the two categories. The `octave` back-end computation scripts, namely [`build_model.m`](Scripts/build_model.m) and [`load_build_model.m`](Scripts/load_build_model.m) use the train set and test set data passed to them by [`octave_makemodel.sh`](Scripts/octave_makemodel.sh) and use a user-specified algorithm to fit the model on the train set and validate the resulting model error using the test set. 

### Troubleshooting

All the scripts have a `-h` flag which lists the possible number of inputs/flags and explains what their functionality is. An example is given below:
```
$ ./octave_makemodel.sh -h
Available flags and options:
-r [FILEPATH] -> Specify the concatednated result file to be analyzed.
-t [FILEPATH] -> Specify the concatednated result file to be used to test model.
-f [FREQENCY LIST][MHz] -> Specify the frequencies to be analyzed, separated by commas.
-b [FILEPATH] -> Specify the benchmark split file for the analyzed results. Can also use an unused filename to generate new split.
-p [NUMBER] -> Specify regressand column.
-e [NUMBER LIST] -> Specify events list.
-d [NUMBER: 1:3]-> Select the compute algortihm to use: 1-> OLS using custom code; 2 -> OLS from octave lib; 3 -> OLS with non-negative weights from octave lib;
-q [FREQENCY LIST][MHz] -> Specify the frequencies to be used in cross-model for the second core (specified with -t flag).
-m [NUMBER: 1:4]-> Type of automatic machine learning search method: 1 -> Bottom-up; 2 -> Top-down; 3 -> Bound exhaustive search; 4 -> Complete exhausetive search;
-c [NUMBER: 1:4]-> Select minimization criteria for model optimisation: 1 -> Mean Absolute Percentage Error; 2 -> Relative Standart Deviation; 3 -> Maximum event cross-correlation; 4 -> Average event cross-correlation;
-l [NUMBER LIST] -> Specify events pool.
-n [NUMBER] -> Specify max number of events to include in automatic model generation.
-i [NUMBER] -> Specify number of randomised training benchmark set folds to use when doing k-folds cross-validation during event search.
-g -> Enable check for constant events and remove from search. LR will not work with data that contains constant events.
-o [NUMBER: 1:6]-> Output mode: 1 -> Measured platform physical data; 2 -> Model detailed performance and coefficients; 3 -> Model shortened performance; 4 -> Platform selected event totals; 5 -> Platform selected event averages; 6-> Output model per sample data (for comprehensive plots).
-s [FILEPATH] -> Specify the save file for the analyzed results. If no save file - output to terminal.
Mandatory options are: -r [FILE] -b [FILE] -p [NUM] -e [LIST] -d [NUM]/(-m [NUM] -c [NUM] -n [NUM] -l [NUM]) -o [NUM]
You can either explicitly specify the events list to be used for the model with -e [LIST] or use the automatic selection flags -m [NUM] -c [NUM] -n [NUM] -l [NUM]) -o [NUM].
```

The code is also heavily commented, so please use that as a further reference to the functional capabilities and options.

## Demo

The project repository also contains a small demo to test proper methodology setup and showcase the functionality. The demo files and instructions are available in the [Demo](Demo/) folder.

## Contributing

Anyone is welcome to contribute to the project as long as they respect the license. Please use the [ShellCheck](https://www.shellcheck.net/) bash code linter to verify your code and comment thoroughly. 

## Author

All of the code and instructions presented here are developed by [Dr Kris Nikov](mailto:kris.nikov@bris.ac.uk) as a fork of the [ARMPB_BUILDMODEL](https://github.com/kranik/ARMPM_BUILDMODEL) project.

## Licence

This project is licensed under the BSD-3 License - please see [LICENSE.md](LICENSE.md) for more details.

## Acknowledgements

This work was supported by the European Union's Horizon 2020 Research and Innovation Programme under grant agreement No. 779882, TeamPlay (Time, Energy and security Analysis for Multi/Many-core heterogeneous PLAtforms).
