# CCEP_Pipeline
 GRIDlab CCEP processing and quantification pipeline

After initial clone of repository, follow setup steps:

1. Add CCEP_Pipeline folder to your MATLAB path and save the path.
2. Run CCEP\_setup (either select the file and press run or type CCEP\_setup on the command line.
3. When prompted, select or create a base directory for data storage. This does not need to be within the CCEP_Pipeline directory, and should be somewhere with plenty of storage space (e.g., a data drive).
4. Wait for completion message to appear in workspace.

Once setup is complete, the app may be run. 

Creating a new subject:

1. Type CCEP into the Matlab workspace and press enter, which will launch the main CCEP app and change your working directory to the data directory.
2. Select 'NEW SUBJECT' in the drop-down menu and enter the subject ID. This will create a new folder for this subject in the data directory.
3. Select 'Upload Raw File' and upload the Matlab-converted TDT file, which should have a single variable called 'data' (struct). Repeat for all CCEP files for this subject. Press 'Convert Unconverted Files' to extract important information from the files. Note: if files are already in \_dat format (containing variables amplitude, anode, cathode, data, fs, onsets\_samps, pulse\_width), click 'Upload \_dat File' instead. No conversion will be necesarry.
4. Check to make sure that stimulation sites and trial numbers match with notes.
5. Choose a \_dat file from the 'Edit File' dropdown menu and press 'Go' to begin processing this file.

Processing a new file:

1. After selecting the file to edit and pressing 'Go', a new app window will open. It might take a long time for this to happen when a file is being processed for the first time, as measurements of noise levels and other spectral calculations are taking place. 
2. The window will initialize on the 'Manual Inspection' tab. Channels that have been automatically identified as bad will be highlighted. To mark a channel as bad or remove the bad designation, click on the channel number. Use left and right arrows to navigate through all channels. The app will automatically only show a pre-stimulation baseline period, but the toggle at the top right allows you to see the full signal (over all stimulation periods). When you are satisfied with labels, click 'Confirm Bad Channels'.
3. The 'Noise Tolerance' tab will open. In the 'Low Frequency Noise' panel, the percentage of channels with significantly nonzero y-intercepts and slopes in a linear model of the entire stimulation period is shown. In the 'Line Noise' pannel, power spectral densities of all good channels is plotted, with the average in black. In the 'High Frequency Noise' panel, a histogram of differential/standard deviation values, combined over all channels, is plotted. Based on the tolerability of the noise, select filter options. Note that these filters will not be applied now, but your choices will appear later on the 'Processing' tab. When you are finished, select 'Confirm Filter Choices'.
4. The 'Artifact Removal' tab will open.