# cd into the folder above bopla_mass
cd ~/learning/labs

# Remove previously exported dependencies
rm -rf local-maven-repo

# cd into project folder
cd bopla_mass

# Prep dependencies to be used offline
# spring-boot:repackage is needed to get extra dependencies for "mvn spirng-boot:run" to run
# local-maven-repo is in the parent folder to avoid issues with git
mvn clean package spring-boot:repackage -Dmaven.repo.local=../local-maven-repo

# Move to exported dependencies
cd ~/learning/labs/local-maven-repo

# While in local-maven repo
zip -r ~/learning/labs/bopla_mass/deps.zip .

# cd back to project folder
cd ../bopla_mass

# Stage the changes locally
git add .

# Commit locally with a message
git commit -m "some_message"

# Push upstream
git push origin main