# Jarkom-Modul-2-A16-2021
Lapres Praktikum Jarkom Modul 2  
kelompok A16 : Deka Julian Arrizki

## **Konten**
* [**Cara Pengerjaan**](#cara-pengerjaan)
* [**Kendala**](#kendala)

## Cara Pengerjaan
### Nomor 1
EniesLobby akan dijadikan sebagai DNS Master, Water7 akan dijadikan DNS Slave, dan Skypie akan digunakan sebagai Web Server. Terdapat 2 Client yaitu Loguetown, dan Alabasta. Semua node terhubung pada router Foosha, sehingga dapat mengakses internet  

**Konfigurasi Ip Address**
* Foosha
```
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
	address 10.7.1.1
	netmask 255.255.255.0

auto eth2
iface eth2 inet static
	address 10.7.2.1
	netmask 255.255.255.0
```
* Loguetown
```
auto eth0
iface eth0 inet static
	address 10.7.1.2
	netmask 255.255.255.0
	gateway 10.7.1.1
```
* Alabasta
```
auto eth0
iface eth0 inet static
	address 10.7.1.3
	netmask 255.255.255.0
	gateway 10.7.1.1
```
* Enieslobby
```
auto eth0
iface eth0 inet static
	address 10.7.2.2
	netmask 255.255.255.0
	gateway 10.7.2.1
```
* Water7
```
auto eth0
iface eth0 inet static
	address 10.7.2.3
	netmask 255.255.255.0
	gateway 10.7.2.1
```
* Skypie
```
auto eth0
iface eth0 inet static
	address 10.7.2.4
	netmask 255.255.255.0
	gateway 10.7.2.1
```
**Requirement di router**
* ketikkan perintah dibawah untuk dapat terhubung ke internet
```
apt-get update
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.7.0.0/16
```
**Requirement di client**
* install dnsutils dan lynx
```
apt-get update
apt-get install dnsutils -y
apt-get install lynx -y
```
* ubah nameserver kembali ke ip enieslobby pada ```/etc/resolv.conf```
```
nameserver 10.7.2.2
```
**Requirement di dns server**
* install bind9
```
apt-get update
apt-get install bind9 -y
```
* ubah nameserver ke foosha
```
nameserver 192.168.122.1 
```
**Requirement di web server**
* install beberapa tools yang akan dibutuhkan dalam pengerjaan soal
```
apt-get update
apt-get install php -y
apt-get install apache2 -y
apt-get install git -y
apt-get install unzip -y
apt-get install ca-certificates -y
apt-get install lynx -y
 apt-get install libapache2-mod-php7.0 -y
```
### Nomor 2
Luffy ingin menghubungi Franky yang berada di EniesLobby dengan denden mushi. Kalian diminta Luffy untuk membuat website utama dengan mengakses franky.yyy.com dengan alias www.franky.yyy.com pada folder kaizoku  
* buat dan buka file konfigurasi pada ```/etc/bind/named.conf.local```
```
zone "franky.A16.com" {
    type master;
    file "/etc/bind/kaizoku/franky.A16.com";
};
```
* buat dan buka folder ```/etc/bind/kaizoku/franky.A16.com```
```
mkdir /etc/bind/kaizoku
nano /etc/bind/kaizoku/franky.A16.com
```
* masukkan konfigurasi di bawah ini
```
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     franky.A16.com. root.franky.A16.com. (
                        2021102501      ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@                       IN      NS      franky.A16.com.
@                       IN      A       10.7.2.4        ; IP Skypie
www                     IN      CNAME   franky.A16.com.
```
### Nomor 3
Setelah itu buat subdomain super.franky.yyy.com dengan alias www.super.franky.yyy.com yang diatur DNS nya di EniesLobby dan mengarah ke Skypie
* tambahkan konfigurasi pada ```/etc/bind/kaizoku/franky.A16.com```
```
super                   IN      A       10.7.2.4        ; IP Skypie
www.super               IN      CNAME   franky.A16.com.
```
### Nomor 4
Buat juga reverse domain untuk domain utama  
* buka file ```/etc/bind/named.conf.local``` di enieslobby dan tambahkan konfigurasi seperti dibawah ini
```
zone "2.7.10.in-addr.arpa" {
    type master;
    file "/etc/bind/kaizoku/2.7.10.in-addr.arpa";
};
```
* buat dan buka file ```/etc/bind/kaizoku/2.7.10.in-addr.arpa``` kemudian isi dengan konfigurasi dibawah ini
```
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     franky.A16.com. root.franky.A16.com. (
                     2021102501         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
2.7.10.in-addr.arpa.    IN      NS      franky.A16.com.
2                       IN      PTR     franky.A16.com.
```
* testing
```
host -t PTR 10.7.2.2
```
### Nomor 5
Supaya tetap bisa menghubungi Franky jika server EniesLobby rusak, maka buat Water7 sebagai DNS Slave untuk domain utama  
* tambahkan konfigurasi pada ```/etc/bind/named.conf.local``` di enieslobby
```
zone "franky.A16.com" {
    type master;
    allow-transfer { 10.7.2.3; };
    file "/etc/bind/kaizoku/franky.A16.com";
};
```
* buat dan tambahkan konfigurasi pada ```/etc/bind/named.conf.local``` di Water7
```
zone "franky.A16.com" {
    type slave;
    masters { 10.7.2.2; };
    file "/var/lib/bind/franky.A16.com";
};
```
### Nomor 6
Setelah itu terdapat subdomain mecha.franky.yyy.com dengan alias www.mecha.franky.yyy.com yang didelegasikan dari EniesLobby ke Water7 dengan IP menuju ke Skypie dalam folder sunnygo  
* buka dan konfigurasi file ```/etc/bind/named.conf.options``` di enieslobby seperti konfigurasi dibawah ini
```
options {
	directory "/var/cache/bind";
        allow-query{any;};
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
```
* buka dan konfigurasi file ```/etc/bind/named.conf.options``` pada Water7
```
options {
        directory "/var/cache/bind";
        allow-query{any;};
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
```
* tambahkan konfigurasi pada ```/etc/bind/kaizoku/franky.A16.com``` di enieslobby
```
ns1                     IN      A       10.7.2.4        ; IP Skypie
mencha                  IN      NS      ns1
```
* buat dan tambahkan konfigurasi pada ```/etc/bind/sunnygo/mecha.franky.A16.com``` di Water7
```
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA  mecha.franky.A16.com. root.mecha.franky.A16.com. (
                     2021102501             ; Serial
                         604800             ; Refresh
                          86400             ; Retry
                        2419200             ; Expire
                         604800 )           ; Negative Cache TTL
;
@               IN      NS      mecha.franky.A16.com.
@               IN      A       10.7.2.4        ; IP Skypie
mecha           IN      A       10.7.2.4        ; IP Skypie
www             IN      CNAME   mecha.franky.A16.com.
```
* tambahkan konfigurasi pada ```/etc/bind/named.conf.local```
```
zone "mecha.franky.A16.com" {
    type master;
    file "/etc/bind/sunnygo/mecha.franky.A16.com";
};
```
### Nomor 7
Untuk memperlancar komunikasi Luffy dan rekannya, dibuatkan subdomain melalui Water7 dengan nama general.mecha.franky.yyy.com dengan alias www.general.mecha.franky.yyy.com yang mengarah ke Skypie  
* buka dan tambahkan konfigurasi pada ```/etc/bind/sunnygo/mecha.franky.A16.com``` di Water7
```
general         IN      A       10.7.2.4        ; IP Skypie
www.general     IN      CNAME   mecha.franky.A16.com.
```

### Nomor 8
Setelah melakukan konfigurasi server, maka dilakukan konfigurasi Webserver. Pertama dengan webserver www.franky.yyy.com. Pertama, luffy membutuhkan webserver dengan DocumentRoot pada /var/www/franky.yyy.com.  
* lakukan persiapan file dan folder yang akan diperlukan pada pengerjaan soal
```
git clone https://github.com/FeinardSlim/Praktikum-Modul-2-Jarkom.git /var/www/source
rm /var/www/source/README.md
unzip /var/www/source/franky.zip -d /var/www/source
unzip /var/www/source/general.mecha.franky.zip -d /var/www/source
unzip /var/www/source/super.franky.zip -d /var/www/source
mkdir /var/www/franky.A16.com
mkdir /var/www/super.franky.A16.com
mkdir /var/www/general.franky.A16.com
cp -r /var/www/source/franky/. /var/www/franky.A16.com
cp -r /var/www/source/super.franky/. /var/www/super.franky.A16.com
cp -r /var/www/source/general.mecha.franky/. /var/www/general.franky.A16.com
rm -r /var/www/source
```
* buat dan tambahkan konfigurasi pada ```/etc/apache2/sites-available/000-default.conf``` di Skypie
```
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/franky.A16.com
        ServerName www.franky.A16.com
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
### Nomor 9
Setelah itu, Luffy juga membutuhkan agar url www.franky.yyy.com/index.php/home dapat menjadi menjadi www.franky.yyy.com/home.  
* tambahkan konfigurasi pada ```/etc/apache2/sites-available/000-default.conf``` di Skypie
```
        Alias "/home" "/var/www/franky.A16.com/index.php/home"
```
### Nomor 10
Setelah itu, pada subdomain www.super.franky.yyy.com, Luffy membutuhkan penyimpanan aset yang memiliki DocumentRoot pada /var/www/super.franky.yyy.com 
* tambahkan konfigurasi pada ```/etc/apache2/sites-available/000-default.conf``` di Skypie
```
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/super.franky.A16.com
        ServerName www.super.franky.A16.com
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
```
### Nomor 11
Akan tetapi, pada folder /public, Luffy ingin hanya dapat melakukan directory listing saja  
* tambahkan konfigurasi pada ```/etc/apache2/sites-available/000-default.conf``` di Skypie
```
        <Directory /var/www/super.franky.A16.com/public>
        	Options +Indexes
        </Directory>

        <Directory /var/www/super.franky.A16.com/public/css/*>
                Options -Indexes
        </Directory>

        <Directory /var/www/super.franky.A16.com/public/js/*>
                Options -Indexes
        </Directory>
```
### Nomor 12
Tidak hanya itu, Luffy juga menyiapkan error file 404.html pada folder /error untuk mengganti error kode pada apache  
* tambahkan konfigurasi pada ```/etc/apache2/sites-available/000-default.conf``` di Skypie
```
	<Directory /var/www/super.franky.A16.com>
                Options +FollowSymLinks -Multiviews
                AllowOverride All
        </Directory>
```
* kemudian buat file .htaccess pada ```/var/www/super.franky.A16.com``` dan isi dengan konfigurasi berikut
```
ErrorDocument 404 /error/404.html
```
### Nomor 13
Luffy juga meminta Nami untuk dibuatkan konfigurasi virtual host. Virtual host ini bertujuan untuk dapat mengakses file asset www.super.franky.yyy.com/public/js menjadi www.super.franky.yyy.com/js.  
* tambahkan konfigurasi pada ```/etc/apache2/sites-available/000-default.conf``` di Skypie
```
	Alias "/js" "/var/www/super.franky.A16.com/public/js" 
```
### Nomor 14
Dan Luffy meminta untuk web www.general.mecha.franky.yyy.com hanya bisa diakses dengan port 15000 dan port 15500  
* tambahkan konfigurasi pada ```/etc/apache2/sites-available/000-default.conf``` di Skypie
```
<VirtualHost *:15000 *:15500>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/general.franky.A16.com
        ServerName www.general.mecha.franky.A16.com
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
```
* aktifkan port 15000 dan 15500 pada ```/etc/apache2/ports.conf``` dan tambahkan konfigurasi berikut
```
Listen 15000
Listen 15500
```
### Nomor 15
dengan autentikasi username luffy dan password onepiece dan file di /var/www/general.mecha.franky.yyy  
### Nomor 16
Dan setiap kali mengakses IP Skypie akan dialihkan secara otomatis ke www.franky.yyy.com  
### Nomor 17
Dikarenakan Franky juga ingin mengajak temannya untuk dapat menghubunginya melalui website www.super.franky.yyy.com, dan dikarenakan pengunjung web server pasti akan bingung dengan randomnya images yang ada, maka Franky juga meminta untuk mengganti request gambar yang memiliki substring “franky” akan diarahkan menuju franky.png. Maka bantulah Luffy untuk membuat konfigurasi dns dan web server ini!  
## Kendala
