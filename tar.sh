mkdir -p release
mkdir -p ../cloudview_deploy_par/
cd ../cloudview_deploy_par/
mkdir -p  cloudview_deploy/bin/
cp -rf ../cloudview_deploy/create_vm_conf.pl .  
cp -rf ../cloudview_deploy/install.pl .
cp -rf ../cloudview_deploy/lib/  .
cp -rf ../cloudview_deploy/local/  .
pp -o ./cloudview_deploy/create_vm  create_vm_conf.pl
pp -o ./cloudview_deploy/install   install.pl
cp -rf ../cloudview_deploy/vm.conf  ./cloudview_deploy/
cp -rf ../cloudview_deploy/ip_map  ./cloudview_deploy/
cp -rf ../cloudview_deploy/bin/cvm.sh    ./cloudview_deploy/bin
cp -rf ../cloudview_deploy/bin/coc.sh    ./cloudview_deploy/bin
cp -rf ../cloudview_deploy/bin/csp.sh    ./cloudview_deploy/bin
mydate=`date +%Y%m%d`
tar cvzf cloudview_deploy.$mydate.tar.gz  cloudview_deploy
cp cloudview_deploy.$mydate.tar.gz  ../cloudview_deploy/release/
