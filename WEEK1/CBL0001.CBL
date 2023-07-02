      *-----------------------
      * Copyright Contributors to the COBOL Programming Course
      * SPDX-License-Identifier: CC-BY-4.0
      *-----------------------
       IDENTIFICATION DIVISION.
      *-----------------------
       PROGRAM-ID.    CBL0001
       AUTHOR.        BURAK OZDEMIR.
      *--------------------
       ENVIRONMENT DIVISION.
      *--------------------
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRINT-LINE ASSIGN TO PRTLINE.
           SELECT ACCT-REC   ASSIGN TO ACCTREC.
      * Daha iyi anlasilmasi adina once 12. satiri anlatacagim.
      * SELECT ile dahili, yani bizim olan bir dosya olustur dedik. 
      * Ve bu dosyamızın icerigini ASSIGN TO kullanarak 
      * ACCTREC isimli bir harici dosya olusturup ona bagladik.
      * Peki neden bunu yaptik? Çünkü DATASET bolumundeki dosyalarimizda 
      * kullanici adimizla baslayan 'Z00000.DATA' isimli bir data 
      * dosyamiz var. Bizim amacimiz bu data sayfasindan okuma yapmak ve 
      * onu yeni bir dosyaya yazdirmak olacak.

      * Peki bu DATA dosyamiza nasil baglanacagiz. Iste bunu saglayan 
      * sey JCL dosyamizda belirttigimiz koddur. JCL dosyamiza girersek 
      * ACCTREC ile baslayan kodu gorecegiz. Hemen yukarida ASSIGN TO 
      * kullanarak olusturdugumuz bu ACCTREC isimli dosyamizi JCL 
      * dosyamizdaki ifade ettigimiz ACCTREC satırı ile data dosyamiza 
      * baglamis oluyoruz.

      * Bu JCL'in icindeki ACCTREC komutunun devamında yazan "SYSUID" bir 
      * environment variable'dır. Yani bizim kullanıcı adımızı tutan bir 
      * degiskendir. (Yani SYSUID = Z99999.) Dikkat ederseniz komutun 
      * devaminda ise ".DATA" yazıyor. DATA dosyamizi derleyicimize 
      * bu komutla vermis olduk. Diger bir deyisle yukarida 
      * olusturdugumuz ACCTREC isimli dosya icin kullanilacak veri 
      * setini "Z99999.DATA" olarak tanimlamis olduk. ACCTREC komutunun 
      * son kismina "DISP=SHR" yazarak data dosyamizin var oldugunu ve 
      * bizim disimizda ayni anda baska islemcinin de kullanabilecegini 
      * belirtmis oluyoruz. 

      * Yani artik ACCTREC isimli dosyanin icindeki veriler bizim icin 
      * kodumuzda ACCT-REC isimli değiskende bulunuyor.

      * O zaman simdi yukaridaki 14. satira donelim. Bu satirda ise yine 
      * ayni seyi yaptik fakat tek fark PRTLINE isimli dosyayi bir 
      * DATA'ya baglamadik. Cunku bu dosyanin boş olmasini istiyoruz. 
      * Bu bos dosyayi kodumuzda diger dosyadan okudugumuz degerlerle 
      * dolduracagiz. JCL dosyamiza gidersek PRTLINE ile başlayan koda 
      * geldigimizde "PRTLINE DD SYSOUT=*,OUTLIM=15000" boyle bir ifade 
      * goruyoruz. Bu kod ile şunu yapmis olduk : Birazdan asagida 
      * yazacagimiz WRITE komutu ile yazdirma islemini hangi dosyaya 
      * yapacagimizi secmis olduk. Yani programin ciktisini belirli bir 
      * dosyaya yonlendirdik. (DD:Data Definition) "DD SYSOUT=*" ifadesi 
      * ciktinin sistemin varsayilan cikti aygitina yonlendirildigini 
      * belirtiyor. "OUTLIM = 15000" ifadesi ise ciktinin maksimum 
      * satir sinirinin 15000 satir oldugunu belirtiyor. Bu satira 
      * ulasildiginda, ciktiya yazdirma islemi durdurulur.
      *-------------
       DATA DIVISION.
      *-------------
       FILE SECTION.
       FD  PRINT-LINE RECORDING MODE F.
      * Burada 64. satirdaki ifademizde sunu saglamış oluyoruz :
      * PRINT-LINE isimli degiskenimiz dosyamizi temsil ediyor. Cunku 
      * yukarida FILE-CONTROL bolumunde bu degiskeni dosyamizla 
      * iliskilendirdik. "FD" anahtar kelimesi ile bu dosyamizin 
      * aciklamasini baslatiyoruz. "RECORDING MODE F" ifadesi ile 
      * dosyanin kayit yapisinin "Fixed(F)" sabit modda oldugunu 
      * belirtiyoruz. Yani dosyamizdaki her kaydin(satirin) aynı 
      * uzunlukta oldugunu ve belirli sabit uzunlukta alanlardan 
      * olustugunu belirttik.
       01  PRINT-REC.
           05  ACCT-NO-O      PIC X(8).
           05  ACCT-LIMIT-O   PIC $$,$$$,$$9.99.
           05  ACCT-BALANCE-O PIC $$,$$$,$$9.99.
           05  LAST-NAME-O    PIC X(20).
           05  FIRST-NAME-O   PIC X(15).
           05  COMMENTS-O     PIC X(50).
      *
      * Burada PRINT-REC isimli bir entity'miz var ve bu entity'nin 
      * altinda yer alan degiskenler PRINT-REC entity'sine ait.
      * 01 daha guclu anlamina geliyor. Elimizde PRINT-REC grubu var ve
      * bu grubun icinde degiskenler var. Peki bir grubun icinde sadece 
      * degiskenler mi olur? Hayir. 101'inci satira bakarsak degiskenler 
      * arasina bir adet CLIENT-ADDR entity'si tanimlanmis. Ve bu 
      * CLIENT-ADDR grubunun icine de yeni degiskenler tanimlanmis. 
      * Siralamaya bakarsak ACCT-FIELDS grubu bir suru degiskene ve bir 
      * adet de CLIENT-ADDR isimli entity'ye sahip. Bu yuzden 01 en 
      * guclu, 05 daha az guclu, 10 daha da az guclu olarak 
      * dusunebiliriz.
       FD  ACCT-REC RECORDING MODE F.
       01  ACCT-FIELDS.
           05  ACCT-NO            PIC X(8).
           05  ACCT-LIMIT         PIC S9(7)V99 COMP-3.
           05  ACCT-BALANCE       PIC S9(7)V99 COMP-3.
      * COMP-3 ifadesi sayinin Binary Coded Decimal olarak tutulmasini 
      * saglar.
           05  LAST-NAME          PIC X(20).
           05  FIRST-NAME         PIC X(15).
           05  CLIENT-ADDR.
               10  STREET-ADDR    PIC X(25).
               10  CITY-COUNTY    PIC X(20).
               10  USA-STATE      PIC X(15).
           05  RESERVED           PIC X(7).
           05  COMMENTS           PIC X(50).
      *
       WORKING-STORAGE SECTION.
       01 FLAGS.
         05 LASTREC           PIC X VALUE SPACE.
      * Burada "FLAGS" isminde bir entity olusturduk. Biz bir degiskenin 
      * 1 veya 0 olduguna, yani TRUE veya FALSE olduguna condition ile 
      * bakiyorsak ve ona gore bir seyler yapiyorsak biz aslinda bir 
      * BAYRAK(FLAG) kullanmis oluyoruz. O yuzden bu degiskenimizi 
      * "FLAGS" adinda bir grubun icinde tanimladik. Bu degisken bizim 
      * okuma yaptigimiz dosyada son satira gelip gelmedigimize gore 
      * 0'dan 1'e donusturulecek.
      *------------------
       PROCEDURE DIVISION.
      *------------------
       OPEN-FILES.
           OPEN INPUT  ACCT-REC.
           OPEN OUTPUT PRINT-LINE.
      * OPEN INPUT diyerek ACTT-REC dosyamizi okunabilir olarak actik.
      * OPEN OUTPUT diyerek PRINT-LINE olarak tanimladigimiz cikti 
      * dosyamizi da acarak program tarafindan yazilabilir hale 
      * getirilmesini sagladik.
       READ-NEXT-RECORD.
           PERFORM READ-RECORD
      *     Alltaki PERFORM UNTIL satiri aslinda while dongusudur.
      *     Yaptigi sey LASTREC degiskeni Y'ye esit mi diye bakar 
      *     ve esit degilse alttaki PERFORM ve PERFORM satirlarini 
      *     calistirir. Sonra tekrar bakar ve esit degilse yine 
      *     tekrarlar. Eger esitse dongu biter, END-PERFORM kismina 
      *     gelinir.
           PERFORM UNTIL LASTREC = 'Y'
               PERFORM WRITE-RECORD
               PERFORM READ-RECORD
           END-PERFORM
           .
      *
       CLOSE-STOP.
           CLOSE ACCT-REC.
           CLOSE PRINT-LINE.
           GOBACK.
      * READ-RECORD isimli fonksiyonumuz calisinca goruyoruz ki 
      * "READ ACCT-REC" sayesinde ACCT-REC isimli dosyamizın ilk satiri
      * READ sayesinde okunmus oluyor. 
      * Kodda 93. satira bakarsak FD ACCT-REC'in hemen altinda 
      * tanimladigimiz ACCT-FIELDS isimli grubun icindeki degiskenlere 
      * okudugumuz bu satirdaki yazilar tek tek yerlesiyor.
       READ-RECORD.
           READ ACCT-REC
               AT END MOVE 'Y' TO LASTREC
           END-READ.
      *
      * Bu kisimde MOVE'dan sonra gelen degiskenin verilerini TO'dan
      * sonra gelen degiskene koyuyoruz. Son adimda ise PRINT-REC 
      * entity'sinin sahip oldugu tum degiskenlerin degerini JCL'de 
      * belirttigimiz cikti dosyamiza yazdiriyoruz.
       WRITE-RECORD.
           MOVE ACCT-NO      TO  ACCT-NO-O.
           MOVE ACCT-LIMIT   TO  ACCT-LIMIT-O.
           MOVE ACCT-BALANCE TO  ACCT-BALANCE-O.
           MOVE LAST-NAME    TO  LAST-NAME-O.
           MOVE FIRST-NAME   TO  FIRST-NAME-O.
           MOVE COMMENTS     TO  COMMENTS-O.
           WRITE PRINT-REC.
      *
