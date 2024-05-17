Icbackup.sh: Incremental and Differential Backup Script
This bash script Icbackup.sh performs continuous backup operations on the directory tree rooted at /home/username. It creates complete, incremental, and differential backups of files, storing them in specific directories and updating a backup.log file with timestamps and backup file names.

Operation
Complete Backup: Tar all files in the directory tree rooted at /home/username into cb****.tar in ~/home/backup/cbw24 and update backup.log.
Incremental Backups: Create incremental backups of newly created or modified files since the last backup, storing them in ib****.tar in ~/home/backup/ib24 and update backup.log.
Differential Backup: Create a differential backup of files modified since the last complete backup, storing them in db****.tar in ~/home/backup/db24 and update backup.log.
Usage
Clone the repository:

git clone https://github.com/username/repository.git
Change directory to the repository:

cd repository
Run the Icbackup.sh script:

./Icbackup.sh
Note
Adjust the paths and naming conventions (cb****.tar, ib****.tar, db****.tar) as needed.
