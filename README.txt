# Aim: make an image of the bbvolume that on
# can simply be booted and contains all the necessary
# mount commands as well as user information
# 1)  make an NFS share on the original bbvolume

sudo apt-get install nfs-kernel-server

# 2) set /etc/exports to share the bbvolume with the whole bb_uzh network

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
tar zcvpf - /root/move/* | ccrypt > /mnt/bbvolume/movelog.tar.gz.cpt
""" 

###########################################
# use the ansible script to configure a ubuntu16.04 instance
# 1) add the server IP to the hosts file
# 2) acttivate the ansible virutalenv
workon ansible
# 3) run the playbook
ansible-playbook -i hosts -u ubuntu configure-bbclient.yml

# Install R & Rstudio server manually (for now):

codename=$(lsb_release -c -s)
echo "deb http://stat.ethz.ch/CRAN/bin/linux/ubuntu $codename/" | sudo tee -a /etc/apt/sources.list > /dev/null
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo add-apt-repository ppa:marutter/rdev
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install r-base r-base-dev


sudo apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.414-amd64.deb
sudo gdebi rstudio-server-1.1.414-amd64.deb

# get R dependencies
sudo apt-get -y build-dep r-cran-rgl
# configure the most important R packages (sudo R)
sudo apt install -y libcurl4-openssl-dev 
update.packages()
install.packages(c('devtools','ggplot2', 'data.table','reshape2', 'doMC','boot','gplots',
'RColorBrewer',  'rgl','RCurl', 'threejs', 'PKI', 'rsconnect','devtools', 'packrat','nnls', 'data.table', 'dplyr', 'dtplyr', 'tidyverse'))
update.packages()
install.packages(c('ggmpmisc', 'packrat','nnls', 'stringi', 'raster', 'viridis', 'cba' , 'fields','plotly', 'largeVis','Rtsne', 'httr', 'ConsensusClusterPlus'))


update.packages()
if(!require(devtools)) install.packages("devtools") # If not already installed
devtools::install_github("RGLab/Rtsne.multicore")
source("https://bioconductor.org/biocLite.R")
update.packages()
biocLite('FlowSOM')
biocLite('EBImage')
biocLite("flowCore")
biocLite("destiny")
biocLite("qvalue")
biocLite("cytofkit")

install.packages('/mnt/bbvolume/labcode/bbRtools',repos = NULL, type="source")
install.packages('cytofkit_1.9.3.tar.gz')







# x2go:
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:x2go/stable
sudo apt-get update
sudo apt-get install x2goserver x2goserver-xsession

