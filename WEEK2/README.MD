Dosyaları sorunsuz çalıştırabilmeniz adına JCL
dosyasini düzenledim. Önceden var olması gereken 
dosyaların da oluşturulması olayını JCL'e ekledim.
Bu yüzden JCL biraz uzun gözüküyor.

1- JCL'de veri belirterek olusturdugumuz QSAM.GG 
dosyasinin olusumu var.

2- Daha sonra GG dosyasini okuyarak olusturdugumuz 
QSAM.HH dosyamız var. Bu dosya verilerin okundugu 
tarihi verilerin sonuna ekleyerek yeni bir dosya 
olarak olusuyor. Ayrıca verilerin ilk 4 karakterinde
yer alan ID'lere göre verileri sıralıyor.

3- Son adımda asıl COBOL ana programımız olan 'PBEG0005'
tetikleniyor ve cobol kaynak kodumuz sayesinde
QSAM.HH dosyasından okuma yapılıyor, okunan verilerde yer alan 
kisilerin dogum tarihine bakarak bugüne kadar yasadiklari 
gün sayısı hesaplanıyor. QSAM.HH dosyasindaki kayitlar yeni bir 
QSAM.JJ dosyasına tekrar yazdırılıyor ve sonlarına da hesaplanan 
'yaşanan gün sayısı' ekleniyor.
