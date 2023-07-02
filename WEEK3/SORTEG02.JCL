//SORTEG02 JOB ' ',CLASS=A,MSGLEVEL=(1,1),MSGCLASS=X,NOTIFY=&SYSUID
//DELET100 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE Z95609.QSAM.AA NONVSAM
  IF LASTCC LE 08 THEN SET MAXCC = 00
//SORT0200 EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//SORTIN   DD *
10002949LEONARDO       DI CAPRIO      19741111
10002840ROBERT         DE NIRO        19430817
10003978MICHAEL        JORDAN         19630217
10001949MEHMET         AYDIN          19740918
10001840LIONEL         MESSI          19870624
//SORTOUT  DD DSN=&SYSUID..QSAM.AA,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(5,5),RLSE),
//            DCB=(RECFM=FB,LRECL=60)
//* Olusturulan QSAM.AA dosyamizin her kaydinin 60 byte'lik
//* yeri var. Biz SYSIN kisminda 1'den 7'nci karaktere
//* kadar olan alandaki sayilara bakarak ve CH,A kullanarak
//* dosyadaki verilerin kopyalandiktan sonra sirali olacagini
//* soyluyoruz. OUTREC FIELDS kisminda verinin geri kalan 
//* kisimlarinin direkt kopyalanacagini, fakat 39. karakterden
//* itibaren yer alan degerin GREGORIAN tarih oldugunu ve bu
//* tarihin TOJUL ile JULIAN tarihe cevrilip o sekilde 
//* QSAM.AA dosyamiza yazilacagini belirtiyoruz. O zaman 
//* bu kisimda dosyamizda 1 byte bos alanimiz var. 15C'0'
//* kisminda ise her kaydin sonuna 15 adet char olarak '0'
//* karakteri ekliyoruz. Artik bir kaydimiz toplam 60
//* karakter oldu. Bu yuzden 18. satirda LRECL=60 yaptik.
//SYSIN    DD *
  SORT FIELDS=(1,7,CH,A)
  OUTREC FIELDS=(1,38,39,8,Y4T,TOJUL=Y4T,15C'0')
//DELET300 EXEC PGM=IEFBR14
//FILE01   DD DSN=&SYSUID..QSAM.BB,
//            DISP=(MOD,DELETE,DELETE),SPACE=(TRK,0)
//SORT0400 EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//SORTIN   DD DSN=&SYSUID..QSAM.AA,DISP=SHR
//SORTOUT  DD DSN=&SYSUID..QSAM.BB,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(5,5),RLSE),
//            DCB=(RECFM=FB,LRECL=47)
//* SYSIN kisminda QSAM.BB'nin QSAM.AA'dan aldigi verileri
//* kendisine kopyalayacagi kismi yapiyoruz. Fakat bu
//* kopyalama isleminde QSAM.BB dosyamizin byte'inin
//* QSAM.AA'nin byte'indan kucuk olmasini sagliyoruz.
//* SORT FIELDS=COPY ile verileri dumduz kopyaliyoruz.
//* Fakat OUTREC FIELDS her kaydin ilk 5 karakterinin
//* Zoned Decimal(ZD) formatindan Packed Decimal(PD)
//* formatina cevrilmesini ve boyutunun da 3'e dusurulmesini,
//* 6'inci satirdan baslayip 3 karakter ilerleyerek bu 
//* karakterlerin de ZD'den Binary(BI) formatina cevirerek
//* 3 bytelik veriyi BI tablosundan bilgi edinerek 2 byte'ta 
//* tutacagimizi soyluyoruz. 9'uncu karakterden 30'uncu
//* karaktere kadar dumduz char olarak kopyalayacagimizi,
//* geri kalan alanlari da kendi icinde ZD'den PD'ye 
//* cevirecegimizi, boyutlarini ise (Kendi Byte'i + 1 / 2)
//* COMP-3 hesaplama yöntemi ile belirliyoruz.
//* Artik dosyamizin bir record'u 60 byte'dan 47 byte'a 
//* inmis oldu.
//SYSIN    DD *
  SORT FIELDS=COPY
  OUTREC FIELDS=(1,5,ZD,TO=PD,LENGTH=3,
                   6,3,ZD,TO=BI,LENGTH=2,
                   9,30,
                   39,7,ZD,TO=PD,LENGTH=4,
                   46,15,ZD,TO=PD,LENGTH=8)
