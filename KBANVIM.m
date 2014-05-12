KBANVIM(RN) ; VEN/SMH - Use VIM Editor on Cache ; 4/29/14 4:51pm
 G EN+1
 ;
EN(RN) ; Public Entry point
 LOCK +@RN:0 E  WRITE "Somebody else is editing this right now" QUIT
 ;
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
 N % S %=$ZF(-1,"vim "_$$DEFDIR^%ZISH()_RN_".m")
 I %'=0 WRITE "Vim exited abnormally... quitting..."
 ;
 ;
 ;
 N NEWRTN
 D OPEN^%ZISH(RN,$$DEFDIR^%ZISH(),RN_".m","R")
 I POP WRITE "CANNOT OPEN FILE "_RN_" IN "_$$DEFDIR^%ZISH() QUIT
 N X,I S I=0
 USE IO
 F  R X:1  Q:$$STATUS^%ZISH()  S I=I+1,NEWRTN(I,0)=X
 D CLOSE^%ZISH(RN)
 ;
 ;
 ;
 K ^TMP($J) M ^TMP($J)=NEWRTN
 N DIE,X,XCN S DIE="^TMP($J,",X=RN,XCN=0
 X ^%ZOSF("SAVE")
 ;
 W "Saved routine "_RN,!
 ;
 N A S A(RN_".m")=""
 N % S %=$$DEL^%ZISH($$DEFDIR^%ZISH(),$NA(A))
 ;
 ;
 LOCK -@RN
 QUIT
