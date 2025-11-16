./get_proc_data.sh 
#1754497127
./sc_run.sh rebuild
#1754497203
sudo ps -ao user,pid,comm,pcpu --sort=-pcpu |grep -v -e 'ps|sudo|bash|sc_run.sh' | awk 'NR==2 {$4=$4"%"; print}' |column -t -R 4
#1754498400
cp get_proc_data.sh get-cpu-usage.sh
#1754498410
mv get-cpu-usage.sh get_cpu_data.sh
#1754498489
nano get_cpu_data.sh 
#1754498503
cat get_cpu_data.sh 
#1754498510

#1754498559
cut -d' ' -f1 /proc/loadavg
#1754498583
vmstat 1 2 | tail -1 | awk '{printf "%.0f\n", 100 - $15}'
#1754498588
free | awk '/Mem:/ {printf "%.0f\n", ($2-$7)/$2 * 100}'
#1754499308
./get_cpu_data.sh 
#1754501957
cp get_cpu_data.sh get_rotation.data.sh
#1754501960
nano get_rotation.data.sh 
#1754502129
./launch.sh 
#1754504810
clear
#1754506259
alactirry
#1754506262
alacritty 
#1754506273
bg 1
#1754488353
sudo ps -ao user,pid,comm,pcpu --sort=-pcpu | awk 'NR==2 {$4=$4"%"; print}' |column -t -R 4
#1754493330
cp get_local_data.sh get_proc_data.sh
#1754496792
./get_proc_data.sh 
#1754497203
sudo ps -ao user,pid,comm,pcpu --sort=-pcpu |grep -v -e 'ps|sudo|bash|sc_run.sh' | awk 'NR==2 {$4=$4"%"; print}' |column -t -R 4
#1754498400
cp get_proc_data.sh get-cpu-usage.sh
#1754498410
mv get-cpu-usage.sh get_cpu_data.sh
#1754498489
nano get_cpu_data.sh 
#1754498503
cat get_cpu_data.sh 
#1754498559
cut -d' ' -f1 /proc/loadavg
#1754498583
vmstat 1 2 | tail -1 | awk '{printf "%.0f\n", 100 - $15}'
#1754498588
free | awk '/Mem:/ {printf "%.0f\n", ($2-$7)/$2 * 100}'
#1754499308
./get_cpu_data.sh 
#1754501957
cp get_cpu_data.sh get_rotation.data.sh
#1754501960
nano get_rotation.data.sh 
#1754506259
alactirry
#1754506262
alacritty 
#1754506273
bg 1
#1754511733
xrandr | grep ' connected' | grep -oE '[0-9]+x[0-9]+' | xargs
#1754511760
cd .config/eww/scripts/
#1754515830
./sc_run.sh vars
#1754516870
free -h
#1754516877
free --help
#1754516916
free -h | awk 'NR==2{print $2}'
#1754516929
free -h | awk 'NR==2{print $2}' |cut -dG -f 1
#1754516943
free -h | awk 'NR==2' |cut -dG -f 1
#1754516948
free -h | awk 'NR==2'
#1754517012
free | awk '/Mem/{printf("%.1f%\n"), $7/$2 * 100}'
#1754517981
./sc_run.sh rebuild
#1754517997
./sc_run.sh read
#1754518112
sudo rm nohup.out 
#1754518116
cd images/
#1754518119
cd icons/
#1754518135
sudo chmod 644 *
#1754518149
mv Clone\ Trupper.ico clone_trooper.ico
#1754518150
ll
#1754518161
mv R2D2.ico r2d2.ico
#1754518167
mv Sonic.ico sonic.ico
#1754518379
l
#1754518519
cd ..
#1754518522
cd scripts/
#1754518523
./launch.sh 
#1754518934
clear
#1754518522
cd scripts/
#1754518523
./launch.sh 
#1754583076
pwvucontrol 
#1754584261
cd Git/
#1754584261
l
#1754584655
sudo nano /etc/nixos/modules/packages.nix 
#1754584672
sudo nixos-rebuild switch
#1754585324
systemctl status lsyncd
#1754585422
sudo su
#1754585535
clear
#1754584655
sudo nano /etc/nixos/modules/packages.nix 
#1754584672
sudo nixos-rebuild switch
#1754585324
systemctl status lsyncd
#1754585422
sudo su
#1754585675
cd Git/nixos/
#1754585700
git commit -m 'fix and separated all files and segments'
#1754585751
git add .
#1754585781
git commit -m 'removed passwords'
#1754585784
git push
#1754585868
l
#1754585892
mc
#1754585923
clear
#1754589746
cd Git/nixos/etc/nixos/modules/
#1754589748
cat files 
#1754589754
rm files
#1754590243
sudo su
#1754589748
cat files 
#1754589754
rm files
#1754760122
sudo cat /etc/lsyncd/files
#1754760125
sudo su
#1754760178
cd /mnt/nfs/juliano/
#1754760180
cd ..
#1754760182
cd juliano/
#1754760183
clear
#1754760183
l
#1754760184
ll
#1754760237
mkdir .local .config .cache 
#1754760566
mc
#1754760821
OA
#1754589754
rm files
#1754590243
sudo su
#1754759811
cd /mnt/nfs
#1754759820
go2 3
#1754759870
mkdir juliano
#1754759872
cd juliano
#1754759881
ls -lad /home/juliano/
#1754759884
ls -lad /home/juliano/*
#1754759903
ls -lad /home/juliano/* |cut -d/ -f3
#1754759905
ls -lad /home/juliano/* |cut -d/ -f4
#1754759932
for var in $(ls -lad /home/juliano/* |cut -d/ -f4); do echo "mkdir " $var; done
#1754759945
for var in $(ls -lad /home/juliano/* |cut -d/ -f4); do echo "mkdir /mnt/nfs/juliano/"$var; done
#1754759956
for var in $(ls -lad /home/juliano/* |cut -d/ -f4); do mkdir /mnt/nfs/juliano/$var; done
#1754759959
ls -lash
#1754759961
clear
#1754759962
mc
#1754761630
clear
#1754761634
ping 192.168.0.3
#1754761346
sudo su
#1754762213
clear
#1754762224
tmux
#1754762143
clear
#1754762145
go2 3
#1754762187
go2 20
#1754762298
go2 3
#1754762281
dstat -cdngy 1
#1754762292
journalctl -b -1 -p 3
#1754763853
go2 20
#1754762274
ping 192.168.0.3
#1754762269
ping 192.168.0.20
#1754764110
sudo su
#1754766634
go2 20
#1754767041
sudo su
#1754767131
go2 20
#1754767249
terminator
#1754766963
sudo su
#1754767429
mc
#1754770594
go2 20
#1754767260
go2 20
#1754772365
go2 3
#1754773906
sudo su
#1754772132
sudo su
#1754773435
mc
#1754776395
sudo su
#1754772132
sudo su
#1754773435
mc
#1754776283
cd /var/log/lsyncd/
#1754776283
l
#1754776290
tailf -f lsyncd.log 
#1754776295
clear
#1754776296
tail -f lsyncd.log 
#1754776300
cd /var/log
#1754776302
cd lsyncd/
#1754776303
clear
#1754776306
tail -f lsyncd.status 
#1754772132
sudo su
#1754773435
mc
#1754776395
sudo su
#1754826076
clear
#1754826116
sudo systemctl start lsyncd
#1754826121
sudo systemctl status lsyncd
#1754826326
sudo systemctl stop lsyncd
#1754826395
htop
#1754776341
sudo systemctl status lsyncd
#1754776346
watch -n 1 sudo systemctl status lsyncd
#1754826442
watch -n 1 sudo ps -ef |grep rsyncd
#1754826455
watch -n 1 "sudo ps -ef |grep 'rsyncd'"
#1754826465
watch -n 1 "sudo ps -ef |grep 'rsyncd' |grep -v 'grep'"
#1754826485
watch -n 1 "sudo ps -ef |grep 'rsync' |grep -v 'grep'"
#1754826518
clear
#1754826522
cd /mnt/nfs
#1754826528
watch -n 1 'df -h .'
#1754767249
terminator
#1754766963
sudo su
#1754767429
mc
#1754770594
go2 20
#1754767260
go2 20
#1754772365
go2 3
#1754773906
sudo su
#1754772132
sudo su
#1754773435
mc
#1754776395
sudo su
#1754776499
watch -n1 ps -ef |grep rsync |grep -v -i 'grep'
#1754776508
watch -n 1 ps -ef |grep rsync |grep -v -i 'grep'
#1754776520
btop
#1754776524
htop
#1754776597
ps -ef |grep rsync |grep -v -i 'grep'
#1754776609
watch -n 1 'ps -ef |grep rsync |grep -v -i 'grep''
#1754776970
cd /mnt/nfs
#1754776978
watch -n 1 df -h .
#1754826090
l
#1754826377
nohup rsync --delete --ignore-errors -vgouptslD --partial --inplace --no-perms --no-group --chmod=D755,F644 -r --exclude-from=/etc/lsyncd/exclude.lst /home/juliano/ /mnt/nfs/juliano/ &
#1754826382
tail -f nohup.out 
#1754830349
kill -9 1013703 1013712 1013713 
#1754830351
ps -ef |grep rsync
#1754830355
clear
#1754776232
go2 3
#1754776524
htop
#1754776597
ps -ef |grep rsync |grep -v -i 'grep'
#1754776609
watch -n 1 'ps -ef |grep rsync |grep -v -i 'grep''
#1754776970
cd /mnt/nfs
#1754776978
watch -n 1 df -h .
#1754826090
l
#1754826377
nohup rsync --delete --ignore-errors -vgouptslD --partial --inplace --no-perms --no-group --chmod=D755,F644 -r --exclude-from=/etc/lsyncd/exclude.lst /home/juliano/ /mnt/nfs/juliano/ &
#1754826382
tail -f nohup.out 
#1754830349
kill -9 1013703 1013712 1013713 
#1754830351
ps -ef |grep rsync
#1754776232
go2 3
#1754931266
cd
#1754931267
ll
#1754931313
sudo su
#1754931917
cat list |sort
#1754931988
nano list
#1754932017
cat list
#1754932049
for var in $(cat list); do echo "    /home/juliano/"$var; done
#1754932073
for var in $(cat list); do echo '"    /home/juliano/"'$var; done
#1754932079
for var in $(cat list); do echo '    "/home/juliano/"'$var; done
#1754932090
for var in $(cat list); do echo '    "/home/juliano/'$var"; done
#1754932105
for var in $(cat list); do echo '    "/home/juliano/${var}"'; done
#1754932121
for var in $(cat list); do echo '    "/home/juliano/\$\{var\}"'; done
#1754932131
for var in $(cat list); do echo '    "/home/juliano/\$var"'; done
#1754932134
for var in $(cat list); do echo '    "/home/juliano/$var"'; done
#1754932146
for var in $(cat list); do echo '    "/home/juliano/"$var'; done
#1754932152
for var in $(cat list); do echo '    "/home/juliano/'$var; done
#1754932308
clear
#1754932323
nano list 
#1754932334
for var in $(cat list); do echo '    "/home/juliano/'$var'"'; done
#1754933664
cd Git/nixos/etc/nixos/modules/
#1754933666
cat lsyncd
#1754933668
cat lsyncd.nix 
#1754949968
sudo su
#1754950556
htop
#1754991005
sudo su
#1754767429
mc
#1754770594
go2 20
#1754767260
go2 20
#1754772365
go2 3
#1754773435
mc
#1754776499
watch -n1 ps -ef |grep rsync |grep -v -i 'grep'
#1754776508
watch -n 1 ps -ef |grep rsync |grep -v -i 'grep'
#1754776520
btop
#1754776524
htop
#1754776597
ps -ef |grep rsync |grep -v -i 'grep'
#1754776609
watch -n 1 'ps -ef |grep rsync |grep -v -i 'grep''
#1754776970
cd /mnt/nfs
#1754776978
watch -n 1 df -h .
#1754826377
nohup rsync --delete --ignore-errors -vgouptslD --partial --inplace --no-perms --no-group --chmod=D755,F644 -r --exclude-from=/etc/lsyncd/exclude.lst /home/juliano/ /mnt/nfs/juliano/ &
#1754826382
tail -f nohup.out 
#1754830349
kill -9 1013703 1013712 1013713 
#1754830351
ps -ef |grep rsync
#1754776232
go2 3
#1754926209
sudo fdisk /dev/sdb
#1754926235
sudo mkfs.ext4 /dev/sdb1
#1754926239
lsblk
#1754941906
cd /etc/nixos/modules/
#1754941921
tar czf files.tar.gz *
#1754941926
tar czf * files.tar.gz
#1754941940
zip files.zip *
#1754941984
mv Xsetup /home/juliano/Git/linux/.BACKUP/.
#1754941988
sudo mv Xsetup /home/juliano/Git/linux/.BACKUP/.
#1754942007
cd
#1754942014
cd Git/nixos/etc/nixos/modules/
#1754942015
ll
#1754942035
tar cf files.tar.gz *
#1754942278
sudo nixos-rebuild switch
#1754947257
cd ..
#1754947278
git commit -m 'fix lsyncd and ollama services'
#1754947303
nano ju
#1754947311
cd etc/nixos/modules/
#1754947312
nano juliano.nix 
#1754947324
git add .
#1754947332
git commit -m 'removed pass'
#1754947335
git push
#1754947400
sudo su
#1754995840
cd 
#1754995856
cd .config/eww/scripts/
#1754995857
clear
#1754995858
l
#1754995858
l
#1755084686
cd .config
#1755084693
mkdir syncthing
#1755084698
cd syncthing
#1755084762
nano ignores
#1755084772
clear
#1754995856
cd .config/eww/scripts/
#1755084686
cd .config
#1755084693
mkdir syncthing
#1755084698
cd syncthing
#1755084762
nano ignores
#1755085099
cd .config/syncthing/
#1755085102
rm ignores 
#1755085107
mkdir ignores
#1755085109
cd ignores/
#1755085136
cat /etc/lsyncd/exclude.lst |cut -d. -f2
#1755085144
cat /etc/lsyncd/exclude.lst |cut -d/ -f2
#1755085150
cat /etc/lsyncd/exclude.lst |cut -d/ -f1
#1755085154
cat /etc/lsyncd/exclude.lst |cut -d/ -f1 |uniq
#1755085180
touch .cache.stignore
#1755085184
touch .config.stignore
#1755085189
touch .local.stignore
#1755085199
mv .cache.stignore cache.stignore 
#1755085207
mv .config.stignore config.stignore 
#1755085208
ll
#1755085215
mv .local.stignore local.stignore 
#1755085216
l
#1755085218
clear
#1755085226
nano cache.stignore 
#1755085237
nano config.stignore 
#1755085247
nano local.stignore 
#1755085189
touch .local.stignore
#1755085199
mv .cache.stignore cache.stignore 
#1755085207
mv .config.stignore config.stignore 
#1755085215
mv .local.stignore local.stignore 
#1755085216
l
#1755085226
nano cache.stignore 
#1755085237
nano config.stignore 
#1755085247
nano local.stignore 
#1755086599
ls -lash .*
#1755086605
ls -lashd .*
#1755086612
ls -lad .*
#1755086616
ls -laD .*
#1755086634
ls -la .* |grep 'drwx'
#1755086653
ls -lash
#1755086674
ll |awk '{print $9}'
#1755086678
ll |awk '{print $8}'
#1755086693
nano list
#1755086764
cat list
#1755086798
nano list 
#1755086808
for var in $(cat list); do touch $var/.stignore; done
#1755086814
ll
#1755086816
mc
#1755086864
clear
#1754933666
cat lsyncd
#1754933668
cat lsyncd.nix 
#1754950439
go2 3
#1754982727
cd /mnt/usb/
#1754982737
clear 
#1754995306
cd ..
#1754995444
cd nvm
#1754995459
sudo rm -Rf lost+found/
#1754995469
watch -n 1 df -h .
#1754995822
clear
#1754995826
sudo su
#1754933668
cat lsyncd.nix 
#1754949968
sudo su
#1754950498
cd /mnt/nfs
#1754950506
watch -n 1 df -h .
#1754950580
watch -n 30 df -h .
#1754982778
tail -f /var/log/lsyncd/lsyncd.status 
#1754983359
clear
#1754983362
tail -f /var/log/lsyncd/lsyncd.log 
#1754933668
cat lsyncd.nix 
#1754949968
sudo su
#1754950516
cd /mnt/nfs
#1754950517
cd juliano/
#1754950528
watch -n 1 du -sh *
#1754950575
watch -n 30 du -sh *
#1754983367
clear
#1754983367
tail -f /var/log/lsyncd/lsyncd.status 
#1754932079
for var in $(cat list); do echo '    "/home/juliano/"'$var; done
#1754932090
for var in $(cat list); do echo '    "/home/juliano/'$var"; done
#1754932105
for var in $(cat list); do echo '    "/home/juliano/${var}"'; done
#1754932121
for var in $(cat list); do echo '    "/home/juliano/\$\{var\}"'; done
#1754932131
for var in $(cat list); do echo '    "/home/juliano/\$var"'; done
#1754932134
for var in $(cat list); do echo '    "/home/juliano/$var"'; done
#1754932146
for var in $(cat list); do echo '    "/home/juliano/"$var'; done
#1754932152
for var in $(cat list); do echo '    "/home/juliano/'$var; done
#1754932323
nano list 
#1754932334
for var in $(cat list); do echo '    "/home/juliano/'$var'"'; done
#1754933664
cd Git/nixos/etc/nixos/modules/
#1754933666
cat lsyncd
#1754933668
cat lsyncd.nix 
#1754949968
sudo su
#1754950462
go2 3
#1754982752
cd /mnt/usb/
#1754995309
cd ..
#1754995448
cd nvm
#1754995674
cd juliano
#1755036958
clear
#1755036961
watch -n 1 du -sh *
#1755076482
ll
#1755076484
watch -n 30 du -sh *
#1755076504
watch -n 30 df -h .
#1755088978
cd .config/syncthing/
#1755088982
nano config.xml
#1755092631
cd .config
#1755092635
mkdir lsyncd
#1755092642
cp /etc/lsyncd/* .
#1755092642
ll
#1755092646
mc
#1755092660
clear
#1754826382
tail -f nohup.out 
#1754830349
kill -9 1013703 1013712 1013713 
#1754830351
ps -ef |grep rsync
#1754776232
go2 3
#1754926209
sudo fdisk /dev/sdb
#1754926235
sudo mkfs.ext4 /dev/sdb1
#1754941906
cd /etc/nixos/modules/
#1754941921
tar czf files.tar.gz *
#1754941926
tar czf * files.tar.gz
#1754941940
zip files.zip *
#1754941984
mv Xsetup /home/juliano/Git/linux/.BACKUP/.
#1754941988
sudo mv Xsetup /home/juliano/Git/linux/.BACKUP/.
#1754942007
cd
#1754942014
cd Git/nixos/etc/nixos/modules/
#1754942035
tar cf files.tar.gz *
#1754942278
sudo nixos-rebuild switch
#1754947278
git commit -m 'fix lsyncd and ollama services'
#1754947303
nano ju
#1754947311
cd etc/nixos/modules/
#1754947312
nano juliano.nix 
#1754947324
git add .
#1754947332
git commit -m 'removed pass'
#1754947335
git push
#1754995840
cd 
#1754995856
cd .config/eww/scripts/
#1755078046
sudo fdisk /dev/sdc
#1755078069
sudo mkfs.ext4 /dev/sdc1
#1755078075
lsblk
#1755080210
sudo su
#1755096328
cd .local
#1755096331
cd share/
#1755096341
cd .config
#1755096369
cd .local/share/
#1755096454
cd Steam/
#1755096573
cd index-v0.14.0.db/
#1755096578
cd ,,
#1755096579
ckear
#1755096579
k
#1755096583
cl
#1755096593
rm -Rf index-v0.14.0.db/ Sync/
#1755096616
l |awk '{print $8}'
#1755096724
cd .cache
#1755096725
l
#1755096832
cd ..
#1755096833
clear
#1755096833
ll
#1755096923
cat .webui_secret_key
#1755085199
mv .cache.stignore cache.stignore 
#1755085207
mv .config.stignore config.stignore 
#1755085215
mv .local.stignore local.stignore 
#1755085226
nano cache.stignore 
#1755085237
nano config.stignore 
#1755085247
nano local.stignore 
#1755086599
ls -lash .*
#1755086605
ls -lashd .*
#1755086612
ls -lad .*
#1755086616
ls -laD .*
#1755086634
ls -la .* |grep 'drwx'
#1755086653
ls -lash
#1755086674
ll |awk '{print $9}'
#1755086678
ll |awk '{print $8}'
#1755086693
nano list
#1755086764
cat list
#1755086798
nano list 
#1755086808
for var in $(cat list); do touch $var/.stignore; done
#1755086816
mc
#1754933666
cat lsyncd
#1754933668
cat lsyncd.nix 
#1754950439
go2 3
#1754982727
cd /mnt/usb/
#1754982737
clear 
#1754995444
cd nvm
#1754995459
sudo rm -Rf lost+found/
#1754995469
watch -n 1 df -h .
#1754995826
sudo su
#1754933668
cat lsyncd.nix 
#1754949968
sudo su
#1754950498
cd /mnt/nfs
#1754950506
watch -n 1 df -h .
#1754950580
watch -n 30 df -h .
#1754982778
tail -f /var/log/lsyncd/lsyncd.status 
#1754983362
tail -f /var/log/lsyncd/lsyncd.log 
#1754933668
cat lsyncd.nix 
#1754949968
sudo su
#1754950516
cd /mnt/nfs
#1754950517
cd juliano/
#1754950528
watch -n 1 du -sh *
#1754950575
watch -n 30 du -sh *
#1754983367
tail -f /var/log/lsyncd/lsyncd.status 
#1754932079
for var in $(cat list); do echo '    "/home/juliano/"'$var; done
#1754932090
for var in $(cat list); do echo '    "/home/juliano/'$var"; done
#1754932105
for var in $(cat list); do echo '    "/home/juliano/${var}"'; done
#1754932121
for var in $(cat list); do echo '    "/home/juliano/\$\{var\}"'; done
#1754932131
for var in $(cat list); do echo '    "/home/juliano/\$var"'; done
#1754932134
for var in $(cat list); do echo '    "/home/juliano/$var"'; done
#1754932146
for var in $(cat list); do echo '    "/home/juliano/"$var'; done
#1754932152
for var in $(cat list); do echo '    "/home/juliano/'$var; done
#1754932323
nano list 
#1754932334
for var in $(cat list); do echo '    "/home/juliano/'$var'"'; done
#1754933664
cd Git/nixos/etc/nixos/modules/
#1754933666
cat lsyncd
#1754933668
cat lsyncd.nix 
#1754949968
sudo su
#1754950462
go2 3
#1754982752
cd /mnt/usb/
#1754995448
cd nvm
#1754995674
cd juliano
#1755036961
watch -n 1 du -sh *
#1755076484
watch -n 30 du -sh *
#1755076504
watch -n 30 df -h .
#1755088982
nano config.xml
#1755092635
mkdir lsyncd
#1755092642
cp /etc/lsyncd/* .
#1755092646
mc
#1755092876
cd .config/syncthing/
#1755092885
touch syncthing.log
#1755093274
syncthing -generate="~/.config/syncthing"
#1755093282
syncthing
#1755093333
/nix/store/pv2xr80ilq668lis4r3q4dynaw89k0bp-syncthing-1.29.5/bin/syncthing -no-browser -gui-address=192.168.0.18:8384 -config=/home/juliano/.config/syncthing -data=/home/juliano/sudo -u juliano /nix/store/pv2xr80ilq668lis4r3q4dynaw89k0bp-syncthing-1.29.5/bin/syncthing -generate="~/.config/syncthing"
#1755093393
rm .syncthing.tmp.766062569 cert.pem config.xml config.xml.v0 https-cert.pem https-key.pem key.pem syncthing.lock
#1755093398
/nix/store/pv2xr80ilq668lis4r3q4dynaw89k0bp-syncthing-1.29.5/bin/syncthing -generate="~/.config/syncthing"
#1755093410
cat config.xml
#1755093461
/nix/store/pv2xr80ilq668lis4r3q4dynaw89k0bp-syncthing-1.29.5/bin/syncthing -no-browser -gui-address=192.168.0.18:8384 -config=/home/juliano/.config/syncthing -data=/home/juliano/
#1755093936
cd 
#1755093938
cd Git/
#1755093945
cd julas/
#1755095447
cd .config
#1755095456
mv lsyncd/ jsyncd
#1755095459
cd jsyncd/
#1755095459
;
#1755095489
mv lsyncd-config.lua ~/Git/linux/.ETC/lsyncd/.
#1755095494
cat files.lst 
#1755095497
rm files.lst 
#1755095508
mv jsyncd/ jsync
#1755096233
cat exclude.lst 
#1755096841
cat include.lst 
#1755096998
nano include.lst
#1755097442
nano jsync.sh
#1755097462
cd systemd/user/
#1755097474
nano jsync.service
#1755097488
nano jsync.timer
#1755097506
cd -
#1755097508
cd jsync/
#1755097512
sudo chmod +x ~/.config/jsync/jsync.sh
#1755097517
systemctl --user daemon-reload
#1755097520
systemctl --user enable --now jsync.timer
#1755097533
systemctl --user status jsync.service
#1755097539
systemctl --user enable jsync.service
#1755097585
nano jsync.sh 
#1755097626
systemctl --user status jsync.timer
#1755097666
sudo rm -Rf img
#1755097694
lsblk
#1755097705
sudo umount nvm
#1755097709
sudo mount nvm
#1755097718
sudo chown juliano:juliano nvm -R
#1755097727
sudo chown juliano:juliano usb -R
#1755097731
sudo chown juliano:juliano ssd -R
#1755097773
cd Git/nixos/etc/nixos/
#1755097775
cd modules/
#1755097786
cp /etc/nixos/modules/* .
#1755097810
rm -Rf lsyncd_new.nix lsyncd_old.nix 
#1755097818
rm files 
#1755097830
ls -w
#1755097837
ls -c
#1755097838
l
#1755097856
cd ..
#1755097860
git add .
#1755097879
git commit -m 'included syncthing and adjusted lsyncd'
#1755097881
git push
#1755098059
cd
#1755098064
cd .config/systemd/u
#1755098067
cd .config/systemd/
#1755098070
cd user/
#1755098070
ls
#1755098085
rm cava.service 
#1755098092
rm openrazer-daemon.service 
#1755098094
cat set-custom-colors.service 
#1755098100
rm set-custom-colors.service 
#1755098127
cp jsync.* ~/.config/jsync/.
#1755098136
nano jsync.service 
#1755098258
cd /mnt
#1755098258
ll
#1755098264
du -sh *
#1755098268
df -h *
#1755098271
clear
#1755098277
watch -n 5 df -h *
#1755098408
cd /mnt
#1755098409
clear
#1755098414
watch -n 5 df-h *
#1755098424
watch -n 5 df -h *
#1755098127
cp jsync.* ~/.config/jsync/.
#1755098136
nano jsync.service 
#1755098258
cd /mnt
#1755098264
du -sh *
#1755098268
df -h *
#1755098277
watch -n 5 df -h *
#1755098540
cd .config/jsync/
#1755098557
sudo chown juliano:juliano *
#1755098563
sudo chmod 777 * -R
#1755098566
cd log
#1755098567
l
#1755098569
cd logs/
#1755098571
clear
#1755098571
ll
#1755098575
tail -f nvm.log 
#1755098460
watch -n 5 systemctl --user status jsync.timer
#1755098127
cp jsync.* ~/.config/jsync/.
#1755098136
nano jsync.service 
#1755098258
cd /mnt
#1755098264
du -sh *
#1755098268
df -h *
#1755098277
watch -n 5 df -h *
#1755098605
systemctl --user restart jsync.timer
#1755098609
systemctl --user restart jsync.service
#1755098633
cd .config/jsync/
#1755098639
cd logs/
#1755101328
cd ..
#1755101333
cat jsync.s
#1755101335
cat jsync.sh 
#1755101383
nano jsync.sh 
#1755101464
cd logs
#1755101465
l
#1755101467
clear
#1755101478
ll
#1755113453
htop
#1755101383
nano jsync.sh 
#1755101464
cd logs
#1755101465
l
#1755113315
cd /mnt
#1755113408
watch -n 5 systemctl --user status jsync.service
#1755129142
systemctl --user stop jsync.timer
#1755129146
systemctl --user status jsync.timer
#1755129154
systemctl --user stop jsync.service
#1755129155
clear
#1755129156
ll
#1755101335
cat jsync.sh 
#1755101383
nano jsync.sh 
#1755101464
cd logs
#1755101465
l
#1755113315
cd /mnt
#1755113369
cd nfs
#1755113375
watch -n 1 du -sh *
#1755113383
watch -n 5 du -sh *
#1755113417
rm nohup.out 
#1755113419
ll
#1755113420
clear
#1755113436
watch -n 5 systemctl --user status jsync.timer
#1755101383
nano jsync.sh 
#1755101464
cd logs
#1755101465
l
#1755113315
cd /mnt
#1755113347
cd 
#1755113351
cd .config/jsync/
#1755113354
cd logs/
#1755113354
ll
#1755113359
clear
#1755113359
tail -f nvm.log 
#1755101464
cd logs
#1755101465
l
#1755113301
cd
#1755113315
cd /mnt
#1755113316
clear
#1755113317
ll
#1755113339
watch -n 5 df -h *
#1755113301
cd
#1755113315
cd /mnt
#1755113339
watch -n 5 df -h *
#1755131117
sudo renice -19 2122902 2125902 2125918 2125919 2125920
#1755131133
sudo renice -19 2122902 2125902
#1755131173
eww kill
#1755153776
cd .config/jsync/
#1755153778
cd logs
#1755153781
ls
#1755153781
ll
#1755153783
clear
#1755113301
cd
#1755113315
cd /mnt
#1755113317
ll
#1755113339
watch -n 5 df -h *
#1755129175
cd .config/jsync/
#1755129175
l
#1755129436
which bash
#1755129617
nano jsync.sh
#1755130058
clear
#1755130074
cat jsync.sh
#1755130197
rsync -avh --delete --include-from=$HOME/.config/jsync/include.lst --exclude-from=$HOME/.config/jsync/exclude.lst /mnt/juliano /mnt/nfs/juliano/
#1755130215
rsync -avh --delete --include-from=$HOME/.config/jsync/include.lst --exclude-from=$HOME/.config/jsync/exclude.lst /home/juliano/ /mnt/nfs/juliano/
#1755130675
rsync -avh --include-from=$HOME/.config/jsync/include.lst --exclude-from=$HOME/.config/jsync/exclude.lst --info=progress2 --partial --inplace /home/juliano/ /mnt/nfs/juliano/
#1755113301
cd
#1755113315
cd /mnt
#1755113339
watch -n 5 df -h *
#1755130265
cd /mnt/nfs
#1755130267
cd juliano/
#1755130270
ll
#1755130273
ls -lash
#1755130275
ls
#1755130278
clear
#1755130295
watch -n5 du -sh .
#1755130303
cd ..
#1755130306
watch -n5 du -sh juliano/
#1755130323
watch -n5 du -sh *
#1755130275
ls
#1755130295
watch -n5 du -sh .
#1755130306
watch -n5 du -sh juliano/
#1755130323
watch -n5 du -sh *
#1755156225
cd Git/
#1755156228
cd athena/
#1755156229
ll
#1755156251
git commit -m 'pushing first version to repo'
#1755156421
mv athena athena-ori
#1755156432
git clone git@github.com:julas23/athena.git
#1755156435
mc
#1755156448
cd athena
#1755156452
git add .
#1755156460
git commit 'including folders'
#1755156466
git commit -m 'including folders'
#1755156468
git push
#1755156604
cd ..
#1755156609
rm -Rf athena-ori/
#1755156610
clear
#1755156615
mkdir iq-bot
#1755156618
cd iq-bot/
#1755156619
l
#1755156690
echo "# iq-bot" >> README.md
#1755156690
git init
#1755156690
git add README.md
#1755156690
git commit -m "first commit"
#1755156690
git branch -M main
#1755156690
git remote add origin git@github.com:julas23/iq-bot.git
#1755156690
git push -u origin main
#1755156894
cd 
#1755156899
nano .aliasrc 
#1755157035
proxmox
#1755157049
clear
#1755157148
cd .ssh
#1755157149
l
#1755157156
nano config 
#1755157222
cd ..
#1755157226
nano .aliasrc 
#1755157254
pfsense
#1755157266
proxmox
#1755157272
truenas
#1755157284
clear
#1755157367
zsh
#1755156899
nano .aliasrc 
#1755157035
proxmox
#1755157049
clear
#1755157148
cd .ssh
#1755157149
l
#1755157156
nano config 
#1755157222
cd ..
#1755157226
nano .aliasrc 
#1755157254
pfsense
#1755157266
proxmox
#1755157272
truenas
#1755157284
clear
#1755157367
zsh
#1755157545
cat /etc/shells
#1755157572
sudo chsh -s /bin/zsh juliano
#1755157581
which zsh
#1755157591
sudo chsh -s /run/current-system/sw/bin/zsh juliano
#1755158000
sudo nano /etc/nixos/modules/juliano.nix 
#1755158014
sudo cat /etc/nixos/modules/juliano.nix 
#1755158016
sudo nixos-rebuild switch
#1755158160
sudo chsh -s /run/current-system/sw/bin/zsh juliano
#1755158170
zsh
#1755158178
chsh -s /run/current-system/sw/bin/zsh juliano
#1755155125
curl  http://localhost:11434
#1755155138
curl http://localhost:11434/api/generate -d '{
  "model": "llama3:70b",
  "prompt": "Qual é a distância da Terra à Lua?",
  "stream": false
}'
#1755155323
go2 5
#1755158368
cd .config/i3/
#1755158368
l
#1755158371
nano config 
#1755158428
sudo systemctl restart display-manager.service
#1755203800
strings X-Bot-1.exe|grep -i "compiler\|language\|runtime"
#1755203825
strings X-Bot-1.exe | grep -i "compiler\|runtime\|python\|java\|.net"
#1755203832
file X-Bot-1.exe 
#1755203842
ldd X-Bot-1.exe 
#1755203848
xxd X-Bot-1.exe 
#1755203928
diec X-Bot-1.exe
ln -s /mnt/jas/juliano/.aliasrc .aliasrc
ll
rm .bashrc .bash_history .bash_logout 
ln -s /mnt/jas/juliano/.bashrc .bashrc
ln -s /mnt/jas/juliano/.bash_history .bash_history
ln -s /mnt/jas/juliano/.bash_logout .bash_logout
ll
ln -s /mnt/jas/juliano/.zshrc .zshrc
ln -s /mnt/jas/juliano/.zsh_history .zsh_history
ll
clear
ll
ln -s /mnt/jas/juliano/.XCompose .XCompose
ln -s /mnt/jas/juliano/.bitwarden-ssh-agent.sock .bitwarden-ssh-agent.sock
ln -s /mnt/jas/juliano/.gitconfig .gitconfig
ln -s /mnt/jas/juliano/Git/ Git
ln -s /mnt/jas/juliano/.psql_history .psql_history
ln -s /mnt/jas/juliano/.todo .todo
ll
rm -Rf Documents/ Downloads/ Desktop/ Music/ Videos/ Public/ Templates/ Videos/
ln -s /mnt/jas/juliano/Desktop Desktop
ln -s /mnt/jas/juliano/Documents Documents
ln -s /mnt/jas/juliano/Downloads Downloads
ln -s /mnt/jas/juliano/Music Music
ln -s /mnt/jas/juliano/Video Video
ln -s /mnt/jas/juliano/Videos Videos
rm -Rf Pictures/
ln -s /mnt/jas/juliano/Pictures Pictures
rm -Rf Desktop/
ln -s /mnt/jas/juliano/Desktop Desktop
ln -s /mnt/jas/juliano/Public Public
ln -s /mnt/jas/juliano/Templates Templates
clear
ll
clear
ls
rm -Rf Desktop/
ls
mc
#1755158371
nano config 
#1755158428
sudo systemctl restart display-manager.service
#1755203800
strings X-Bot-1.exe|grep -i "compiler\|language\|runtime"
#1755203825
strings X-Bot-1.exe | grep -i "compiler\|runtime\|python\|java\|.net"
#1755203832
file X-Bot-1.exe 
#1755203842
ldd X-Bot-1.exe 
#1755203848
xxd X-Bot-1.exe 
#1755203928
diec X-Bot-1.exe
#1755504956
ln -s /mnt/jas/juliano/.aliasrc .aliasrc
#1755504956
rm .bashrc .bash_history .bash_logout 
#1755504956
ln -s /mnt/jas/juliano/.bashrc .bashrc
#1755504956
ln -s /mnt/jas/juliano/.bash_history .bash_history
#1755504956
ln -s /mnt/jas/juliano/.bash_logout .bash_logout
#1755504956
ln -s /mnt/jas/juliano/.zshrc .zshrc
#1755504956
ln -s /mnt/jas/juliano/.zsh_history .zsh_history
#1755504956
ln -s /mnt/jas/juliano/.XCompose .XCompose
#1755504956
ln -s /mnt/jas/juliano/.bitwarden-ssh-agent.sock .bitwarden-ssh-agent.sock
#1755504956
ln -s /mnt/jas/juliano/.gitconfig .gitconfig
#1755504956
ln -s /mnt/jas/juliano/Git/ Git
#1755504956
ln -s /mnt/jas/juliano/.psql_history .psql_history
#1755504956
ln -s /mnt/jas/juliano/.todo .todo
#1755504956
rm -Rf Documents/ Downloads/ Desktop/ Music/ Videos/ Public/ Templates/ Videos/
#1755504956
ln -s /mnt/jas/juliano/Desktop Desktop
#1755504956
ln -s /mnt/jas/juliano/Documents Documents
#1755504956
ln -s /mnt/jas/juliano/Downloads Downloads
#1755504956
ln -s /mnt/jas/juliano/Music Music
#1755504956
ln -s /mnt/jas/juliano/Video Video
#1755504956
ln -s /mnt/jas/juliano/Videos Videos
#1755504956
rm -Rf Pictures/
#1755504956
ln -s /mnt/jas/juliano/Pictures Pictures
#1755504956
rm -Rf Desktop/
#1755504956
ln -s /mnt/jas/juliano/Desktop Desktop
#1755504956
ln -s /mnt/jas/juliano/Public Public
#1755504956
ln -s /mnt/jas/juliano/Templates Templates
#1755504956
rm -Rf Desktop/
#1755504956
mc
#1755505041
cd .cache
#1755505064
ln -s /mnt/jas/juliano/.cache/chromium chromium
#1755505074
ln -s /mnt/jas/juliano/.cache/wavebox wavebox
#1755505089
ln -s /mnt/jas/juliano/.cache/eww eww
#1755505111
ln -s /mnt/jas/juliano/.cache/sublime-text sublime-text
#1755505115
cd .config
#1755505155
ln -s /mnt/jas/juliano/.config/cava cava
#1755505165
ln -s /mnt/jas/juliano/.config/alacritty alacritty
#1755505177
ln -s /mnt/jas/juliano/.config/Bitwarden Bitwarden
#1755505190
ln -s /mnt/jas/juliano/.config/hypr hypr
#1755505213
ln -s /mnt/jas/juliano/.config/Simplenote Simplenote
#1755505252
ln -s /mnt/jas/juliano/.config/neofetch neofetch
#1755505267
ln -s /mnt/jas/juliano/.config/openrazer openrazer
#1755505287
ln -s /mnt/jas/juliano/.config/polychromatic polychromatic
#1755505306
ln -s /mnt/jas/juliano/.config/razergenie razergenie
#1755505322
ln -s /mnt/jas/juliano/.config/sublime-text sublime-text
#1755505332
ln -s /mnt/jas/juliano/.config/strawberry strawberry
#1755505343
ln -s /mnt/jas/juliano/.config/systemd systemd
#1755505389
ln -s /mnt/jas/juliano/.config/torbrowser torbrowser
#1755505394
ln -s /mnt/jas/juliano/.config/chromium chromium
#1755505398
ln -s /mnt/jas/juliano/.config/wavebox wavebox
#1755505454
ln -s /mnt/jas/juliano/.data .data
#1755505458
ln -s /mnt/jas/juliano/.ssh .ssh
#1755505465
ln -s /mnt/jas/juliano/.fonts .fonts
#1755505478
ln -s /mnt/jas/juliano/.icons .icons
#1755505486
ln -s /mnt/jas/juliano/.wallpaper .wallpaper
#1755505499
ln -s /mnt/jas/juliano/.tor\ project/ .tor\ project/
#1755505521
ln -s /mnt/jas/juliano/'.tor project' '.tor project'
#1755505545
ln -s /mnt/jas/juliano/.thunderbird .thunderbird
#1755505565
ln -s /mnt/jas/juliano/.oh-my-zsh .oh-my-zsh
#1755505571
ln -s /mnt/jas/juliano/.ollama .ollama
#1755505588
ln -s /mnt/jas/juliano/.mozilla .mozilla
#1755505603
cd .local/sh
#1755505605
cd .local/share/
#1755505611
mkdir Steam
#1755505727
cd Steam/
#1755505729
ls
#1755505745
mkdir steamapps userdata
#1755505763
cd steamapps/
#1755505766
mkdir compatdata
#1755505770
cd compatdata/
#1755505781
rm -Rf compatdata/
#1755505805
ln -s /mnt/jas/juliano/.local/share/Steam/steamapps/compatdata compatdata
#1755505811
cd userdata/
#1755505811
l
#1755505820
rm -Rf userdata/
#1755505835
ln -s /mnt/jas/juliano/.local/share/Steam/userdata userdata
#1755505858
ln -s /mnt/jas/juliano/.local/share/DBeaverData DBeaverData
#1755505868
ln -s /mnt/jas/juliano/.local/share/hyprland hyprland
#1755505877
ln -s /mnt/jas/juliano/.local/share/openrazer openrazer
#1755505889
ln -s /mnt/jas/juliano/.local/share/strawberry strawberry
#1755505897
ln -s /mnt/jas/juliano/.local/share/systemd systemd
#1755505905
ln -s /mnt/jas/juliano/.local/share/torbrowser torbrowser
#1755505910
cd ..
#1755505911
clear
#1755505912
ll
#1755505670
OA
#1755505611
mkdir Steam
#1755505727
cd Steam/
#1755505729
ls
#1755505745
mkdir steamapps userdata
#1755505763
cd steamapps/
#1755505766
mkdir compatdata
#1755505770
cd compatdata/
#1755505781
rm -Rf compatdata/
#1755505805
ln -s /mnt/jas/juliano/.local/share/Steam/steamapps/compatdata compatdata
#1755505811
cd userdata/
#1755505820
rm -Rf userdata/
#1755505835
ln -s /mnt/jas/juliano/.local/share/Steam/userdata userdata
#1755505858
ln -s /mnt/jas/juliano/.local/share/DBeaverData DBeaverData
#1755505868
ln -s /mnt/jas/juliano/.local/share/hyprland hyprland
#1755505877
ln -s /mnt/jas/juliano/.local/share/openrazer openrazer
#1755505889
ln -s /mnt/jas/juliano/.local/share/strawberry strawberry
#1755505897
ln -s /mnt/jas/juliano/.local/share/systemd systemd
#1755505905
ln -s /mnt/jas/juliano/.local/share/torbrowser torbrowser
#1755505910
cd ..
#1755505670
OA
#1755506112
cd .thunderbird
#1755506137
sudo groupmod -g 369 juliano
#1755506155
sudo chown juliano:juliano /home/juliano/ -R
#1755506167
sudo chown juliano:juliano * -R
#1755506199
cat ~/Git/nixos/etc/nixos/modules/juliano.nix 
#1755506222
sudo usermod -G plugdev juliano
#1755506234
sudo usermod -G lp juliano
#1755506238
sudo usermod -G scanner juliano
#1755506243
sudo usermod -G input juliano
#1755506248
sudo usermod -G wheel juliano
#1755506253
sudo usermod -G root juliano
#1755506261
sudo usermod -G openrazer juliano
#1755506274
id juliano
#1755506294
sudo nano /etc/passwd
#1755506360
sudo su
#1755506363
l
#1755506384
cat profiles.ini 
#1755506398
mc
#1755506450
cat installs.ini 
#1755506460
nano installs.ini 
#1755506469
nano profiles.ini 
#1755506563
rm -Rf *
#1755506564
clear
#1755506687
ll
#1755506563
rm -Rf *
#1755506687
ll
#1755508252
xdg-user-dirs-update 
#1755508271
xdg-user-dirs-gtk-update 
#1755508279
cd .config
#1755508309
clear
#1755508510
nano user-dirs.dirs 
#1755508535
xdg-user-dirs-update
#1755508541
xdg-user-dirs-gtk-update
#1755508565
cd .config
#1755508567
nano user-dirs.dirs 
#1755508592
xdg-user-dirs-update
#1755508593
xdg-user-dirs-gtk-update
#1755509809
xdg-user-dirs-update
#1755509810
xdg-user-dirs-gtk-update
#1755511279
xdg-user-dirs-update
#1755511280
xdg-user-dirs-gtk-update
ll
ls -lash
cd .cargo/
ls
cd bin/
l
ls
clear
echo $PATH
export PATH=/home/juliano/.cargo/bin/:$PATH
eza
cd ..
clear
eza
cd ..
clear
eza
eza -l
ls
cd Downloads/
ls
cd nixos/
clear
lsblk
clear
lsblk
sudo mount /dev/sda1 /mnt
sudo systemctl daemon-reload
sudo mount /dev/sda1 /mnt
clear
whoami
sudo su
#1763309492
ls
#1763309492
echo $PATH
#1763309492
export PATH=/home/juliano/.cargo/bin/:$PATH
#1763309492
eza
#1763309492
eza
#1763309492
eza
#1763309492
eza -l
#1763309492
ls
#1763309492
cd Downloads/
#1763309492
ls
#1763309492
cd nixos/
#1763309492
lsblk
#1763309492
lsblk
#1763309492
sudo mount /dev/sda1 /mnt
#1763309492
sudo systemctl daemon-reload
#1763309492
sudo mount /dev/sda1 /mnt
#1763309492
whoami
#1763309503
sudo su
#1763310408
cd
#1763310431
cd home/
#1763310433
cd juliano/
#1763310435
ll
#1763310465
git commit -m  'including bash and zsh files'
#1763310926
zsh
#1763311444
export QT_QPA_PLATFORM=xcb
#1763311515
git add .
#1763311528
git commit -m  'bash and zsh files
#1763311532
git commit -m  'bash and zsh files' 
#1763311547
cd .ssh
#1763311547
l
#1763311564
chmod 400 ryzen id_rsa key.pem 
#1763311569
sudo chmod 400 ryzen id_rsa key.pem 
#1763311570
clear
#1763311571
cd ..
#1763311574
cd Downloads/nixos/
#1763311577
git push
#1763311571
cd ..
#1763311658
cd Downloads/nixos/
#1763311666
export QT_QPA_PLATFORM=xcb
#1763311668
git push
#1763311532
git commit -m  'bash and zsh files' 
#1763311547
cd .ssh
#1763311547
l
#1763311564
chmod 400 ryzen id_rsa key.pem 
#1763311569
sudo chmod 400 ryzen id_rsa key.pem 
#1763311571
cd ..
#1763311571
cd ..
#1763311688
cd Downloads/nixos/
#1763311750
export QT_QPA_PLATFORM=xcb
#1763311766
ssh -T git@github.com
#1763311780
ll /home/juliano/.ssh/config 
#1763311784
ll /home/juliano/.ssh/
#1763311806
sudo chown juliano:juliano ~/.ssh/*
#1763311845
sudo chown juliano:juliano ~/.ssh/vps-hostinger
#1763311869
sudo chmod 400 ~/.ssh/vps-hostinger
#1763311875
sudo chmod 400 ~/.ssh/config
#1763311880
sudo chmod 400 ~/.ssh/key.pem 
#1763311885
sudo chmod 400 ~/.ssh/ryzen
#1763311889
sudo chmod 400 ~/.ssh/id_rsa
#1763311893
ls -lash /home/juliano/.ssh/
#1763311902
clear
#1763311904
cleargit push
#1763311907
git push
#1763311569
sudo chmod 400 ryzen id_rsa key.pem 
#1763311532
git commit -m  'bash and zsh files' 
#1763311547
l
#1763311564
chmod 400 ryzen id_rsa key.pem 
#1763311569
sudo chmod 400 ryzen id_rsa key.pem 
#1763311780
ll /home/juliano/.ssh/config 
#1763311784
ll /home/juliano/.ssh/
#1763311806
sudo chown juliano:juliano ~/.ssh/*
#1763311845
sudo chown juliano:juliano ~/.ssh/vps-hostinger
#1763311869
sudo chmod 400 ~/.ssh/vps-hostinger
#1763311875
sudo chmod 400 ~/.ssh/config
#1763311880
sudo chmod 400 ~/.ssh/key.pem 
#1763311885
sudo chmod 400 ~/.ssh/ryzen
#1763311889
sudo chmod 400 ~/.ssh/id_rsa
#1763311893
ls -lash /home/juliano/.ssh/
#1763311904
cleargit push
#1763312716
export QT_QPA_PLATFORM=xcb
#1763312747
GIT_TRACE=1
#1763312801
GIT_SSH_COMMAND="ssh -vvv" git push
#1763312833
cd
#1763312895
nano config 
#1763312976
pkill ssh-agent
#1763312999
eval "$(ssh-agent -s)"
#1763313013
ssh-add ~/.ssh/ryzen
#1763313016
ssh-add -l
#1763313135
nano ~/.ssh/config 
#1763313146
ssh -T git@github.com
#1763313173
cd 
#1763313174
cd .ssh
#1763313207
sudo chmod 400 ryzen.pub vps-hostinger.pub id_rsa.pub cert.pem  
#1763313208
clear
#1763313208
ll
#1763313223
cd ..
#1763313225
cd Downloads/nixos/
#1763313228
git push
#1763311845
sudo chown juliano:juliano ~/.ssh/vps-hostinger
#1763311869
sudo chmod 400 ~/.ssh/vps-hostinger
#1763311875
sudo chmod 400 ~/.ssh/config
#1763311880
sudo chmod 400 ~/.ssh/key.pem 
#1763311885
sudo chmod 400 ~/.ssh/ryzen
#1763311889
sudo chmod 400 ~/.ssh/id_rsa
#1763311893
ls -lash /home/juliano/.ssh/
#1763311904
cleargit push
#1763311921
cd Downloads/nixos/
#1763311927
export QT_QPA_PLATFORM=xcb
#1763311948
pkill ssh-agent
#1763311958
ssh -T git#github.com
#1763311963
ssh -T git@github.com
#1763311994
GIT_SSH_COMMAND="ssh -v" git push
#1763312157
eval "$(ssh-agent -s)"
#1763312178
ssh-add ~/.ssh/ryzen
#1763312181
ssh-add -l
#1763312190
git push -v
#1763312364
cd
#1763312365
ls -lash
#1763312371
cat .gitconfig 
#1763312374
cd .ssh
#1763312376
cat config 
#1763312403
sudo chmod 600 config
#1763312405
nano config 
#1763312422
cd ../Downloads/nixos/
#1763312445
cd ..
#1763312451
mv nixos/ ori-nixos
#1763312464
git clone https://github.com/julas23/nixos
#1763312477
mc
#1763312503
cd nixos
#1763312507
git add .
#1763312522
git commit -m  'included bash and zsh files'
#1763312525
git push
#1763312590
nano ../../.ssh/
#1763312595
nano ../../.ssh/config 
#1763312671
clear
#1763312699
while true; do sudo ss -tunp |grep :22; sleep 2; done
#1763312595
nano ../../.ssh/config 
#1763312699
while true; do sudo ss -tunp |grep :22; sleep 2; done
#1763313388
cd .ssh
#1763313392
cat config 
#1763313396
cat ryzen
#1763313413
clear
#1763313439
cat ryzen.pub 
