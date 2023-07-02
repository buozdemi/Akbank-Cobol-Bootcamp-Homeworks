//SORTREPR JOB ' ',CLASS=A,MSGLEVEL=(1,1),
//          MSGCLASS=X,NOTIFY=&SYSUID
//DELET100 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN DD *
   DELETE Z95609.QSAM.AA NONVSAM
   IF LASTCC LE 08 THEN SET MAXCC = 00
//DELET500 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//* Bu bolumde olusturacagimiz isimde bir dosya daha once 
//* olusturulduysa onu silerek basliyoruz. Dosya yok ise 
//* DELETE silme islemi JCL'e hata kodu yazacagindan dolayi
//* bu durumu es gecmek icin LASTCC'nin 8 den kucuk oldugu
//* durumda MAXCC'yi 00'a cektik. DEF CL ile yeni clusterin
//* ismini belirledik. FREESPACE ile kontrol alanimizin
//* %20'si kadar daha fazla alan ayiracagimizi soyluyoruz. 
//* Bu sayede RESERVED ile ayni mantigi JCL'de yapmis olduk. 
//* Verilerimizin islenme performansini arttirdik. SHR ile 
//* VSAM'in okuma ve yazma izinlerini actik. RECSZ ile her 
//* record'un uzunlugunu soyleyerek fixed oldugunu belirtmis 
//* olduk. TRK ile diskimizde 10'luk 10'luk yer acacagimizi,
//* LOG(NONE) ile gunluk kayit tutmayacagimizi, VOLUMES ile
//* hangi diskimizi kullanacagimizi, KEYS ile recordumuzun
//* ilk 5 karakterinin bizim icin bir KEY olacagini, UNIQUE
//* ile ayni KEY degerinin birden fazla oldugu durumda 
//* yalnizca ilkinin VSAM dosyasina alinacagini belirttik.
//* DATA ve INDEX kisimlarinda cluster'imizin gerekli 
//* values ve attributes'lerini tutuyoruz. Alt kisimda ise
//* INN001 ile belirledigimiz programimizin icindekileri 
//* OUT001 ile belirledigimiz out dosyamizin icine 
//* kopyalama islemimizi gerceklestiriyoruz.
//SYSIN DD *
    DELETE Z95609.VSAM.AA CLUSTER PURGE
    IF LASTCC LE 08 THEN SET MAXCC = 00
        DEF CL ( NAME(Z95609.VSAM.AA)         -
                FREESPACE( 20 20 )            -
                SHR( 2,3 )                    -
                KEYS(5 0)                     -
                INDEXED SPEED                 -
                RECSZ(47 47)                  -
                TRK (10 10)                   -
                LOG(NONE)                     -
                VOLUMES (VPWRKB)              -
                UNIQUE )                      -
        DATA ( NAME(Z95609.VSAM.AA.DATA))     -
        INDEX ( NAME(Z95609.VSAM.AA.INDEX))
//REPRO600 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//INN001 DD DSN=Z95609.QSAM.BB,DISP=SHR
//OUT001 DD DSN=Z95609.VSAM.AA,DISP=SHR
//SYSIN DD *
    REPRO INFILE(INN001) OUTFILE(OUT001)