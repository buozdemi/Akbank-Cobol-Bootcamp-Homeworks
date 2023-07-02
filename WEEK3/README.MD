1 - Öncelikle input dosyamız olan 'Z95609.QSAM.INP'yi olustumak icin 'SORTEG03.JCL' dosyasını submit edelim.

2 - Sonrasında icinde veriler olan 'Z95609.QSAM.BB' isimli dosyamizi olusturan 'SORTEG02.JCL' dosyasını submit edelim. (Bu dosya önce 
'Z95609.QSAM.AA' isimli dosyayı olusturur, sonrasında ise bu dosyanın 
degişkenlerinin byte'larını 'Binary Coded Decimal'a çevirerek 
daha küçük boyutlu (yine aynı verilerden oluşan) 'Z95609.QSAM.BB' dosyasını yaratır.)

3 - Şimdi ise 'DELDEF01.JCL' dosyamızı submit edelim. Bu dosyada calistiginde ise 'Z95609.QSAM.BB'daki tüm veriler alınarak bir Cluster olan 'Z95609.VSAM.AA' dosyasi olusturulup icine yazılır.

4 - Artık PBEG105.JCL dosyamizi submit edebiliriz. 
(PBEG105 programımız 'Z95609.QSAM.INP' ve 'Z95609.VSAM.AA' dosyalarını kullanacağı için yukarıda önce onları olusturduk.)