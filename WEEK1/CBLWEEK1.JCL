//CBLWEEK1 JOB 1,NOTIFY=&SYSUID
//***************************************************/
//* Copyright Contributors to the COBOL Programming Course
//* SPDX-License-Identifier: CC-BY-4.0
//***************************************************/
//* IGYWCL proseduru, kaynak kodumuzun execute edilmesini 
//* ve exe dosyamizin olusturulacagi yer gibi ayarlari 
//* yapabilmemizi saglayan iki adimli bir prosedurdur.
//* COBOL.SYSIN ile calistiracagimiz kaynak dosyamizi
//* belirtiriz. DISP=SHR ile okuma yapacagimizi ve
//* bu kod calisirken baska programlarin da 
//* belirtilen data dosyasini okuyabilmesini sagliyoruz.
//* LKED.SYSLMOD ile exec dosyamizin olusmasi gereken
//* konum ile baglantiyi ayarlariz. 
//COBRUN   EXEC IGYWCL
//COBOL.SYSIN  DD DSN=&SYSUID..CBL(CBL0001),DISP=SHR
//LKED.SYSLMOD DD DSN=&SYSUID..LOAD(CBLWEK1),DISP=SHR
//***************************************************/
//* Burada IF RC ile yukaridaki islemlerimiz sirasinda
//* bir hata olmadigini yani RC'nin 0 olup olmadigini,
//* eger 0 ise asagidaki koddan devam edecegimizi, 
//* sifir degilse en alttaki else blogundan islemi
//* sonlandiracagimizi belirttik. RC = Return Code
// IF RC = 0 THEN
//***************************************************/
//* Burada oncelikle "&SYSUID.DATA.WEEK1" isminde olusan
//* bir dosyamiz varsa "DELET300" kisminda o dosyayi  
//* silme islemini uygulariz.
//* IEFBR14 isimli bos programi calistiriririz. Bunu 
//* yapmamizin sebebi, bir data definition kullanarak
//* var olan dosyayi silmektir. (MOD, DELETE, DELETE)
//* kullanarak MOD ile var olan dosya eger gercekten
//* varsa silinmis olur. 
//DELET300  EXEC PGM=IEFBR14
//FILE01    DD DSN=&SYSUID..DATA.WEEK1,
//             DISP=(MOD,DELETE,DELETE),SPACE=(TRK,0)
//* Burada CBL0001 isimli programimizi calistiririz.
//* Execute dosyamizin da STEPLIB ile islemler
//* yapilirken okunabilmesini saglamak adina bir  
//* DD DSN belirtiriz. Kodumuzda bulunan ACCTREC
//* isimli dosyanin burada hangi dosya olacagini
//* da DD DSN ile belirtiriz. PRTLINE kisminda ise
//* hangi dosyaya yazma yapacagimizi belirtmek icin,
//* once NEW ile dosya acariz, o dosyayi katalogumuza
//* ekleriz, aksi bir durumda DELETE ile silinmesini
//* saglariz. SPACE 5 Track'lik yer acilmasini ve
//* yetmedigi durumlarda bir 5 Track'lik yer daha 
//* acilmasini belirtiriz. RLSE ile islemlerimiz 
//* bittiginde tutulan alanlarin artik serbest 
//* birakilabilecegini soyleriz.
//* RECFM ile kayit formatimizin Fixed Block
//* yani her satirin ayni uzunlukta oldugunu, 
//* LRECL ile bu satirlarin 119 uzunlugunda oldugunu,
//* BLKSIZE = 0 ile varsayilan BLKSIZE ayarini,
//* 3390 ile IBM Mainframe'indeki disk surucusu 
//* modelini belirtmis oluruz.
//RUN      EXEC PGM=CBL0001
//STEPLIB   DD DSN=&SYSUID..LOAD,DISP=SHR
//ACCTREC   DD DSN=&SYSUID..DATA,DISP=SHR
//PRTLINE   DD DSN=&SYSUID..DATA.WEEK1,
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(5,5),RLSE),
//             DCB=(RECFM=FB,LRECL=119,BLKSIZE=0),UNIT=3390
//***************************************************/
// ELSE
// ENDIF