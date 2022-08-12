# RQ1 and RQ2

This branch contains the replicability package for the results presented in RQ1 and RQ2 of the [ATheNA paper](https://arxiv.org/abs/2207.11016) (respectively Sections 5.1 and 5.2).

For instructions on how to install ATheNA and how run it, please refer to the main branch. For the results of RQ3 (Section 5.3 of the paper), please refer to the branch RQ3.

The content of this branch is divided in three folders:

* Models  
* Results  
* Scripts

## Models

This folder contains the Simulink model and the Setting file necessary to run the 7 models under analysis in RQ1 and RQ2.  
These are:

* **AFC**: A controller for the air-fuel ratio in an engine.
* **AT**: A model of a car automatic transmission with gears from 1 to 4.
* **CC**: A simulation of a system formed by five cars.
* **F16**: Simulation of an F16 ground collision avoidance controller.
* **NN**: A Neural Network controller for a levitating magnet above an electromagnet.
* **SC**: Dynamic model of steam condenser, controlled by a Recurrent Neural Network.
* **WT**: A model of a wind turbine that takes as input the wind speed.

## Results
This folder contains the .mat file containing the actual results presented in the paper.

The name of each file has the the following structure:

	Athena_[requirement ID]_[range ID].mat
	
For the requirement ID, please refer to Table 2 of the paper.  
For the range ID, `R1` was used for the original range, while `R2` for the modified range reported in Table 3 of the paper.

The results for each run of the algorithm are contained in the variable called `Results` which is a 150x1 cell array.  
The first 50 elements of this array represent the runs using S-Taliro, the following 50 elements the runs using ATheNA-Manual and the final 50 elements the runs using ATheNA.

The results are also presented in an aggregated form in the variables `fals` and `n_iter`, that contain respectively if a run had falsified the requirement or not and how many iterations it has performed. Both variables are 50x3 matrices where the rows represents the 50 runs and the columns represents the tool used (1 for S-Taliro, 2 for ATheNA-Manuale and 3 for ATheNA).

## Scripts

This folder contains four scripts that can read the Results file and analyze them by creating plots and printing in the command window the success rate and number of iterations for each requirement and input range.

* `Analyze_results.m`: this script reads all the data contained in the `Results` folder and the compute the relevant parameters in an aggregated form.
* `Compare_results.m`: this script reads all the data contained in the `Results` folder and compute the relevant parameters for each requirement-assumption combination.
* `Join_results.m`: this script is used to combine the 3 `.mat` files obtained by running S-Taliro, ATheNA-M and ATheNA on the same requirement into a single file.
* `Print_boxplot.m`: this script reads all the data contained in the `Results` folder and save a single boxplot of the number of iterations for all the requirement-assumption combinations.
