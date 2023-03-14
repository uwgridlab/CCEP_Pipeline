# CCEP_Pipeline
 GRIDlab CCEP processing and quantification pipeline

After initial clone of repository, follow setup steps:

1. Add CCEP_Pipeline folder to your MATLAB path and save the path.
2. Run CCEP\_setup (either select the file and press run or type CCEP\_setup on the command line.
3. When prompted, select or create a base directory for data storage. This does not need to be within the CCEP_Pipeline directory, and should be somewhere with plenty of storage space (e.g., a data drive).
4. Wait for completion message to appear in workspace.

Once setup is complete, the app may be run. To begin, type CCEP into the Matlab workspace and press enter, which will launch the main CCEP app and change your working directory to the data directory.

Select a subject or create a new subject. If needed, select montage and raw files for the subject. If raw files have already been converted to \_dat format<sup>*</sup>, upload _dat files to folder. Otherwise, press '\_dat convert' to convert all unconverted files for this subject. A summary of electrodes and stimulation parameters for each file will be displayed when all needed inputs are present. To process and quantify a file (or view prior processing/quantification), select the file in the 'Edit File' field and press 'Go'.

<sup>*</sup> Raw files will contain a single data structure, called 'data'. The \_dat files will contain extracted information: amplitude, anode, cathode, data, fs, onsets\_samps, and pulse\_width.