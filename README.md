## Instructions for the reviewers of Transaction Of Software Engineering and Methodologies (TOSEM)

### Running ATheNA

To install ATheNA, please follow the instructions in the *main* branch on how to download S-Taliro, setting up the compiler and installing ATheNA.  


The Matlab script `runAthena.m` can then be used to execute ATheNA on any of the available models.  

### Models
All the models discussed in the Evaluation Section of the paper are publicly available and have been attached to the present replicability package in the folder `Models`.

Each model is identified by the identifier *MID* in Table 1, with the addition of *HEV* and *MV* that represent respectively the *Hybrid-Electric Vehicle* and *Mechanical Ventilator* discussed in RQ5.

### Results
The folder `Results` contains the .mat files obtained from each experiment and divided in:

* `Results/RQ1`
* `Results/RQ2-RQ3-RQ4`
* `Results/RQ5`

Included in this package, there are all the scripts used to analyze these .mat files and produce the tables and figures in the paper.
It is not necessary to install ATheNA to run these scripts.

### RQ1 - Experiment with volunteers
The folder `RQ1-ModelDescription` contains the following:

* The textual descriptions of each requirement that was provided to Subject 1 and Subject 2.
* The original manual fitness functions, written as pseudo-code by the volunteers.
* Matlab functions that implement in correct code the pseudo-code proposed by the volunteers.