        IDENTIFICATION DIVISION.
        PROGRAM-ID.    PBEG105.
        AUTHOR.        BURAK OZDEMIR.
        ENVIRONMENT DIVISION.
        INPUT-OUTPUT SECTION.
        FILE-CONTROL.
      * Burada ORG IND. kullanarak bu dosyamizda record'lara nasil 
      * nasil ulasilacagini belirledik. Recordlar'a indexlerle 
      * ulasacagimizi soyledik. ACCESS kisminda RANDOM kullanarak 
      * KEY degerlerimizi bizim belirledigimizi, yani record'umuzun 
      * icinde key degerimizin mevcut oldugunu soyledik.
      * RECORD KEY ise record'larimiza dosya icinde ulasabilmemizi ve 
      * kayit silme, ekleme, guncelleme gibi olaylari gerceklestirmeyi 
      * saglar. Bu IDX-KEY simdilik bos, onu kullanacagimiz zaman 
      * dolduracagiz. 
            SELECT IDX-FILE   ASSIGN TO IDXFILE
                              ORGANIZATION INDEXED
                              ACCESS RANDOM
                              RECORD KEY IDX-KEY
                              STATUS  IDX-ST.
            SELECT OUT-FILE   ASSIGN TO OUTFILE
                              STATUS  OUT-ST.
            SELECT INP-FILE   ASSIGN TO INPFILE
                              STATUS  INP-ST.
        DATA DIVISION.
        FILE SECTION.
      * Bu bolumde IDX-KEY'imizi JCL'de belirttigimiz PD ve BI 
      * formatinda olusturacagiz ki sonrasinda dogru dolum yapabilelim.
      * Diger degiskenlerimizi de JCL'de cevirmis oldugumuz veri tipinde
      * olusturuyoruz. Bu alanlar READ ile IDX-FILE okumasi yaptigimiz 
      * zaman otomatik olarak dosyanin icerigi ile dolacaktir.
        FD  IDX-FILE.
        01  IDX-REC.
            03  IDX-KEY.
                05 IDX-ID            PIC S9(05) COMP-3.
                05 IDX-DVZ           PIC S9(03) COMP.
            03  IDX-ADSOYAD          PIC X(30).
            03  IDX-TARIH            PIC 9(07) COMP-3.
            03  IDX-TUTAR            PIC S9(13)V99 COMP-3.
      *
      * Bu kisimda aralarda kullanilan WS-SPACE degiskenleri verileri 
      * yazdirdigimizda aralarinda bosluk olmasini istedigim icindir.
      * VSAM dosyamizdan JULIAN olarak aldigimiz tarihi H200-PROCESS'de
      * GREGORIAN tarihe cevirdigimiz icin 7 karakterlik tarih 8 
      * karaktere donusmustur. Bu sebeple OUT-TARIH'i 8 karakter olarak 
      * belirledik. OUT-TUTAR degiskeni ise virguller, noktalar ve dolar
      * isareti dahil oldugu icin 21 byte kaplayacaktir.
        FD  OUT-FILE RECORDING MODE F.
        01  OUT-REC.
            03  OUT-KEY.
                05  OUT-ID             PIC 9(05).
                05  WS-SPACE-1         PIC X(01) VALUE SPACE.
                05  OUT-DVZ            PIC 9(03).
            03  WS-SPACE-2             PIC X(01) VALUE SPACE.
            03  OUT-ADSOYAD            PIC X(30).
            03  WS-SPACE-3             PIC X(01) VALUE SPACE.
            03  OUT-TARIH              PIC 9(08).
            03  WS-SPACE-4             PIC X(01) VALUE SPACE.
            03  OUT-TUTAR              PIC $,$$$,$$$,$$$,$$$9.99.
      *
      * Bu kisimda INP dosyamizdan aldigimiz ve VSAM dosyamizda 
      * bulmaya calisacagimiz ID degeri 8 karakterlik bir ZD oldugu 
      * icin bu degeri sonunda COMP ifadesi olmayan sekliyle tanimladik. 
        FD  INP-FILE RECORDING MODE F.
        01  INP-FIELDS.
            03  INP-KEY.
                05 INP-ID        PIC 9(05).
                05 INP-DVZ       PIC 9(03).
      *
        WORKING-STORAGE SECTION.
        01  WS-WORK-AREA.
            05 IDX-ST            PIC 9(02).
               88 IDX-SUCCESS               VALUE 00 97.
      *     Buradaki 23, eger inputta bir dosyamiz yoksa veya
      *     KEY IS ile veri taramasi yapilirken veri bulunamazsa 
      *     IDX-ST 23'e esit olur. Dolayisiyla IDX-NOTFND degeri 
      *     TRUE olur. Biz de IDX-NOTFND'a condition uygulayarak 
      *     VSAM dosyamizin icinde KEY degerimizin var olup olmadigina 
      *     bakabilir, buna gore degerlendirme yapabiliriz.
               88 IDX-NOTFND                VALUE 23.
            05 OUT-ST            PIC 9(02).
               88 OUT-SUCCESS               VALUE 00 97.
            05 INP-ST            PIC 9(02).
               88 INP-SUCCESS               VALUE 00 97.
            05  WS-INT-JULIAN    PIC 9(07).
            05  WS-GREG          PIC 9(08).
            05  TEMP-DATE        PIC 9(07).
            05  LASTREC           PIC X VALUE SPACE.
            05  INP-KEY-COMP.
               07 INP-ID-COMP    PIC S9(05) COMP-3.
               07 INP-DVZ-COMP   PIC S9(03) COMP.
        PROCEDURE DIVISION.
      *
      * Bu kisim bitmeden burada READ-RECORD'u calistiriyoruz. Cunku 
      * main kisminda "PERFORM UNTIL LASTREC = 'Y'" komutumuz var. 
      * Bu komut LASTREC degiskeninin Y olup olmadigina gore donguyu
      * devam ettirir. Biz burada once 1 kez READ-RECORD ile okuma 
      * yapiyoruz ki okudugumuz ilk satirda bir deger yoksa, yani 
      * inputtan okudugumuz dosya bos ise READ-RECORD'da LASTREC 
      * degiskenimizi 'Y' yapiyoruz. Bu sayede maindeki 2. PERFORM 
      * ifademizi calisamaz duruma getirmis oluyoruz.
        H100-OPEN-FILES.
            OPEN INPUT  IDX-FILE.
            OPEN INPUT  INP-FILE.
            OPEN OUTPUT OUT-FILE.
            PERFORM STATUS-CONTROL.
            PERFORM READ-RECORD.
        H100-END. EXIT.
      *
      * Dosyalarimizin acilip acilmadigi durumunu kontrol ediyoruz. 
      * Eger bir tanesi acilmadi ise digerlerinin acilip acilmadigini 
      * if ile kontrol ediyor ve acilanlari mutlaka kapatiyoruz.
        STATUS-CONTROL.
            IF NOT (IDX-SUCCESS AND OUT-SUCCESS AND INP-SUCCESS) THEN
               DISPLAY 'FILE OR FILES NOT OPENED. STATUS VALUES => '
               DISPLAY ' IDX: ' IDX-ST ' INP: ' INP-ST ' OUT: ' OUT-ST
               IF IDX-SUCCESS THEN CLOSE IDX-FILE
               IF OUT-SUCCESS THEN CLOSE OUT-FILE
               IF INP-SUCCESS THEN CLOSE INP-FILE
               STOP RUN.
        STATUS-CONTROL-END. EXIT.
      *
      * Bu bolumde INITIALIZE ile basliyoruz, cunku bu kisim dongumuz
      * her calistiginda tekrar edecek ve biz INP-KEY-COMP'a degerler 
      * atiyacagiz. Önceki degerin uzerine atama yapmak yanlis sonuca 
      * neden olabilir. Sonrasinda inputtan ZD olarak aldigimiz 
      * ID verilerini Working-Storage-Section'da olusturdugumuz COMP
      * türü degiskenlerimize atiyoruz. Cunku IDX-KEY'imiz COMP turunde.
      * Amacimiz IDX-KEY'imize inputtan okudugumuz ID degerlerini 
      * yerlestirmek. Asagidaki 3. MOVE satirinda bu yerlestirmeyi 
      * yapiyoruz. Artik READ komutu ile IDX-FILE'in icinde IDX-KEY'deki
      * degerin var olup olmadigina bakabiliriz. Eger VSAM dosyamizin
      * icinde KEY degerimiz varsa o KEY'in verilerini yazdirmak icin
      * H200-PROCESS'ini calistirdik.
        H175-WHILE-PROCESS.
            INITIALIZE INP-KEY-COMP
            MOVE INP-ID         TO INP-ID-COMP
            MOVE INP-DVZ        TO INP-DVZ-COMP
            MOVE INP-KEY-COMP   TO IDX-KEY
            READ IDX-FILE KEY IS IDX-KEY
              IF IDX-NOTFND
                DISPLAY 'THIS VALUE: ' INP-KEY ' NOT AVAILABLE'
              ELSE
                PERFORM H200-PROCESS.
        H175-END. EXIT.
      *
      * Burada ilk isimiz verimizdeki TARIH degeri COMP olarak geldigi
      * icin onu oncelikle ZD formatinda bir TEMP degiskenine atiyorum.
      * Bu degiskeni kullanarak, JULIAN olarak gelen 7 karakterli bu 
      * TARIH'i gerekli fonksiyonlari kullanarak GREOGORIAN tarihe
      * ceviriyoruz. Bu adimda dongu devam ettikce OUT-REC entity'sinin 
      * degerlerini dolduracagimiz icin önceki islemlerden dolu kalan 
      * OUT-REC'i INITIALIZE ile sifirlayip sonrasinda gerekli atamalari
      * yapiyoruz.
        H200-PROCESS.
            MOVE IDX-TARIH     TO TEMP-DATE
            COMPUTE WS-INT-JULIAN = FUNCTION INTEGER-OF-DAY(TEMP-DATE)
            COMPUTE WS-GREG = FUNCTION DATE-OF-INTEGER(WS-INT-JULIAN)
            INITIALIZE OUT-REC.
            MOVE IDX-ID        TO OUT-ID
            MOVE IDX-DVZ       TO OUT-DVZ
            MOVE IDX-ADSOYAD   TO OUT-ADSOYAD
            MOVE WS-GREG       TO OUT-TARIH
            MOVE IDX-TUTAR     TO OUT-TUTAR
            MOVE SPACE         TO WS-SPACE-1
            MOVE SPACE         TO WS-SPACE-2
            MOVE SPACE         TO WS-SPACE-3
            MOVE SPACE         TO WS-SPACE-4
            WRITE OUT-REC.
        H200-END. EXIT.
      *
        H300-CLOSE-FILES.
            CLOSE IDX-FILE
                  OUT-FILE
                  INP-FILE.
        H300-END. EXIT.
      *
        H999-PROGRAM-EXIT.
            PERFORM H300-CLOSE-FILES.
        H999-END. EXIT.

        READ-RECORD.
            READ INP-FILE
                AT END MOVE 'Y' TO LASTREC
            END-READ.
      *
        0000-MAIN.
            PERFORM H100-OPEN-FILES.
            PERFORM UNTIL LASTREC = 'Y'
                PERFORM H175-WHILE-PROCESS
                PERFORM READ-RECORD
            END-PERFORM.
            PERFORM H999-PROGRAM-EXIT.
            STOP RUN.
