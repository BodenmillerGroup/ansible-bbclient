# Aim: make an image of the bb-server that on
# can simply be booted and contains all the necessary
# mount commands as well as user information
# and has already the most important software installed


## Setup required on the main server
# 1)  make an NFS share on the original bbvolume server

sudo apt-get install nfs-kernel-server

# 2) set /etc/exports to share the bbvolume with the whole bb_uzh private network

"""
/mnt/bbvolume 10.65.12.0/24(rw,async,crossmnt,no_subtree_check)
"""

# after restarting the nfs server, /mnt/bbvolume is now accessible - and mountable - by the whole bb_uzh network

# 3) export the password/login related files to the bbvolume in an encrypted tar folder
# (this can then be used to setup the client servers)

"""
mkdir /root/move/
export UGIDLIMIT=500
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/passwd > /root/move/passwd.mig
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/group > /root/move/group.mig
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534) {print $1}' /etc/passwd | tee - |egrep -f - /etc/shadow > /root/move/shadow.mig
cp /etc/gshadow /root/move/gshadow.mig
tar zcvpf - /root/move/* | ccrypt -K BBpasswd2012. > /mnt/bbvolume/movelog.tar.gz.cpt
""" 

# -> This unfortunately does not perserve sudo rights for users at the moment!

###########################################
# use the ansible script to configure a ubuntu16.04 instance
# 1) add the server IP to the hosts file
# 2) activate the ansible virutalenv
workon ansible
# 3) run the playbook
ansible-playbook -i hosts -u ubuntu configure-bbclient.yml

# Install R & Rstudio server manually (for now as i cannot get the ansible R installation working):

codename=$(lsb_release -c -s)
echo "deb http://stat.ethz.ch/CRAN/bin/linux/ubuntu $codename/" | sudo tee -a /etc/apt/sources.list > /dev/null
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo add-apt-repository ppa:marutter/rdev
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y r-base r-base-dev


sudo apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.447-amd64.deb
sudo gdebi rstudio-server-1.1.447-amd64.deb

# get R dependencies
sudo apt-get -y build-dep r-cran-rgl libcurl4-openssl-dev 

# Rjava (https://github.com/hannarud/r-best-practices/wiki/Installing-RJava-(Ubuntu)), used for the library for xlsx reading
sudo apt-get -y install default-jdk
sudo R CMD javareconf
sudo apt-get -y install r-cran-rjava
sudo apt-get -y install libgdal1-dev libproj-dev

# Install the major R packages

sudo R
"
update.packages()
install.packages(c('devtools','ggplot2', 'data.table','reshape2', 'doMC','boot','gplots', 'RColorBrewer',  'rgl','RCurl', 'threejs', 'PKI', 'rsconnect','devtools', 'packrat','nnls', 'data.table', 'dplyr', 'dtplyr', 'ggmpmisc', 'packrat','nnls', 'stringi', 'raster', 'viridis', 'cba' , 'fields','plotly', 'largeVis','Rtsne', 'httr', 'ConsensusClusterPlus'))


if(!require(devtools)) install.packages("devtools") # If not already installed
devtools::install_github("RGLab/Rtsne.multicore")
source("https://bioconductor.org/biocLite.R")
update.packages()
biocLite('FlowSOM')
biocLite("flowCore")
biocLite("destiny")
biocLite("qvalue")
biocLite("cytofkit")

if(!require(devtools)) install.packages("devtools") # If not already installed
devtools::install_github("RGLab/Rtsne.multicore")

# installing the 'bbRtools' package from the lab
install.packages('/mnt/bbvolume/labcode/bbRtools',repos = NULL, type="source")
install.packages('largeVis')
# installing the modified cytofkit that allows the usage of an approximated thus faster
# kNN graph calculation for phenograph
install.packages('/mnt/bbvolume/labcode/cytofkit_1.9.3.tar.gz')
"

# x2go:
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:x2go/stable
sudo apt-get update
sudo apt-get install x2goserver x2goserver-xsession

