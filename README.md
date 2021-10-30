# Jarkom-Modul-2-A16-2021
Lapres Praktikum Jarkom Modul 2

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
	address [Prefix IP].1.2
	netmask 255.255.255.0
	gateway [Prefix IP].1.1
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
### Nomor 7
Untuk memperlancar komunikasi Luffy dan rekannya, dibuatkan subdomain melalui Water7 dengan nama general.mecha.franky.yyy.com dengan alias www.general.mecha.franky.yyy.com yang mengarah ke Skypie  
### Nomor 8
Setelah melakukan konfigurasi server, maka dilakukan konfigurasi Webserver. Pertama dengan webserver www.franky.yyy.com. Pertama, luffy membutuhkan webserver dengan DocumentRoot pada /var/www/franky.yyy.com.  
### Nomor 9
Setelah itu, Luffy juga membutuhkan agar url www.franky.yyy.com/index.php/home dapat menjadi menjadi www.franky.yyy.com/home.  
### Nomor 10
Setelah itu, pada subdomain www.super.franky.yyy.com, Luffy membutuhkan penyimpanan aset yang memiliki DocumentRoot pada /var/www/super.franky.yyy.com  
### Nomor 11
Akan tetapi, pada folder /public, Luffy ingin hanya dapat melakukan directory listing saja  
### Nomor 12
Tidak hanya itu, Luffy juga menyiapkan error file 404.html pada folder /error untuk mengganti error kode pada apache  
### Nomor 13
Luffy juga meminta Nami untuk dibuatkan konfigurasi virtual host. Virtual host ini bertujuan untuk dapat mengakses file asset www.super.franky.yyy.com/public/js menjadi www.super.franky.yyy.com/js.  
### Nomor 14
Dan Luffy meminta untuk web www.general.mecha.franky.yyy.com hanya bisa diakses dengan port 15000 dan port 15500  
### Nomor 15
dengan autentikasi username luffy dan password onepiece dan file di /var/www/general.mecha.franky.yyy  
### Nomor 16
Dan setiap kali mengakses IP Skypie akan dialihkan secara otomatis ke www.franky.yyy.com  
### Nomor 17
Dikarenakan Franky juga ingin mengajak temannya untuk dapat menghubunginya melalui website www.super.franky.yyy.com, dan dikarenakan pengunjung web server pasti akan bingung dengan randomnya images yang ada, maka Franky juga meminta untuk mengganti request gambar yang memiliki substring “franky” akan diarahkan menuju franky.png. Maka bantulah Luffy untuk membuat konfigurasi dns dan web server ini!  
## Kendala
