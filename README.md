Penggunaan script

1. Buat Folder /var/lib/xtrabackup/

mkdir /var/lib/xtrabackup/

2. Install mysql

wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm

rpm -ivh mysql-community-release-el7-11.noarch.rpm

yum install mysql-server mysql

3. Install qpress

wget http://www.quicklz.com/qpress-11-linux-x64.tar

tar xf qpress-11-linux-x64.tar

cp qpress  /usr/bin/qpress

chmod 755  /usr/bin/qpress

chown root:root /usr/bin/qpress

4. Membuat folder /opt/script

mkdir /opt/script/

5. Copy dan paste script lalu ditempatkan di folder /opt/script/

cp xtrabackupnewrev2.sh /opt/script/

cp fullbackup.sh /opt/script/

cp incrementalbackupnew.sh /opt/script/

cp extract.sh /opt/script/


6. Edit file xtrabackupnewrev2.sh ubah user dan password sesuai yang digunakan di mysql

USER_ARGS=" --user=user_mysql --password=password_mysql"

Sebelumnya buat folder tempat penyimpanan semua file xtrabackup di /var/lib/all_xtrabackup/ di server storage

mkdir /var/lib/all_xtrabackup/

7. Untuk menjalankan fullbackup jalankan script dibawah ini :

/bin/sh /opt/script/fullbackup.sh

8. Kemudian lakukan proses incremental backup dengan menjalankan script dibawah ini :

/bin/sh /opt/script/incrementalbackupnew.sh

9. Proses Restore

Pastikan service mysql sudah di install dan distop.

Backup folder mysql yang sudah exsisting.

Buka folder /var/lib/all_xtrabackup/ pilih dan copy file backup sesuai dengan tanggal yang dibutuhkan.

cp -r /var/lib/all_xtrabackup/FULL/xxxxxxxx-FULL.bz2 /var/lib/xtrabackup/

cp -r /var/lib/all_xtrabackup/INC/xxxxxxxx_incx.bz2 /var/lib/xtrabackup/

cp -r /var/lib/all_xtrabackup/log/xxxxxxxx_last_incremental_number /var/lib/xtrabackup/


extract file fullbackup dan incrementalbackup, last_incremental_number dan pindahkan ke folder /var/lib/xtrabackup/

Jalankan proses restore

/bin/sh /opt/script/xtrabackupnewrev1.sh restore



-----------------------------------------------------------------------------------------------------------------




Incremental Backup Mysql menggunakan Percona Xtrabackup


1. Persiapan

1.1 Install mysql versi 5.7

wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm

rpm -ivh mysql-community-release-el7-11.noarch.rpm

yum install mysql-server mysql

1.2 Aktifkan service mysql

systemctl start mysqld

Sebelum melakukan login di mysql silahkan cek password temporary dengan perintah berikut :

grep 'temporary password' /var/log/mysqld.log

Lakukan login ke mysql

mysql -u root -p
password : (masukan password yang ada di temporary password)

Ubah rules dari password mysql

Cek rules password :

mysql > show variables like 'validate_password%'

Ubah validate password policy
mysql > set global validate_password_policy = LOW;

Kemudian ubah password temporary tersebut sesuai dengan kebutuhan

mysql > alter user 'root'@'localhost' IDENTIFIED by 'isi_password_baru';

Selanjutnya coba buat database, table dan isi data di table yang sebelumnya dibuat.

1.3 Install Percona xtrabackup

wget http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm

rpm -ivH percona-release-0.1-4.noarch.rpm

yum install percona-xtrabackup-24 -y

1.4 Install qpress

wget http://www.quicklz.com/qpress-11-linux-x64.tar

tar xf qpress-11-linux-x64.tar

cp qpress  /usr/bin/qpress

chmod 755  /usr/bin/qpress

chown root:root /usr/bin/qpress

2. Proses Backup dengan Percona

2.1 Membuat Fullbackup
innobackupex --user=user_mysql --password='password_mysql' --no-timestamp $folder_tujuan_untuk_menyimpan_hasil_fullbackup

* --no-timestamp = untuk menonaktifkan fitur pembuatan folder dalam format date

contoh :

innobackupex --user=root --password='12345Sh' --no-timestamp /data/backup/full

2.2 Membuat incremental backup 1

innobackupex --user=user_mysql --password='password_mysql' --no-timestamp --incremental $folder_tujuan_untuk_menyimpan_hasil_incremental_1 --incremental-basedir=$folder_tempat_menyimpan_fullbackup

* --no-timestamp = perintah untuk menonaktifkan fitur pembuatan folder dalam format date
* --incremental = perintah untuk melakukan incremental
* --incremental-basedir = perintah untuk sebagai acuan posisi binlog terakhir
contoh :

innobackupex --user=root --password='12345Sh' --no-timestamp --incremental /data/backup/inc1 --incremental-basedir=/data/backup/full

2.3 Membuat incremental backup 2

innobackupex --user=user_mysql --password='password_mysql' --no-timestamp --incremental $folder_tujuan_untuk_menyimpan_hasil_incremental_2 --incremental-basedir=$folder_tempat_menyimpan_incremental_1

contoh :

innobackupex --user=root --password='12345Sh' --no-timestamp --incremental /data/backup/inc2 --incremental-basedir=/data/backup/inc1

............................................................................................

2.4 Membuat incremental backup n+1

innobackupex --user=user_mysql --password='password_mysql' --no-timestamp --incremental $folder_tujuan_untuk_menyimpan_hasil_incremental(n+1) --incremental-basedir=$folder_tempat_menyimpan_incremental(n-1)

innobackupex --user=root --password='12345Sh' --no-timestamp --incremental /data/backup/inc(n+1) --incremental-basedir=/data/backup/inc(n-1)


- persiapan full backup

innobackupex --user=user_mysql --password='password_mysql' --apply-log --redo-only $dir_fullbackup

contoh :

innobackupex --user=root --password='12345Sh' --apply-log --redo-only /data/backup/full

* --apply-log = perintah untuk membaca konfigurasi innodb yang ada di file backup-my.cnf
* --redo-only = perintah untuk menggabungkan posisi awal dan terakhir bin log

- persiapan incremental backup 1

innobackupex --user=user_mysql --password='password_mysql' --apply-log --redo-only $dir_fullbackup --incremental-dir=$dir_incremental_1

contoh :

innobackupex --user=root --password='12345Sh' --apply-log --redo-only /data/backup/full --incremental-dir=/data/backup/inc1

* --apply-log = perintah untuk membaca konfigurasi innodb yang ada di file backup-my.cnf
* --redo-only = perintah untuk menggabungkan posisi awal dan terakhir bin log

- persiapan incremental backup 2

innobackupex --user=user_mysql --password='password_mysql' --apply-log --redo-only $dir_fullbackup --incremental-dir=$dir_incremental_2

contoh :

innobackupex --user=root --password='12345Sh' --apply-log --redo-only /data/backup/full --incremental-dir=/data/backup/inc2

...........................................................................................................................

- persiapan incremental backup n+1

innobackupex --user=user_mysql --password='password_mysql' --apply-log --redo-only $dir_fullbackup  --incremental-dir=$dir_incremental_(n+1)

contoh :

innobackupex --user=root --password='12345Sh' --apply-log --redo-only /data/backup/full --incremental-dir=/data/backup/inc(n+1)


- Persiapan backup terakhir

innobackupex --user=user_mysql --password='password_mysql' --apply-log $dir_fullbackup

contoh :

innobackupex --user=root --password='12345Sh' --apply-log /data/backups/full/

* --apply-log = perintah untuk membaca konfigurasi innodb yang ada di file backup-my.cnf

- Proses restore

innobackupex --user=root --password='12345Sh' --copy-back $dir_fullbackup

contoh :

innobackupex --user=root --password='12345Sh' --copy-back /data/backups/full/

