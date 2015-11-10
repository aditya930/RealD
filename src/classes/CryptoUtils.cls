public  class CryptoUtils {
 
    public enum eAES_MODE{AES_ENCRYPT,AES_DECRYPT}    
    
    public static  String []    HexStringValues    = new  String []          {
          
'00','01','02','03','04','05','06','07','08','09','0A','0B','0C','0D','0E','0F','10','11','12','13','14','15','16','17','18','19','1A','1B','1C','1D','1E','1F','20','21','22','23','24','25','26','27','28','29','2A','2B','2C','2D','2E','2F','30','31','32','33','34','35','36','37','38','39','3A','3B','3C','3D','3E','3F','40','41','42','43','44','45','46','47','48','49','4A','4B','4C','4D','4E','4F','50','51','52','53','54','55','56','57','58','59','5A','5B','5C','5D','5E','5F','60','61','62','63','64','65','66','67','68','69','6A','6B','6C','6D','6E','6F','70','71','72','73','74','75','76','77','78','79','7A','7B','7C','7D','7E','7F','80','81','82','83','84','85','86','87','88','89','8A','8B','8C','8D','8E','8F','90','91','92','93','94','95','96','97','98','99','9A','9B','9C','9D','9E','9F','A0','A1','A2','A3','A4','A5','A6','A7','A8','A9','AA','AB','AC','AD','AE','AF','B0','B1','B2','B3','B4','B5','B6','B7','B8','B9','BA','BB','BC','BD','BE','BF','C0','C1','C2','C3','C4','C5','C6','C7','C8','C9','CA','CB','CC','CD','CE','CF','D0','D1','D2','D3','D4','D5','D6','D7','D8','D9','DA','DB','DC','DD','DE','DF','E0','E1','E2','E3','E4','E5','E6','E7','E8','E9','EA','EB','EC','ED','EE','EF','F0','F1','F2','F3','F4','F5','F6','F7','F8','F9','FA','FB','FC','FD','FE','FF'
           };
       
    public static Integer [] HexIntValues = new Integer[]
    {
       0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255
    };


    public static Long [] RCON = new Long [] {
         1L,2L,4L,8L,16L,32L,64L,128L,27L,54L
      };
    
    public static Long [] FSB = new Long [] {
         99L,124L,119L,123L,242L,107L,111L,197L,48L,1L,103L,43L,254L,215L,171L,118L,202L,130L,201L,125L,250L,89L,71L,240L,173L,212L,162L,175L,156L,164L,114L,192L,183L,253L,147L,38L,54L,63L,247L,204L,52L,165L,229L,241L,113L,216L,49L,21L,4L,199L,35L,195L,24L,150L,5L,154L,7L,18L,128L,226L,235L,39L,178L,117L,9L,131L,44L,26L,27L,110L,90L,160L,82L,59L,214L,179L,41L,227L,47L,132L,83L,209L,0L,237L,32L,252L,177L,91L,106L,203L,190L,57L,74L,76L,88L,207L,208L,239L,170L,251L,67L,77L,51L,133L,69L,249L,2L,127L,80L,60L,159L,168L,81L,163L,64L,143L,146L,157L,56L,245L,188L,182L,218L,33L,16L,255L,243L,210L,205L,12L,19L,236L,95L,151L,68L,23L,196L,167L,126L,61L,100L,93L,25L,115L,96L,129L,79L,220L,34L,42L,144L,136L,70L,238L,184L,20L,222L,94L,11L,219L,224L,50L,58L,10L,73L,6L,36L,92L,194L,211L,172L,98L,145L,149L,228L,121L,231L,200L,55L,109L,141L,213L,78L,169L,108L,86L,244L,234L,101L,122L,174L,8L,186L,120L,37L,46L,28L,166L,180L,198L,232L,221L,116L,31L,75L,189L,139L,138L,112L,62L,181L,102L,72L,3L,246L,14L,97L,53L,87L,185L,134L,193L,29L,158L,225L,248L,152L,17L,105L,217L,142L,148L,155L,30L,135L,233L,206L,85L,40L,223L,140L,161L,137L,13L,191L,230L,66L,104L,65L,153L,45L,15L,176L,84L,187L,22L
      };
      
    public   static Long [] FT0= new Long [] {
         2774754246L,2222750968L,2574743534L,2373680118L,234025727L,3177933782L,2976870366L,1422247313L,1345335392L,50397442L,2842126286L,2099981142L,436141799L,1658312629L,3870010189L,2591454956L,1170918031L,2642575903L,1086966153L,2273148410L,368769775L,3948501426L,3376891790L,200339707L,3970805057L,1742001331L,4255294047L,3937382213L,3214711843L,4154762323L,2524082916L,1539358875L,3266819957L,486407649L,2928907069L,1780885068L,1513502316L,1094664062L,49805301L,1338821763L,1546925160L,4104496465L,887481809L,150073849L,2473685474L,1943591083L,1395732834L,1058346282L,201589768L,1388824469L,1696801606L,1589887901L,672667696L,2711000631L,251987210L,3046808111L,151455502L,907153956L,2608889883L,1038279391L,652995533L,1764173646L,3451040383L,2675275242L,453576978L,2659418909L,1949051992L,773462580L,756751158L,2993581788L,3998898868L,4221608027L,4132590244L,1295727478L,1641469623L,3467883389L,2066295122L,1055122397L,1898917726L,2542044179L,4115878822L,1758581177L,0L,753790401L,1612718144L,536673507L,3367088505L,3982187446L,3194645204L,1187761037L,3653156455L,1262041458L,3729410708L,3561770136L,3898103984L,1255133061L,1808847035L,720367557L,3853167183L,385612781L,3309519750L,3612167578L,1429418854L,2491778321L,3477423498L,284817897L,100794884L,2172616702L,4031795360L,1144798328L,3131023141L,3819481163L,4082192802L,4272137053L,3225436288L,2324664069L,2912064063L,3164445985L,1211644016L,83228145L,3753688163L,3249976951L,1977277103L,1663115586L,806359072L,452984805L,250868733L,1842533055L,1288555905L,336333848L,890442534L,804056259L,3781124030L,2727843637L,3427026056L,957814574L,1472513171L,4071073621L,2189328124L,1195195770L,2892260552L,3881655738L,723065138L,2507371494L,2690670784L,2558624025L,3511635870L,2145180835L,1713513028L,2116692564L,2878378043L,2206763019L,3393603212L,703524551L,3552098411L,1007948840L,2044649127L,3797835452L,487262998L,1994120109L,1004593371L,1446130276L,1312438900L,503974420L,3679013266L,168166924L,1814307912L,3831258296L,1573044895L,1859376061L,4021070915L,2791465668L,2828112185L,2761266481L,937747667L,2339994098L,854058965L,1137232011L,1496790894L,3077402074L,2358086913L,1691735473L,3528347292L,3769215305L,3027004632L,4199962284L,133494003L,636152527L,2942657994L,2390391540L,3920539207L,403179536L,3585784431L,2289596656L,1864705354L,1915629148L,605822008L,4054230615L,3350508659L,1371981463L,602466507L,2094914977L,2624877800L,555687742L,3712699286L,3703422305L,2257292045L,2240449039L,2423288032L,1111375484L,3300242801L,2858837708L,3628615824L,84083462L,32962295L,302911004L,2741068226L,1597322602L,4183250862L,3501832553L,2441512471L,1489093017L,656219450L,3114180135L,954327513L,335083755L,3013122091L,856756514L,3144247762L,1893325225L,2307821063L,2811532339L,3063651117L,572399164L,2458355477L,552200649L,1238290055L,4283782570L,2015897680L,2061492133L,2408352771L,4171342169L,2156497161L,386731290L,3669999461L,837215959L,3326231172L,3093850320L,3275833730L,2962856233L,1999449434L,286199582L,3417354363L,4233385128L,3602627437L,974525996L };
      
     public  static Long [] RSB= new Long [] {
         82L,9L,106L,213L,48L,54L,165L,56L,191L,64L,163L,158L,129L,243L,215L,251L,124L,227L,57L,130L,155L,47L,255L,135L,52L,142L,67L,68L,196L,222L,233L,203L,84L,123L,148L,50L,166L,194L,35L,61L,238L,76L,149L,11L,66L,250L,195L,78L,8L,46L,161L,102L,40L,217L,36L,178L,118L,91L,162L,73L,109L,139L,209L,37L,114L,248L,246L,100L,134L,104L,152L,22L,212L,164L,92L,204L,93L,101L,182L,146L,108L,112L,72L,80L,253L,237L,185L,218L,94L,21L,70L,87L,167L,141L,157L,132L,144L,216L,171L,0L,140L,188L,211L,10L,247L,228L,88L,5L,184L,179L,69L,6L,208L,44L,30L,143L,202L,63L,15L,2L,193L,175L,189L,3L,1L,19L,138L,107L,58L,145L,17L,65L,79L,103L,220L,234L,151L,242L,207L,206L,240L,180L,230L,115L,150L,172L,116L,34L,231L,173L,53L,133L,226L,249L,55L,232L,28L,117L,223L,110L,71L,241L,26L,113L,29L,41L,197L,137L,111L,183L,98L,14L,170L,24L,190L,27L,252L,86L,62L,75L,198L,210L,121L,32L,154L,219L,192L,254L,120L,205L,90L,244L,31L,221L,168L,51L,136L,7L,199L,49L,177L,18L,16L,89L,39L,128L,236L,95L,96L,81L,127L,169L,25L,181L,74L,13L,45L,229L,122L,159L,147L,201L,156L,239L,160L,224L,59L,77L,174L,42L,245L,176L,200L,235L,187L,60L,131L,83L,153L,97L,23L,43L,4L,126L,186L,119L,214L,38L,225L,105L,20L,99L,85L,33L,12L,125L};
      
    public   static Long [] RTO= new Long [] {
        1353184337L,1399144830L,3282310938L,2522752826L,3412831035L,4047871263L,2874735276L,2466505547L,1442459680L,4134368941L,2440481928L,625738485L,4242007375L,3620416197L,2151953702L,2409849525L,1230680542L,1729870373L,2551114309L,3787521629L,41234371L,317738113L,2744600205L,3338261355L,3881799427L,2510066197L,3950669247L,3663286933L,763608788L,3542185048L,694804553L,1154009486L,1787413109L,2021232372L,1799248025L,3715217703L,3058688446L,397248752L,1722556617L,3023752829L,407560035L,2184256229L,1613975959L,1165972322L,3765920945L,2226023355L,480281086L,2485848313L,1483229296L,436028815L,2272059028L,3086515026L,601060267L,3791801202L,1468997603L,715871590L,120122290L,63092015L,2591802758L,2768779219L,4068943920L,2997206819L,3127509762L,1552029421L,723308426L,2461301159L,4042393587L,2715969870L,3455375973L,3586000134L,526529745L,2331944644L,2639474228L,2689987490L,853641733L,1978398372L,971801355L,2867814464L,111112542L,1360031421L,4186579262L,1023860118L,2919579357L,1186850381L,3045938321L,90031217L,1876166148L,4279586912L,620468249L,2548678102L,3426959497L,2006899047L,3175278768L,2290845959L,945494503L,3689859193L,1191869601L,3910091388L,3374220536L,0L,2206629897L,1223502642L,2893025566L,1316117100L,4227796733L,1446544655L,517320253L,658058550L,1691946762L,564550760L,3511966619L,976107044L,2976320012L,266819475L,3533106868L,2660342555L,1338359936L,2720062561L,1766553434L,370807324L,179999714L,3844776128L,1138762300L,488053522L,185403662L,2915535858L,3114841645L,3366526484L,2233069911L,1275557295L,3151862254L,4250959779L,2670068215L,3170202204L,3309004356L,880737115L,1982415755L,3703972811L,1761406390L,1676797112L,3403428311L,277177154L,1076008723L,538035844L,2099530373L,4164795346L,288553390L,1839278535L,1261411869L,4080055004L,3964831245L,3504587127L,1813426987L,2579067049L,4199060497L,577038663L,3297574056L,440397984L,3626794326L,4019204898L,3343796615L,3251714265L,4272081548L,906744984L,3481400742L,685669029L,646887386L,2764025151L,3835509292L,227702864L,2613862250L,1648787028L,3256061430L,3904428176L,1593260334L,4121936770L,3196083615L,2090061929L,2838353263L,3004310991L,999926984L,2809993232L,1852021992L,2075868123L,158869197L,4095236462L,28809964L,2828685187L,1701746150L,2129067946L,147831841L,3873969647L,3650873274L,3459673930L,3557400554L,3598495785L,2947720241L,824393514L,815048134L,3227951669L,935087732L,2798289660L,2966458592L,366520115L,1251476721L,4158319681L,240176511L,804688151L,2379631990L,1303441219L,1414376140L,3741619940L,3820343710L,461924940L,3089050817L,2136040774L,82468509L,1563790337L,1937016826L,776014843L,1511876531L,1389550482L,861278441L,323475053L,2355222426L,2047648055L,2383738969L,2302415851L,3995576782L,902390199L,3991215329L,1018251130L,1507840668L,1064563285L,2043548696L,3208103795L,3939366739L,1537932639L,342834655L,2262516856L,2180231114L,1053059257L,741614648L,1598071746L,1925389590L,203809468L,2336832552L,1100287487L,1895934009L,3736275976L,2632234200L,2428589668L,1636092795L,1890988757L,1952214088L,1113045200L }; 
        
    public static string generateEncryptionKey()
    {
        Blob cryptoKey = Crypto.generateAesKey(128);
        return  EncodingUtil.base64Encode(cryptoKey);
        
    }
    
    public static void AESFROUND(Long[] RK, RefObject  X0, RefObject  X1, RefObject  X2, RefObject  X3, Long Y0, Long Y1, Long Y2, Long Y3)
    { 
      X0.argvalue = ((((RK[0] ^  FT0((Y0) & 255)) ^  FT1((Y1 >> 8) & 255)) ^  FT2((Y2 >> 16) & 255)) ^  FT3((Y3 >> 24) & 255));

      X1.argvalue =  ((((RK[1] ^  FT0((Y1) & 255)) ^  FT1((Y2 >> 8) & 255)) ^  FT2((Y3 >> 16) & 255)) ^  FT3((Y0 >> 24) & 255));

      X2.argvalue =  ((((RK[2] ^  FT0((Y2) & 255)) ^  FT1((Y3 >> 8) & 255)) ^  FT2((Y0 >> 16) & 255)) ^  FT3((Y1 >> 24) & 255));

      X3.argvalue =  ((((RK[3] ^  FT0((Y3) & 255)) ^  FT1((Y0 >> 8) & 255)) ^  FT2((Y1 >> 16) & 255)) ^  FT3((Y2 >> 24) & 255));
    }





    public static void AESRROUND(Long [] RK,  RefObject  X0,  RefObject  X1,  RefObject  X2,  RefObject  X3, Long Y0, Long  Y1, Long  Y2, Long Y3)
    {
      X0.argvalue = ((((RK[0] ^  RT0((Y0) & 255)) ^ RT1((Y3 >> 8) & 255)) ^ RT2((Y2 >> 16) & 255)) ^ RT3((Y1 >> 24) & 255));

      X1.argvalue = ((((RK[1] ^  RT0((Y1) & 255)) ^ RT1((Y0 >> 8) & 255)) ^ RT2((Y3 >> 16) & 255)) ^ RT3((Y2 >> 24) & 255));

      X2.argvalue = ((((RK[2] ^  RT0((Y2) & 255)) ^ RT1((Y1 >> 8) & 255)) ^ RT2((Y0 >> 16) & 255)) ^ RT3((Y3 >> 24) & 255));

      X3.argvalue = ((((RK[3] ^  RT0((Y3) & 255)) ^ RT1((Y2 >> 8) & 255)) ^ RT2((Y1 >> 16) & 255)) ^ RT3((Y0 >> 24) & 255));
    }



  
  
    public static Long RotateLeft(Long x, Long r)
    {
      return   Integer.valueOf(
        (x) <<  (r)  |  ((x) >> (32 - r))
      )
      ;
    }

 
    public static Long FT0(Long x)
    {
      return FT0[(Integer)x];
    }


     public static Long FT1(Long x)
    {
      return RotateLeft(FT0[(Integer)x], 8);
    }

    public static Long FT2(Long x)
    {
      return RotateLeft(FT0[(Integer)x], 16);
    }
 
    public static Long FT3(Long x)
    {
      return RotateLeft(FT0[(Integer)x], 24);
    }


 
    public static Long RT0(Long x)
    {
      return RTO[(Integer)x];
    }


 
    public static Long RT1(Long x)
    {
      return RotateLeft(RTO[(Integer)x], 8);
    }

 
    public static Long RT2(Long x)
    {
      return RotateLeft(RTO[(Integer)x], 16);
    }

 
    public static Long RT3(Long x)
    {
      return RotateLeft(RTO[(Integer)x], 24);
    }



    public static Integer setbits(Integer destination, Integer source, Integer at, Integer numbits)
        {
            Integer  ones = ((1 << (numbits)) - 1) << at;
            return (ones | destination) ^ ((~source << at) & ones);
        } 
        
    
    public  class RefObject 
    {
        public Long argvalue;
        public RefObject(Long  refarg)
        {
            argvalue = refarg;
        }
    }
  
  
         
    public static void AESSetKeyDec(CAESContext ctx, Long[] key, Long keysize)
    {

 
      Long i, j;
      CAESContext cty = new CAESContext();

 
      Long[] RK;

 
      Long[] SK;


      Long RK_index = 0;


     
      Long NUMROUNDS = 10;
            cty.buf = new Long[44];
            cty.nr = 10;
           RK = ctx.buf;

      AESSetKeyEnc(cty, key, keysize);


 
      Long SK_index = cty.nr * 4;

      SK = cty.buf;

      RK[(Integer)RK_index++] = SK[(Integer)SK_index++];
      RK[(Integer)RK_index++] = SK[(Integer)SK_index++];
      RK[(Integer)RK_index++] = SK[(Integer)SK_index++];
      RK[(Integer)RK_index++] = SK[(Integer)SK_index++];

      SK_index -= 8;


 
      for (i = NUMROUNDS; i > 1; i--)
      {
        for (j = 0; j < 4; j++)
        {
          RK[(Integer)RK_index++] = (((RT0(FSb[(Integer)(SK[(Integer)SK_index]) & 255]) ^ RT1(FSb[(Integer)(SK[(Integer)SK_index] >> 8) & 255])) ^ RT2(FSb[(Integer)(SK[(Integer)SK_index] >> 16) & 255])) ^ 
          RT3(FSb[(Integer)(SK[(Integer)SK_index] >> 24) & 255]));
          SK_index++;
        }
        SK_index -= 8;
      }

      RK[(Integer)RK_index++] = SK[(Integer)SK_index++];
      RK[(Integer)RK_index++] = SK[(Integer)SK_index++];
      RK[(Integer)RK_index++] = SK[(Integer)SK_index++];
      RK[(Integer)RK_index++] = SK[(Integer)SK_index++];
 
    }


 


 
    public static Long[] AESGetExpandedkeyDec(Long[] key, Long keysize)
    {
      CAESContext ctx = new CAESContext();
      AESSetKeyDec(ctx, key, keysize);
      return ctx.buf;
    }



 
    public static void AESSetKeyEnc(CAESContext ctx, Long[] key, Long keysize)
    {
      Integer i;


      Long[] RK;

      Long   NUMROUNDS = 10; 

      RK = ctx.buf;

      for (i = 0; i < (keysize >> 5); i++)
      {
        RK[i] = key[i];
      }

     if ( NUMROUNDS == 10)
     {
          for (i = 0; i < 10; i++)
          {
            RK[4 + (4 * i)] = (Long)(((((RK[0 + (4 * i)] ^ RCON[i]) ^ (FSb[(Integer)(RK[3 + (4 * i)] >> 8) & 255])) ^ 
            (FSb[(Integer)(RK[(3 + (4 * i))] >> 16) & 255] << 8))
             ^ (FSb[(Integer)(RK[3 + (4 * i)] >> 24) & 255] << 16)) ^ (FSb[(Integer)(RK[3 + (4 * i)]) & 255] << 24));

            RK[5 + (4 * i)] = RK[1 + (4 * i)] ^ RK[4 + (4 * i)];
            RK[6 + (4 * i)] = RK[2 + (4 * i)] ^ RK[5 + (4 * i)];
            RK[7 + (4 * i)] = RK[3 + (4 * i)] ^ RK[6 + (4 * i)];
          }
     }
     /*
     if ( NUMROUNDS == 12)
     {
          for (i = 0; i < 8; i++)
          {
            RK[6 + (6 * i)] = (Long)(((((RK[0 + (6 * i)] ^ RCON[i]) ^ (FSb[(Integer)(RK[5 + (6 * i)] >> 8) & 255])) ^ (FSb[(Integer)(RK[5 + (6 * i)] >> 16) & 255] << 8))
             ^ (FSb[(Integer)(RK[5 + (6 * i)] >> 24) & 255] << 16)) ^ (FSb[(Integer)(RK[5 + (6 * i)]) & 255] << 24));

            RK[7 + (6 * i)] = RK[1 + (6 * i)] ^ RK[6 + (6 * i)];
            RK[8 + (6 * i)] = RK[2 + (6 * i)] ^ RK[7 + (6 * i)];
            RK[9 + (6 * i)] = RK[3 + (6 * i)] ^ RK[8 + (6 * i)];
            RK[10 + (6 * i)] = RK[4 + (6 * i)] ^ RK[9 + (6 * i)];
            RK[11 + (6 * i)] = RK[5 + (6 * i)] ^ RK[10 + (6 * i)];
          }
      }

      if ( NUMROUNDS == 14)
      {
          for (i = 0; i < 7; i++)
          {
            RK[8 + (8 * i)] = (Long)(((((RK[0 + (8 * i)] ^ RCON[i]) ^ (FSb[(Integer)(RK[7 + (8 * i)] >> 8) & 255])) ^ (FSb[(Integer)(RK[7 + (8 * i)] >> 16) & 255] << 8))
             ^ (FSb[(Integer)(RK[7 + (8 * i)] >> 24) & 255] << 16)) ^ (FSb[(Integer)(RK[7 + (8 * i)]) & 255] << 24));

            RK[9 + (8 * i)] = RK[1 + (8 * i)] ^ RK[8 + (8 * i)];
            RK[10 + (8 * i)] = RK[2 + (8 * i)] ^ RK[9 + (8 * i)];
            RK[11 + (8 * i)] = RK[3 + (8 * i)] ^ RK[10 + (8 * i)];

            RK[12 + (8 * i)] = (Long)((((RK[4 + (8 * i)] ^ (FSb[(Integer)(RK[11 + (8 * i)]) & 255])) ^ (FSb[(Integer)(RK[11 + (8 * i)] >> 8) & 255] << 8))
             ^ (FSb[(Integer)(RK[11 + (8 * i)] >> 16) & 255] << 16)) ^ (FSb[(Integer)(RK[11 + (8 * i)] >> 24) & 255] << 24));

            RK[13 + (8 * i)] = RK[5 + (8 * i)] ^ RK[12 + (8 * i)];
            RK[14 + (8 * i)] = RK[6 + (8 * i)] ^ RK[13 + (8 * i)];
            RK[15 + (8 * i)] = RK[7 + (8 * i)] ^ RK[14 + (8 * i)];
          }
        }*/
      
    }



   public static void AESRROUND(Long[] RK, Long X0,  Long X1,  Long X2,  Long X3, Long Y0, Long Y1, Long Y2, Long Y3)
    {
      X0 = ((((RK[0] ^ RT0((Y0) & 255)) ^ RT1((Y3 >> 8) & 255)) ^ 
                         RT2((Y2 >> 16) & 255)) ^
                         RT3((Y1 >> 24) & 255));

      X1 = ((((RK[1] ^ RT0((Y1) & 255)) ^
                         RT1((Y0 >> 8) & 255)) ^
                         RT2((Y3 >> 16) & 255)) ^
                         RT3((Y2 >> 24) & 255));

      X2 = ((((RK[2] ^ RT0((Y2) & 255)) ^
                         RT1((Y1 >> 8) & 255)) ^
                         RT2((Y0 >> 16) & 255)) ^
                         RT3((Y3 >> 24) & 255));

      X3 = ((((RK[3] ^ RT0((Y3) & 255)) ^
                         RT1((Y2 >> 8) & 255)) ^
                         RT2((Y1 >> 16) & 255)) ^
                         RT3((Y0 >> 24) & 255));
    }

 
 
    /*
     * AES-ECB block encryption/decryption
     * ECB (Electronic Code Book) is non-chained (each block is separately
     * encrypted). This does not need an init vector (IV).
     */


    public static Integer[] CustomAESWithObfuscate(Long[] key, Integer[] uuid, date begindate, date enddate )
    { 
         system.debug('UUID+++' + uuid);
         Integer [] obfuscatedValues = Obfuscate(uuid,begindate,enddate);  
      /*  System.Debug('---------------------------my debug');
        DEBUG_PrintArray(obfuscatedValues);
        string sss = PrintStringChars(obfuscatedValues);
 System.Debug(' char array ----' + sss);
        Blob b = Blob.valueOf(sss); 
            System.Debug('blob.tostring--------------------' + b.toString());
      //  PrintStringChars(sss);
        System.Debug('--------blob b ' + b.size());
        Blob e = Crypto.encrypt('AES128', key, Blob.valueOf('7777777777777777'), 
                              b);
        System.Debug(e.size());
        System.Debug('-------------------<<<<<<<<< ' + Blob.valueOf('12345678').size());*/
      //  return e;
          return CustomAES( key,  eAES_MODE.AES_ENCRYPT,  obfuscatedValues );
   
    }


    public  static Integer[] Obfuscate(Integer[] uuidValues, date begindate, date enddate )
    {
        System.Debug('<::::::::::OBFUSCATING::::::::::>');
        Blob cryptoKey = Crypto.generateAesKey(128);
        
        String cryptoString =  EncodingUtil.base64Encode(cryptoKey) ;
        System.Debug('<::::::::::Calling Crypto.generateAesKey(128);::::::::::> cryptoString = ');
                     System.Debug(cryptoString);
 
         Integer bday  = begindate.day();         
         Integer bmon  = begindate.month();
         Integer byear = begindate.year()-2000;
         
         Integer eday  = enddate.day();
         Integer emon  = enddate.month();
         Integer eyear = enddate.year()-2000;         
     
        /*Integer [] uuidValues = new Integer[uuid.length()]; 
        for(Integer i=0; i< uuidValues.size();i++)
        {
            uuidValues [i] =  Character.toAscii(uuid.substring(i,i+1));
        }*/
        
        
        Integer [] obfuscatedValues = new Integer[16]; 
        for(Integer i=0; i< 16;i++)
        {
           obfuscatedValues [i] =  Character.toAscii(cryptoString.substring(i,i+1));
        }
        
        System.Debug('<::::::::::Converting crypto string ti Integer array::::::::::> obfuscatedValues = ');
        System.Debug(obfuscatedValues);

        // for testing purpose to match algoritm you can use statid hard coded list
         //obfuscatedValues = new Integer[] { 144,143,126,150,92,75,58,41,24,7,246,229,212,195,178,161 };
       //  obfuscatedValues = new Integer[] { 48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48};
                 
 
      DEBUG_PrintArray(obfuscatedValues);
      
         //1 keep the random byte
         
         //2 keep the random byte
          
          obfuscatedValues [2] =   uuidValues [0] ;  
         
          obfuscatedValues [3] =   (obfuscatedValues [3] & 224 ) | eyear;
         //4 keep the random byte
         
          obfuscatedValues [4] =   uuidValues [1] ;
          
 
         
         obfuscatedValues [5] =   (obfuscatedValues [5] & 224 ) | eday;
           
 
         obfuscatedValues [6] =   uuidValues [2] ;

 
         obfuscatedValues [7] =   (obfuscatedValues [7] & 240 ) | emon;
                 
 
         obfuscatedValues [8] =   uuidValues [3] ;
         
 
         obfuscatedValues [9] =  (obfuscatedValues [9] & 224) | byear;
         
 
         obfuscatedValues [10] =   uuidValues [4] ;
         
 
         obfuscatedValues [11] =   (obfuscatedValues [11] & 224) | bday;
         
 
         obfuscatedValues [12] =   uuidValues [5] ;
         
 
         obfuscatedValues [13] =   (obfuscatedValues [13] & 240 ) | bmon;
         
 
         obfuscatedValues [14] =   uuidValues [6] ;
         
 
         obfuscatedValues [15] =   uuidValues [7] ;
         
          
 DEBUG_PrintArray(obfuscatedValues);
 
        Integer checksum = 0;
        
         for(Integer k =2;k < 16;k++)
          {
           
              checksum +=  obfuscatedValues[k] ;
          }   
        System.Debug('Checksum' + checksum);
          
       Integer[] originalValue  = new Integer[4];
       for(Integer i=0; i< 1;i++)
       { 
        originalValue [3+(4*i)] =  (Integer) (checksum  /16777216) ; 
        originalValue [2+(4*i)] =  (Integer)((checksum  -  (originalValue [3+(4*i)] * 16777216.0 ))/65536)  ; 
        originalValue [1+(4*i)] =  (Integer) ((checksum   -  (originalValue [3+(4*i)] * 16777216.0 ) - (originalValue [2+(4*i)] * 65536.0) )/256) ; 
        originalValue [0+(4*i)] =  (Integer) ((checksum   -  (originalValue [3+(4*i)] * 16777216.0 ) - (originalValue [2+(4*i)] * 65536.0) - ( originalValue [1+(4*i)] * 256.0) )) ; 
       }
       
       obfuscatedValues[1] = originalValue[0];
        System.Debug('Obfuscated values');
       DEBUG_PrintArray(obfuscatedValues);
       Integer randRotate  = obfuscatedValues[0];
       
       for(Integer i=1; i< 16;i++)
       { 
               if ((randRotate & 1) == 1)
              {
                  randRotate = (randRotate >> 1) | 128;
              }
              else
                  randRotate = randRotate >> 1;             
           obfuscatedValues[i] = (((obfuscatedValues[i] ) ^ (obfuscatedValues[i-1])) ^ (randRotate));   
       }

       System.Debug('<::::::::::Obfuscated Integer Array Integer array::::::::::> cryptoString = '+obfuscatedValues);
       DEBUG_PrintArray(obfuscatedValues);
               return obfuscatedValues;
   
    }
    
    public static void DEBUG_PrintArray(Integer[] arr)
    {
        for(Integer i=0; i < arr.size(); i++)
        {
        System.Debug('-------------------------------> ' + arr[i]);
        }
    }
    
     public static void DEBUG_PrintArray(Long[] arr)
    {
        for(Integer i=0; i < arr.size(); i++)
        {
        System.Debug('-------------------------------> ' + arr[i]);
        }
    }
    
    public static Integer[] CustomAES(Long[] key, eAES_MODE mode, Integer[] inputValue)
    {
 
      System.Debug('<::::::::::CustomAES using Key and Obfuscated Input ::::::: key = '+key + '  :::::  Obfusscated value = '+inputValue);
      Long[] inputUintValue = new Long[4];
       
      DEBUG_PrintArray(key);
      
       for(Integer i=0; i< 4;i++)
       { 
            inputUintValue[0+i]  =  (inputValue[3+(4*i)] * 16777216)  +  (inputValue[2+(4*i)] * 65536)  + (inputValue[1+(4*i)]*256 )  + (inputValue[0+(4*i)] *1);         
       }

       Long[] outputValues =   AESCryptECB(  key,   mode,inputUintValue);
       
       System.Debug('<::::::::::AESCryptECB:::::: Value = '+outputValues);
     
     DEBUG_PrintArray(outputValues);
       
       Integer[] originalValue  = new Integer[16];
       for(Integer i=0; i< 4;i++)
       { 
        originalValue [3+(4*i)] =  (Integer) (outputValues [0+i] /16777216) ; 
        originalValue [2+(4*i)] =  (Integer)((outputValues [0+i] -  (originalValue [3+(4*i)] * 16777216.0 ))/65536)  ; 
        originalValue [1+(4*i)] =  (Integer) ((outputValues[0+i]  -  (originalValue [3+(4*i)] * 16777216.0 ) - (originalValue [2+(4*i)] * 65536.0) )/256) ; 
        originalValue [0+(4*i)] =  (Integer) ((outputValues[0+i]  -  (originalValue [3+(4*i)] * 16777216.0 ) - (originalValue [2+(4*i)] * 65536.0) - ( originalValue [1+(4*i)] * 256.0) )) ; 
       }
       
       System.Debug('<::::::::::FINAL ENCRYPTION:::::: Value = '+originalValue);
       DEBUG_PrintArray(originalValue);
      return originalValue ;
    }
   

    public static Long [] AESCryptECB(Long[] key, eAES_MODE mode, Long[] input)
    {
      //for(Long i = 0; i < 4; i++)
      //{
      //  output[i] = input[i];
      //}
      //return;



      Long X0, X1, X2, X3, Y0 = 0, Y1 = 0, Y2 = 0, Y3 = 0;
 
      Long[] RK;
 
      Long[] tmp_key_array = new Long[4];

      CAESContext ctx = new CAESContext();



      if (mode == eAES_MODE.AES_ENCRYPT)
      {
        AESSetKeyEnc(ctx, key, 128);
      }
      else
      {
        AESSetKeyDec(ctx, key, 128);
      }

      RK = ctx.buf;

 
      X0 = (input[0]);
      X0 ^= RK[0];
 
      X1 = input[1];
      X1 ^= RK[1];
 
      X2 =  input[2];
      X2 ^= RK[2];
 
      X3 = input[3];
      X3 ^= RK[3];

      if (mode == eAES_MODE.AES_ENCRYPT)
      {
        for (Integer i = 1; i < 9; i += 2)
        {
          tmp_key_array[0] = RK[i * 4];
          tmp_key_array[1] = RK[i * 4 + 1];
          tmp_key_array[2] = RK[i * 4 + 2];
          tmp_key_array[3] = RK[i * 4 + 3];
          RefObject  tempRef_Y0 = new RefObject(Y0);
          RefObject tempRef_Y1 = new RefObject(Y1);
          RefObject tempRef_Y2 = new RefObject(Y2);
          RefObject tempRef_Y3 = new RefObject(Y3);
          AESFROUND(tmp_key_array, tempRef_Y0, tempRef_Y1, tempRef_Y2, tempRef_Y3, X0, X1, X2, X3);
          Y0 = tempRef_Y0.argvalue;
          Y1 = tempRef_Y1.argvalue;
          Y2 = tempRef_Y2.argvalue;
          Y3 = tempRef_Y3.argvalue;

          tmp_key_array[0] = RK[i * 4 + 4];
          tmp_key_array[1] = RK[i * 4 + 5];
          tmp_key_array[2] = RK[i * 4 + 6];
          tmp_key_array[3] = RK[i * 4 + 7];
          RefObject tempRef_X0 = new RefObject(X0);
          RefObject tempRef_X1 = new RefObject(X1);
          RefObject tempRef_X2 = new RefObject(X2);
          RefObject tempRef_X3 = new RefObject(X3);
          AESFROUND(tmp_key_array, tempRef_X0, tempRef_X1, tempRef_X2, tempRef_X3, Y0, Y1, Y2, Y3);
          X0 = tempRef_X0.argvalue;
          X1 = tempRef_X1.argvalue;
          X2 = tempRef_X2.argvalue;
          X3 = tempRef_X3.argvalue;
        }
        tmp_key_array[0] = RK[36];
        tmp_key_array[1] = RK[37];
        tmp_key_array[2] = RK[38];
        tmp_key_array[3] = RK[39];
        RefObject tempRef_Y02 = new RefObject(Y0);
        RefObject tempRef_Y12 = new RefObject(Y1);
        RefObject tempRef_Y22 = new RefObject(Y2);
        RefObject tempRef_Y32 = new RefObject(Y3);
        AESFROUND(tmp_key_array, tempRef_Y02, tempRef_Y12, tempRef_Y22, tempRef_Y32, X0, X1, X2, X3);
        Y0 = tempRef_Y02.argvalue;
        Y1 = tempRef_Y12.argvalue;
        Y2 = tempRef_Y22.argvalue;
        Y3 = tempRef_Y32.argvalue;


 
        X0 = ((((RK[40] ^ (FSb[(Integer)(Y0) & 255])) ^ (Long)(FSb[(Integer)(Y1 >> 8) & 255] << 8)) ^ (Long)(FSb[(Integer)(Y2 >> 16) & 255] << 16)) ^ (Long)(FSb[(Integer)(Y3 >> 24) & 255] << 24));

        X1 = RK[41];
        X1 ^= (FSb[(Integer)(Y1) & 255]);

 
        X1 ^= (Long)(FSb[(Integer)(Y2 >> 8) & 255] << 8);

 
        X1 ^= (Long)(FSb[(Integer)(Y3 >> 16) & 255] << 16);

 
        X1 ^= (Long)(FSb[(Integer)(Y0 >> 24) & 255] << 24);


 
        X2 = (((( RK[42] ^ (FSb[(Integer)(Y2) & 255])) ^ (Long)(FSb[(Integer)(Y3 >> 8) & 255] << 8)) ^ (Long)(FSb[(Integer)(Y0 >> 16) & 255] << 16)) ^ (Long)(FSb[(Integer)(Y1 >> 24) & 255] << 24));


 
        X3 = ((((RK[43] ^ (FSb[(Integer)(Y3) & 255])) ^ (Long)(FSb[(Integer)(Y0 >> 8) & 255] << 8)) ^ (Long)(FSb[(Integer)(Y1 >> 16) & 255] << 16)) ^ (Long)(FSb[(Integer)(Y2 >> 24) & 255] << 24));
      }
      else // AES_DECRYPT
      {
        for (Integer i = 1; i < 9; i += 2)
        {
          tmp_key_array[0] = RK[i * 4];
          tmp_key_array[1] = RK[i * 4 + 1];
          tmp_key_array[2] = RK[i * 4 + 2];
          tmp_key_array[3] = RK[i * 4 + 3];
          RefObject tempRef_Y03 = new RefObject(Y0);
          RefObject tempRef_Y13 = new RefObject(Y1);
          RefObject tempRef_Y23 = new RefObject(Y2);
          RefObject tempRef_Y33 = new RefObject(Y3);
          AESRROUND(tmp_key_array, tempRef_Y03, tempRef_Y13, tempRef_Y23, tempRef_Y33, X0, X1, X2, X3);
          Y0 = tempRef_Y03.argvalue;
          Y1 = tempRef_Y13.argvalue;
          Y2 = tempRef_Y23.argvalue;
          Y3 = tempRef_Y33.argvalue;

          tmp_key_array[0] = RK[i * 4 + 4];
          tmp_key_array[1] = RK[i * 4 + 5];
          tmp_key_array[2] = RK[i * 4 + 6];
          tmp_key_array[3] = RK[i * 4 + 7];
          RefObject tempRef_X02 = new RefObject(X0);
          RefObject tempRef_X12 = new RefObject(X1);
          RefObject tempRef_X22 = new RefObject(X2);
          RefObject tempRef_X32 = new RefObject(X3);
          AESRROUND(tmp_key_array, tempRef_X02, tempRef_X12, tempRef_X22, tempRef_X32, Y0, Y1, Y2, Y3);
          X0 = tempRef_X02.argvalue;
          X1 = tempRef_X12.argvalue;
          X2 = tempRef_X22.argvalue;
          X3 = tempRef_X32.argvalue;
        }

        tmp_key_array[0] = RK[36];
        tmp_key_array[1] = RK[37];
        tmp_key_array[2] = RK[38];
        tmp_key_array[3] = RK[39];
        RefObject tempRef_Y04 = new RefObject(Y0);
        RefObject tempRef_Y14 = new RefObject(Y1);
        RefObject tempRef_Y24 = new RefObject(Y2);
        RefObject tempRef_Y34 = new RefObject(Y3);
        AESRROUND(tmp_key_array, tempRef_Y04, tempRef_Y14, tempRef_Y24, tempRef_Y34, X0, X1, X2, X3);
        Y0 = tempRef_Y04.argvalue;
        Y1 = tempRef_Y14.argvalue;
        Y2 = tempRef_Y24.argvalue;
        Y3 = tempRef_Y34.argvalue;


 
        X0 = ((((RK[40] ^ (RSb[(Integer)(Y0) & 255])) ^ (Long)(RSb[(Integer)(Y3 >> 8) & 255] << 8)) ^ (Long)(RSb[(Integer)(Y2 >> 16) & 255] << 16)) ^ (Long)(RSb[(Integer)(Y1 >> 24) & 255] << 24));


 
        X1 = ((((RK[41] ^ (RSb[(Integer)(Y1) & 255])) ^ (Long)(RSb[(Integer)(Y0 >> 8) & 255] << 8)) ^ (Long)(RSb[(Integer)(Y3 >> 16) & 255] << 16)) ^ (Long)(RSb[(Integer)(Y2 >> 24) & 255] << 24));


 
        X2 = ((((RK[42] ^ (RSb[(Integer)(Y2) & 255])) ^ (Long)(RSb[(Integer)(Y1 >> 8) & 255] << 8)) ^ (Long)(RSb[(Integer)(Y0 >> 16) & 255] << 16)) ^ (Long)(RSb[(Integer)(Y3 >> 24) & 255] << 24));


 
        X3 =((((( RK[43] ^ (RSb[(Integer)(Y3) & 255]))^ (Long)(RSb[(Integer)(Y2 >> 8) & 255] << 8)) ^ (Long)(RSb[(Integer)(Y1 >> 16) & 255] << 16))) ^ (Long)(RSb[(Integer)(Y0 >> 24) & 255] << 24));
      }
      
     Long[] output = new Long[4];

      output[0] = X0;
      output[1] = X1;
      output[2] = X2;
      output[3] = X3;
      
      return output;
      /*System.BitConverter.GetBytes(X0).CopyTo(output, 0);
      System.BitConverter.GetBytes(X1).CopyTo(output, 4);
      System.BitConverter.GetBytes(X2).CopyTo(output, 8);
      System.BitConverter.GetBytes(X3).CopyTo(output, 12);*/

    }
  


    public static string StandardApexDecrypt(string encryptedString) {
    
    Blob decryptedData = Crypto.decryptWithManagedIV('AES128', getKey(), EncodingUtil.base64Decode(encryptedString));
        return decryptedData.toString();
    }
    
    
    public static string StandardApexEncrypt(string plainString) {
        Blob cryptoKey = Crypto.generateAesKey(128);
        Blob encryptedData = null;
        Crypto.encrypt('AES128', getKey(), Blob.valueOf(plainString),encryptedData );
        return EncodingUtil.base64Encode(encryptedData);
    }
    
    public static Blob getKey() {
     
        return   Blob.valueOf('7777777777777777');
    }
    
    public static List<Integer> stringToCodePoint(String input) 
    {       
        list<Integer> charList = new list<Integer>();
        
        for(Integer i=0; i< input.length(); i++)
        {
            charList.add( Character.toAscii(input.substring(i,i+1)) );
        }   
        return charList;
    }
    
    
 public static  Integer [] HexStringToCodePoint(String input) 
    {       
        list<Integer> charList = new list<Integer>();
        
        for(Integer i=0; i< input.length()/2; i++)
        {
        
             string hex   =      input.substring(2 * i, 2 * i + 2).toUpperCase(); 
              for(Integer k=0; k < 256;k++)
              
                {
                   if( HexStringValues[k] == hex)
                   
                    {
                       charList.Add(k);
                       
                       break;
                    }                
               }                       
        } 
          Integer [] reverseList = new  Integer[charList.size()] ;
          for(Integer i=0; i< charList .size(); i++)
        {
           reverseList[charList .size() -1 -i] = charList[i];
        }
        return reverseList;
    }


    
 public static  String IntArrayToHexString(list<Integer> intList ) 
    {        
    String hexString = '';
        
        for(Integer i:intList)
        {
        //   hexString  =  HexStringValues[i] + hexString ;                                  
            hexString  = hexString + HexStringValues[i]  ;                                  
        } 
           
        return hexString  ;
    }

    

    public static String PrintStringChars(Integer[] ar)
    {
        Integer[] newarr = new Integer[]{63000,0,0,0,0,0,0,0};        
        for(Integer i=0; i< 8; i++)
        {
               // newarr[i] = ar[i * 2] + (ar[(i * 2) + 1] * 256);
                System.Debug('--------------------------------- PrintStringChars');
           DEBUG_PrintArray( newarr);
        }   
            
            
            return String.fromCharArray(newarr); 
        }

}