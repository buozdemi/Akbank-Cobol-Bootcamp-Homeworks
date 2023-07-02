        IDENTIFICATION DIVISION.
        PROGRAM-ID.    PBEG0005.
        AUTHOR.        BURAK OZDEMIR.
        ENVIRONMENT DIVISION.
        INPUT-OUTPUT SECTION.
        FILE-CONTROL.
      * 16. satirda JCL dosyamizda bagladigimiz ACCTREC'i kodumuzun 
      * icinde ACCT-REC olarak kullanacagimizi belirtiyoruz. Ayrıca 
      * ACCTREC dosyasinin acilmamasi veya herhangi bir problem olmasi 
      * durumunda ACCT-ST isminde bir STATUS belirterek bu degiskenin 
      * daha sonrasinda kontrolunu saglayarak dosyamizla ilgili 
      * islerinin yolunda olup olmadigini kontrol edecegiz. Ayni islemi 
      * tabiki yeni olusturdugumuz PRTLINE dosyasi için de yapiyoruz. 
            SELECT PRINT-LINE ASSIGN TO PRTLINE
                              STATUS  PRT-ST.
            SELECT ACCT-REC   ASSIGN TO ACCTREC
                              STATUS  ACCT-ST.
        DATA DIVISION.
        FILE SECTION.
      * Bu kisimda PRINT-LINE dosyamizi FIXED(F) kayit modunda
      * kullanacagimizi belirtiyoruz. Cunku ACCT-REC'den okudugumuz
      * record'larin hepsi ayni uzunluga sahip. Okudugumuz degerleri
      * sabit, alani tanimlanmis degiskenlerimizde tutuyoruz.
      * O yuzden FIXED mod kullandık. Okudugumuz degerlerin uzerinde 
      * degisiklik yapabilmek adina PRINC-REC grubu altinda yeni 
      * degiskenlerimizi belirliyoruz. Bu degiskenler simdilik bos.
      * Amacimiz ACCT-REC'ten okudugumuz bilgileri bu degiskenlere
      * aktarmak olacak. O yuzden her birinin boyutunu okuduklarimizin 
      * boyutu kadar olusturduk.
        FD  PRINT-LINE RECORDING MODE F.
        01  PRINT-REC.
            05  PRINT-SEQ            PIC X(04).
            05  WS-SPACE-1           PIC X(01) VALUE SPACE.
            05  PRINT-AD             PIC X(15).
            05  WS-SPACE-2           PIC X(01) VALUE SPACE.
            05  PRINT-SOYAD          PIC X(15).
            05  WS-SPACE-3           PIC X(01) VALUE SPACE.
            05  PRINT-DTAR           PIC 9(08).
            05  WS-SPACE-4           PIC X(01) VALUE SPACE.
            05  PRINT-TODAY          PIC 9(08).
            05  WS-SPACE-5           PIC X(01) VALUE SPACE.
            05  PRINT-FARK           PIC 9(08).
      *
      * Burada ACCT-REC dosyamizin her satiri ayni uzunluga(length'e) 
      * sahip oldugu icin ve degiskenlerimizin boyutlarini da onceden 
      * belirttigimiz icin dosyamizi FIXED(F) kayit modunda 
      * kullacagimizi belirtiyoruz. Ve bu kisimda, dolu olan ACCT-REC
      * dosyamizi kullandigimiz icin altta yer alan ACCT-FIELDS isimli
      * grubun altindaki tum degiskenler tek tek ACCT-REC'den okudugumuz 
      * satirdaki bilgiler ile dolacak. Ama suan boslar. Dosyadan okuma 
      * yaptigimiz zaman dolmaya baslayacaklar. Yani kodumuzun devaminda
      * "H100-OPEN-FILES" bolumunde "READ ACCT-REC" komutu ile okuma 
      * yaptigimizda buradaki ACCT-FIELDS icindeki degiskenler 
      * okudugumuz satirdaki bilgiler ile dolmaya baslayacak.
      * NOT = "READ ACCT-REC" her calistiginda tek bir satir okur.
        FD  ACCT-REC RECORDING MODE F.
        01  ACCT-FIELDS.
            05  ACCT-SEQ            PIC X(04).
            05  ACCT-AD             PIC X(15).
            05  ACCT-SOYAD          PIC X(15).
            05  ACCT-DTAR           PIC 9(08).
            05  ACCT-TODAY          PIC 9(08).
      *
      * Bu kisimda STATUS olarak belirledigimiz PRT-ST isimli degiskeni
      * olusturuyoruz. STATUS hata kodları 0 ile 99 arasinda oldugu 
      * icin "PIC 9(02)" ile 2 rakamlik boyut belirtiyoruz. 
      * 88 numarali seviye bize soyle bir avantaj sagliyor : 
      * PTR-SUCCESS isimli degisken kendisinin bir ust seviyesinde olan
      * 05 PRT-ST degiskeninin degerini kontrol ediyor, eger bu deger 
      * 00 veya 97 ise PRT-SUCCESS degiskeni 1(TRUE) degerini aliyor.
      * Eger PRT-ST degeri 00 veya 97 numarali hata kodunu
      * icermiyorsa o zaman PRT-SUCCESS 0(FALSE) olarak kaliyor. Yani
      * 88 seviyeli bu kontol ile dosyamizin acilmasinda bir problem 
      * olup olmadiğina bakmis oluyoruz. 00 zaten islemin "Basarili" 
      * oldugunu soyleyen bir hata kodudur. 97 ise yine islemde bir 
      * problem olmadigini, sadece actigimiz bu dosyanin bir önceki 
      * islemlerde kapatilmamis yani acık kaldigini soyluyor. Bu durumu 
      * kodumuzda bir hata olarak gormuyoruz.
      *
      * Aynı islemi ACCT-ST icin de belirttik. Fakat ACCT-ST'nin icine
      * bir de ACCT-EOF isimli bir kontrol durumu daha ekledik. 
      * Bu kontrol "0000-MAIN." kisminda UNTIL ile surekli calismasi
      * saglanan "H200-PROCESS"'un dosyamizin son satirini okudugumuzda
      * artik dongunun sonlandirilmasi icindir. Bunun nasil olduguna 
      * "0000-MAIN." kisminda deginecegim.
        WORKING-STORAGE SECTION.
        01  WS-WORK-AREA.
            05 PRT-ST            PIC 9(02).
               88 PRT-SUCCESS               VALUE 00 97.
            05 ACCT-ST           PIC 9(02).
               88 ACCT-EOF                  VALUE 10.
               88 ACCT-SUCCESS              VALUE 00 97.
            05 WS-INT-D          PIC 9(08).
            05 WS-INT-T          PIC 9(08).
        PROCEDURE DIVISION.
      *
      * Bu kisimda INPUT ve OUTPUT dosyalarimizi acariz. Cunku 
      * birinden okuma yapacagiz, digerine de yazdirma yapacagiz. 
      * Fakat bir de "READ ACCT-REC" komutunu calistiririz. Cunku 
      * eger bu komutu sadece H200-PROCESS'imizin basina ekleseydik, 
      * dosyamiz bos bir dosya oldugunda "READ ACCT-REC" ile hata 
      * donduremeden H200-PROCESS'imize baslamis olacaktık. Boylelikle
      * H200-PROCESS'indeki islemler calismayacak ve ERROR alacaktik.
      * Bunu engellemek ve dosyanin bos oldugu durumu goz onune alarak 
      * ilk olarak okumamizi burada yapiyoruz. Bir hata soz konusu ise
      * H200-PROCESS'imizi hic calistirmamis oluyoruz.
        H100-OPEN-FILES.
            OPEN INPUT  ACCT-REC.
            OPEN OUTPUT PRINT-LINE.
            PERFORM STATUS-CONTROL.
            READ ACCT-REC.
        H100-END. EXIT.
      *
        STATUS-CONTROL.
           IF NOT (PRT-SUCCESS AND ACCT-SUCCESS)
             DISPLAY 'FILE OR FILES NOT OPENED, '
             DISPLAY 'PRT-ST: ' PRT-ST
             DISPLAY 'ACCT-ST ' ACCT-ST
             IF PRT-SUCCESS THEN
               CLOSE PRINT-LINE
             IF ACCT-SUCCESS THEN
               CLOSE ACCT-REC
             STOP RUN.
        STATUS-CONTROL-END. EXIT.
      *
      * JCL dosyamizda ACCTREC'e baglamis oldugumuz "Z95609.QSAM.BB" 
      * dosyamizin ilk satirini okuduk ve ilgili degiskenlere degerleri 
      * koyduk. Bu kisimda bu degiskenleri kullanarak hesaplamamizi 
      * yapacagiz. COMPUTE diyerek '=' gibi matematiksel bir terim
      * kullanacagimizi belirttik. FUNCTION kullanarak gomulu olan 
      * INTEGER-OF-DAY fonksiyonu ile ACCT-DTAR(Dogum tarihi) 
      * degiskenindeki gercek tarihin integer olan karsiliğini 
      * aldik. Aynisini gunumuzun tarihini iceren ACCT-TODAY degiskenine 
      * de uyguladik. Artik elimizde iki integer sayi var. 
      * Bu sayilardan gunumuz tarihi olandan dogum tarihimiz olani 
      * cikardigimizda bugune kadar yasadigimiz gun sayisini elde etmis
      * oluyoruz. 
      * INITIALIZE komutu ile PRINT-REC'deki degerleri sifirliyoruz, 
      * cunku bu degerlere her dongude diger okuyacagimiz satirin 
      * degerlerini atacagiz.
      * "WRITE PRINT-REC" komutu ile PRINT-REC'e doldurdugumuz degerleri
      * JCL'de belirttigimiz "...QSAM.CC" dosyamiza yazdirmis oluyoruz.
        H200-PROCESS.
               COMPUTE WS-INT-D =
                             FUNCTION INTEGER-OF-DATE(ACCT-DTAR)
               COMPUTE WS-INT-T =
                             FUNCTION INTEGER-OF-DATE(ACCT-TODAY)
            INITIALIZE PRINT-REC
            MOVE ACCT-SEQ       TO PRINT-SEQ
            MOVE ACCT-AD        TO PRINT-AD
            MOVE ACCT-SOYAD     TO PRINT-SOYAD
            MOVE ACCT-DTAR      TO PRINT-DTAR
            MOVE ACCT-TODAY     TO PRINT-TODAY
            COMPUTE PRINT-FARK = WS-INT-T - WS-INT-D
            MOVE SPACE TO WS-SPACE-1.
            MOVE SPACE TO WS-SPACE-2.
            MOVE SPACE TO WS-SPACE-3.
            MOVE SPACE TO WS-SPACE-4.
            MOVE SPACE TO WS-SPACE-5.
            WRITE PRINT-REC.
            READ ACCT-REC.
        H200-END. EXIT.
      *
      * Bu adımda daha once acmis oldugumuz iki dosyamizi da 
      * islemlerimiz bittigi icin kapatiyoruz.
        H300-CLOSE-FILES.
            CLOSE ACCT-REC
                  PRINT-LINE.
        H300-END. EXIT.
      *
        H999-PROGRAM-EXIT.
            PERFORM H300-CLOSE-FILES.
        H999-END. EXIT.
      *
      * Bu kisimda MAIN fonksiyonumuzu olusturuyoruz. Bu main fonksiyonu
      * PERFORM ile belirtilen diger fonksiyonları sirasiyla calistirir.
      * Fakat 2. PERFORM satirinda kullanilan UNTIL'den dolayi 
      * "H200-PROCESS" fonksiyonu ACCT-EOF degiskeni 1(TRUE) olana kadar
      * calistirilacaktir. ACCT-EOF nasil TRUE olacak diye sorarsanız
      * soyle aciklamak gerekir. "H200-PROCESS"'un en alt satirindaki
      * "READ ACCT-REC" calistiginda eger son satirdaysak ve artik bir 
      * sonraki satiri okumaya calisiyorsa, boyle bir satir olmadigi 
      * icin ACCT-REC isimli dosyamizin STATUS degiskenine otomatik 
      * olarak END-OF-FILE(Dosya Sonu) hata kodu olan 10 degeri atanır.
      * 63. satirda bahsettigim olay burada da gerceklesir. 
      * Yani ACCT-ST 10 degerini aldigindan dolayi ACCT-EOF degiskeni
      * kendisinin bir ust seviyesindeki degisken olan ACCT-ST'yi 
      * surekli kontrol ettigi icin "ACCT-ST" 10 oldugu an "ACCT-EOF" 
      * TRUE(1) olur. Bu sayede 2. PERFORM'daki dongu biter.
      * Artik 3. PERFORM baslayabilir.
        0000-MAIN.
            PERFORM H100-OPEN-FILES.
            PERFORM H200-PROCESS UNTIL ACCT-EOF.
            PERFORM H999-PROGRAM-EXIT.
            STOP RUN.