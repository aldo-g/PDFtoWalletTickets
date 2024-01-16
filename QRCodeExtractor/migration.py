import shutil
import os

# Define the source directory from which files will be moved
source_dir = '/app/qr_codes'

# Define the target directory to which files will be moved
target_dir = '/app/shared'

# Get a list of all file names in the source directory
file_names = os.listdir(source_dir)

# Loop over each file name in the source directory
for file_name in file_names:
    # Use shutil.move to move each file to the target directory
    # os.path.join is used to ensure that the file paths are joined correctly regardless of the operating system
    shutil.move(os.path.join(source_dir, file_name), target_dir)