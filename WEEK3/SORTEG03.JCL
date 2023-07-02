//SORTEG03 JOB ' ',
//         CLASS=A,
//         MSGLEVEL=(1,1),
//         MSGCLASS=X,
//         NOTIFY=&SYSUID
//DELET100 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE Z95609.QSAM.INP NONVSAM
  IF LASTCC LE 08 THEN SET MAXCC = 00
//SORT0200 EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//* SORTIN kisminda verilerimizi belirtiyoruz.
//SORTIN   DD *
10003978
20001836
10001949
//SORTOUT  DD DSN=&SYSUID..QSAM.INP,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(5,5),RLSE),
//            DCB=(RECFM=FB,LRECL=8)
//* SYSIN kisminda verilerimizi direkt olarak
//* SORTOUT olarak belirledigimiz QSAM.INP
//* isimli yeni olusturdugumuz dosyamiza kopyaliyoruz.
//SYSIN    DD *
  SORT FIELDS=COPY
