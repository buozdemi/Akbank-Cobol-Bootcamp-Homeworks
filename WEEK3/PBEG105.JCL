//PBEG105J JOB 1,NOTIFY=&SYSUID
//***************************************************/
//* Copyright Contributors to the COBOL Programming Course
//* SPDX-License-Identifier: CC-BY-4.0
//***************************************************/
//COBRUN    EXEC IGYWCL
//COBOL.SYSIN  DD DSN=&SYSUID..CBL(PBEG105),DISP=SHR
//LKED.SYSLMOD DD DSN=&SYSUID..LOAD(PBEG105),DISP=SHR
//***************************************************/
// IF RC < 5 THEN
//***************************************************/
//* COBRUN kisminda yaptigimiz islemler sonucunda bir hata 
//* durumu soz konusu ise yalnizca bu hatanin 5'den kucuk 
//* oldugu durum icin asagidaki islemleri baslatacagimizi
//* belirttik. Aksi takdirde programi calistirmiyoruz.
//* IEFBR14 programini calistirarak OUTP dosyamiz 
//* daha once var ise bu dosyayi siliyoruz. PBEG105 isimli
//* programimizi RUN kisminda tetikliyoruz, STEPLIB adiminda 
//* JCL'in dosyamizin exe'sini LOAD bolumunun icinden 
//* okumasinin iznini veriyoruz. INPFILE ve IDXFILE ile 
//* QSAM.INP ve VSAM.AA dosyamizin daha onceden var 
//* oldugunu ve okunabilecegini, yani DISP=SHR kullanarak 
//* paylasilabilecegini soyluyoruz. OUTFILE kisminda OUTPUT
//* dosyamizi olusturuyoruz, bu dosyanin yeni oldugunu, 
//* kataloglanacagini, bir hata durumunda silinmesini
//* belirtiyoruz. RECFM kisminde dosyanin satirlarinin 
//* sabit boyutlu oldugunu, her satirin 71 karakter oldugunu,
//* 3390 ile spesifik disk cihazi turunu, SYSOUT=* ile
//* yazdirilacak cikti dosyasinin MSGCLASS'da belirttigimiz
//* dosya ile ayni oldugunu ve en fazla 1000 satir 
//* yazdirabilecegimizi, DD DUMMY ile bazi hata durumlarinin
//* ciktilarini yazdirmaya gerek olmadigini belirtiyoruz.
//DELET300  EXEC PGM=IEFBR14
//FILE01    DD DSN=&SYSUID..QSAM.OUTP,
//             DISP=(MOD,DELETE,DELETE),SPACE=(TRK,0)
//RUN       EXEC PGM=PBEG105
//STEPLIB   DD DSN=&SYSUID..LOAD,DISP=SHR
//IDXFILE   DD DSN=&SYSUID..VSAM.AA,DISP=SHR
//INPFILE   DD DSN=&SYSUID..QSAM.INP,DISP=SHR
//OUTFILE   DD DSN=&SYSUID..QSAM.OUTP,
//             DISP=(NEW,CATLG,CATLG),
//             SPACE=(TRK,(5,5),RLSE),
//             DCB=(RECFM=FB,LRECL=71,BLKSIZE=0),UNIT=3390
//SYSOUT    DD SYSOUT=*,OUTLIM=1000
//CEEDUMP   DD DUMMY
//SYSUDUMP  DD DUMMY
//***************************************************/
// ELSE
// ENDIF
