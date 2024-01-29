# ATheNA

ATheNA is a Search-Based Software Testing framework that combines an automatically-generated and a manually-defined
fitness functions to search for failure-revealing test cases. On one hand, the automatic fitness function is generated
using S-TaLiRo directly from the requirement under analysis. On the other hand, the manual fitness function must be
written by the user employing their domain knowledge and expertise on the model.

The replication package for the paper submitted to Transactions On Software Engineering and Methodologies (TOSEM) is in the branch *TOSEM*.  
Please, download Athena from the *main* branch and follow the installation instructions below to replicate the proposed results.  



The replication and results files used in the [ATheNA paper](https://dl.acm.org/doi/abs/10.1145/3624745) on ACM Transaction on Software Engineering and Methodology are available:

* In the branch *RQ1-RQ2*, for the results of Research Question 1 and 2 of the paper (Section 5.1 and 5.2 respectively)
* In the branch *RQ3*, for the results of Research Question 3 of the paper (Section 5.3)

**Note**: RQ3 requires a separate version of ATheNA due to some properties of the model. Please use the scripts contained in that branch.

## Installation

To install the toolbox, clone this repository to the intended system and add all folders to the MATLAB path. Then,
follow all the requirements and instructions listed in [_System Requirements_](#system-requirements) and [_Setting Up
S-TaLiRo for ATheNA Usage_](#setting-up-s-taliro-for-athena-usage).

A step-by-step installation guide is also available on [YouTube](https://www.youtube.com/watch?v=F8hhTQ8nLts)

## System Requirements

### S-TaLiRo Toolbox

ATheNA requires a copy of the S-TaLiRo toolbox, with the *staliro* folder location added to the MATLAB path. The
S-TaliRo toolbox can be downloaded from the following link:
[https://app.assembla.com/spaces/s-taliro_public/subversion/source/HEAD/trunk](https://app.assembla.com/spaces/s-taliro_public/subversion/source/HEAD/trunk).

Note that a MEX compiler is required to use S-TaLiRo, and that MEX files should be compiled before using ATheNA. For
more information on supported compilers, refer to the MATLAB documentation on supported compilers in the following link:
[https://www.mathworks.com/support/requirements/supported-compilers.html](https://www.mathworks.com/support/requirements/supported-compilers.html). To change the default compiler, refer to the MATLAB documentation in the following link:
[https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html](https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html).

### Additional MathWorks Toolboxes and Products

* MATLAB Signal Processing Toolbox
* Simulink (for the example tutorial)

### Setting Up S-TaLiRo for ATheNA Usage

ATheNA modifies some contents of the S-TaLiRo toolbox for it to run. Before a _staliro_ folder can be used for
the first time, it must be configured correctly. To configure the folder correctly, follow the steps below:

1. Download S-Taliro from its [repository](https://app.assembla.com/spaces/s-taliro_public/subversion/source/HEAD/trunk).

2. Unzip the folder, rename it to `staliro` (Optional), and move it inside the ATheNA repo.

3. Ensure that the correct MEX compiler for your operating system is connected to MATLAB by referring to the online MATLAB [documentation](https://www.mathworks.com/support/requirements/supported-compilers.html).

4. Ensure that the ATheNA toolbox folder and its subfolders are added to the MATLAB path.

5. Run the `configureAthena` function by providing the relative path from the current working directory to the S-Taliro folder.
   For example, if the current working directory is the ATheNA repository cloned from GitHub and the folder containing S-Taliro has been renamed to `staliro`, then the command is the following:

```matlab
configureAthena('staliro')
```

## Features

The ATheNA toolbox includes the following functions and features:

* The `athena` function: runs a test on a given model with the indicated initial conditions, assumptions on the input
  profile (input range, number of control points and interpolation function), and requirement under analysis. The
  structure of the function call is shown in the comment below and is the same as the `staliro` function, with the
  exception of the options object, which is of `athena_options` type. For more information on the function and its
  inputs, refer to the MATLAB `help` function documentation by entering the following to the MATLAB Command Window:
    ```matlab
    % Usage structure:
    % [Results, History, Opt] = athena(model,init_cond,input_range,cp_array,phi,preds,TotSimTime,athena_opt);
    help athena
    ```

* The `athena_options` object: inherits the properties of `staliro_options` and incorporates additional properties
  required for ATheNA to work. Note that the `optimization_solver` and `runs` properties, which are inherited
  from `staliro_options`, <u>must be kept as the default values</u>. To conduct multiple runs, modify
  the `athena_options.athena_runs` property. For more information, refer to and navigate the MATLAB `help` function
  documentation by entering the following to the MATLAB Command Window:
    ```matlab
    % Usage structure:
    % opt = athena_options;
    help athena_options
    ```

* __Manual fitness functions__: functions that are defined by the user functions that are defined by the user that
  incorporate user-defined metrics to calculate a manual fitness value. For more information on how to create and use
  manual fitness functions, refer to the [_Manual Fitness Functions_](#manual-fitness-functions) section, or use
  the `help` function documentation by entering the following to the MATLAB Command Window:
    ```matlab
    help createManualFitness
    ```

## Manual Fitness Functions

### Creating Manual Fitness Functions

A manual fitness function is required for ATheNA to work properly. The function must be added to the MATLAB path. The
function **MUST** take 3 arguments as these are passed to the function internally by ATheNA:

* `t`: column vector with the timestamps for the model input and output spanning the specified simulation time.
* `u`: the input generated for the current iteration. If the `athena_options.useInterpInput` property is set to `true`,
  then this is a matrix where the $i$-th column corresponds to the interpolated values for the $i$-th input port and the
  rows correspond to the timestamps in `t`. Otherwise, a column vector of the control point values is provided with the
  control points for each input port being placed consecutively. For example, if the first input port has 7 control
  points, and the second input port has 3 control points, then `u(1:7,1)` would contain the control points for the first
  port in order, and `u(8:10,1)` would contain the control points for the second input port in order.
* `y`: matrix containing the output generated by the model, where the $i$-th column corresponds to the $i$-th output
  port, and the rows correspond to timestamps in `t`.

**Note**: <u>users can also invoke and use global variables inside of fitness functions</u>.

The function declaration should resemble the following structure:

```matlab
function fitness = myFitnessFunction(t,u,y)
% The manual fitness function calculation proceeds,
% and can differ from the following line
fitness = 1;
end
```

The function should output a fitness value in the range $[-1,1]$, where -1 is the most desirable fitness. For more
information on creating manual fitness functions refer to the MATLAB `help` function documentation by
calling `help createManualFitness`.

In order for ATheNA to correctly identify the function, it must be a valid MATLAB function added to the MATLAB path, and
the `athena_options.fitnessFcn` property must be set to the name of function as a string or character vector if the
fitness function is a main function, or as a function handle if it is a local or nested function. For example, if the
function is called myFitnessFunction, set the property as follows:

```matlab
% Ensure that 'athena_opt' has been initialized as an athena_options object.
% Any valid variable name can be used for the athena_options instance.

% If the function is a main function
athena_opt.fitnessFcn = 'myFitnessFunction';

% If the function is a local or nested function
athena_opt.fitnessFcn = @myFitnessFunction;
```

Even if an ATheNA test is set to use automatic fitness only, a fitness function must be defined. In such a case, the
default value of `athena_options.fitnessFcn` can be used. Documentation regarding the `athena_options.fitnessFcn`
property and its default value can be accessed through the following `help` function call:

```matlab
help athena_options.fitnessFcn
```

See the [_Examples_](#examples) section below for instructions on how to access an applied example of a fitness
function.

### Combining Manual and Automatic Fitness Values

The Manual and Automatic Fitness values are combined linearly by default using the `athena\_options.coeffRob` property.
This weight must be a value in the range $[0, 1]$, where 0
signifies using the manual fitness only, and 1 signifies using the automatic fitness only. Any value
of `athena_options.coeffRob` inside the range corresponds to a value $p$ used to calculate the combined fitness
$f_{athena}$ with the weighted average formula below:

$$f_{athena} = f_{automatic} \cdot p + f_{manual} \cdot (1 - p)$$

The user can define their own implementation of the `athenaFitness` method, by modifying the function `./src/UpdateStaliro/Compute \_Robustness.m` at line 147.

The atomic predicates used during the test should also be normalized with their normalization bounds defined. The bound
of an atomic predicate is the highest magnitude robustness value that is possible for that predicate, or a reasonable
approximation of that value. Formally, if the robustness interval for some predicate is found to be within $[a, b]$,
then the bound would be $\max(|a|,|b|)$. If the robustness interval is unknown, then the magnitude of the
difference of the input range can be used. Formally, if the input range is $[c, d]$, then the bound would be 
$|d - c|$.

**Note**: The atomic predicates are stored in the `preds` struct that is passed into the `athena` function. Refer to the
`help` documentation regarding the `athena` function using `help athena` for more information on this structure.

To normalize the atomic predicate at index $i$ of a predicates struct `preds`:

```matlab
preds(i).Normalized = true;
```

To set the normalization bounds of the atomic predicate at index $i$ of a predicates struct `preds` to some value $k$:

```matlab
preds(i).NormBounds = k;
```

To access the `help` function documentation pertaining to the `athena_options.coeffRob` property, run the following or
enter it to the MATLAB Command Window:

```matlab
help athena_options.coeffRob
```

## Examples

Two examples are provided with the tool to show how to set up and run ATheNA.\\

The first example can be found inside the [AutomotiveExample](AutomotiveExample) folder.
The folder includes the Simulink model which is used in the example (version 8.7/ R2016a) and a MATLAB script with the tutorial.
If an older MATLAB version is used, the example script and model will not run, but the rest of the toolbox should remain compatible.  
A complete walkthrough of this example is available on [YouTube](https://www.youtube.com/watch?v=dhw9rwO7L4k).

Another tutorial example can be found inside the [PendulumExample](PendulumExample) folder.
The folder includes the Simulink model which is used in the example (version 8.5/ R2015a), a formatted html tutorial page with a sample of what the output should look like, and a MATLAB script with the tutorial.

## How to Cite ATheNA

To cite ATheNA, please visit [https://dl.acm.org/doi/abs/10.1145/3624745](https://dl.acm.org/doi/abs/10.1145/3624745). Alternatively, the 
following BibTeX information can be used:

```
@article{ATheNA,
author = {Formica, Federico and Fan, Tony and Menghi, Claudio},
title = {Search-Based Software Testing Driven by Automatically Generated and Manually Defined Fitness Functions},
year = {2023},
issue_date = {February 2024},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
volume = {33},
number = {2},
issn = {1049-331X},
url = {https://doi.org/10.1145/3624745},
doi = {10.1145/3624745},
journal = {ACM Trans. Softw. Eng. Methodol.},
month = {dec},
articleno = {40},
numpages = {37},
}

```

## Contributors

The following authors contributed to writing this toolbox:

* Federico Formica, McMaster University (Email:`formicaf at mcmaster dot ca`)
* Mohammad Mahdi Mahboob, McMaster University (Email:`mahbom2 at mcmaster dot ca`)
* Claudio Menghi, University of Bergamo, McMaster University (Email:`menghic at mcmaster dot ca`)
