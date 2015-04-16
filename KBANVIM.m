KBANVIM(RN,RO) ; VEN/SMH - Use VIM Editor on Cache ; 4/29/14 4:51pm
 G EN+1
R(RN) D KBANVIM(RN,1) QUIT  ; Read Only
EN(RN,RO) ; Public Entry point
 I $G(RN)="" B
 LOCK +@RN:0 E  WRITE "Somebody else is editing this right now" QUIT
 S RO=$G(RO,0)
 ;
 N POP
 D OPEN^%ZISH(RN,$$DEFDIR^%ZISH(),RN_".m","W")
 I POP WRITE "CANNOT OPEN FILE "_RN_" IN "_$$DEFDIR^%ZISH() QUIT
 ;
 ;
 USE IO
 N LN,LN0
 N I F I=1:1 S LN=$T(+I^@RN) Q:'$L(LN)  W LN,!
 ;
 ;
 ;
 D CLOSE^%ZISH(RN)
 ;
 ;
 N % S %=$ZF(-1,"vim "_$S(RO:"-R ",1:"")_$$DEFDIR^%ZISH()_RN_".m")
 I %'=0 WRITE "Vim exited abnormally... quitting..."
 ;
 ;
 ;
 I 'RO D
 . N NEWRTN
 . D OPEN^%ZISH(RN,$$DEFDIR^%ZISH(),RN_".m","R")
 . I POP WRITE "CANNOT OPEN FILE "_RN_" IN "_$$DEFDIR^%ZISH() QUIT
 . N X,I S I=0
 . USE IO
 . F  R X:1  Q:$$STATUS^%ZISH()  S I=I+1,NEWRTN(I,0)=X
 . D CLOSE^%ZISH(RN)
 . ;
 . I $G(NEWRTN(1,0))="" QUIT
 . ;
 . ;
 . ;
 . K ^TMP($J) M ^TMP($J)=NEWRTN
 . N DIE,X,XCN S DIE="^TMP($J,",X=RN,XCN=0
 . X ^%ZOSF("SAVE")
 . ;
 . W "Saved routine "_RN,!
 . ;
 . N A S A(RN_".m")=""
 . N % S %=$$DEL^%ZISH($$DEFDIR^%ZISH(),$NA(A))
 . ;
 . K ^TMP($J)
 . D 
 . . N RTN S RTN=RN
 . . N RN
 . . D CHKROU^XTECROU($NA(^TMP($J)),RTN,RTN)
 . . W !
 . . N I F I=0:0 S I=$O(^TMP($J,I)) Q:'I  W ^(I),!
 . ;
 K ^TMP($J)
 LOCK -@RN
 QUIT
