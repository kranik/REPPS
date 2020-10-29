# REPPS
Robust Energy and Power Predictor Selection

Project continued from https://github.com/kranik/ARMPM_BUILDMODEL
Readme to be updated.

## Benchmarks used during model training and validation

| Benchmark           | Time [s] | Benchmark                  | Time [s] |
|---------------------|---------:|----------------------------|---------:|
| aha-compress        |     3.19 | prime                      |     2.11 |
| aha-mont64          |     2.64 | qurt                       |     2.74 |
| ctl-stack           |     2.11 | sglib-heap-arraybinsearch  |     2.06 |
| ctl-string          |     1.97 | sglib-heap-arrayheapsort   |     4.29 |
| ctl-vector          |     1.56 | sglib-heap-arrayquicksort  |     4.29 |
| dhrystone           |    19.29 | sglib-heap-arraysort       |     4.29 |
| dtoa                |     1.60 | sglib-heap-dllist          |     4.54 |
| edn                 |    14.45 | sglib-heap-hashtable       |     3.09 |
| fasta               |     8.81 | sglib-heap-listinsertsort  |     5.39 |
| fir                 |    49.15 | sglib-heap-listsort        |     3.63 |
| frac                |    21.02 | sglib-heap-queue           |     4.65 |
| huffbench           |    56.67 | sglib-heap-rbtree          |    11.87 |
| levenshtein         |     9.88 | sglib-quick-arraybinsearch |     2.06 |
| ludcmp              |     3.79 | sglib-quick-arrayheapsort  |     2.08 |
| matmult-float       |     0.99 | sglib-quick-arrayquicksort |     2.08 |
| miniz               |   138.80 | sglib-quick-arraysort      |     2.08 |
| minver              |     1.62 | sglib-quick-dllist         |     4.54 |
| nbody               |     1.59 | sglib-quick-hashtable      |     3.09 |
| ndes                |     7.95 | sglib-quick-listinsertsort |     5.39 |
| nettle-aes          |     7.27 | sglib-quick-listsort       |     3.63 |
| nettle-arcfour      |     4.10 | sglib-quick-queue          |     4.65 |
| nettle-sha256       |     0.95 | sglib-quick-rbtree         |    11.87 |
| newlib-exp          |     1.51 | slre                       |     5.54 |
| newlib-log          |     1.13 | stanford                   |     1.90 |
| picojpeg            |   179.69 | whetstone                  |   115.75 |
| use\_case\_opt      |    15.36 | use\_case\_noopt           |    22.67 |
| use\_case\_wcc\_opt |    19.50 | use\_case\_wcc\_noopt      |    23.55 |
