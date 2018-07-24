for i in *.bz2; do
	tar -zxvf "$i" -C /var/lib/xtrabackup/
done
