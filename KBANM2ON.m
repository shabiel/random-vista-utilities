KBANM2ON ;VEN/SMH - Import .m to Cache;5/3/2014
 ;;0.1;SAM'S INDUSTRIAL CONGLOMERATES;
 ;
 G EN1
EN(PATH) ; Entry Point
EN1 ; Interactive entry point
 N DONE
 I '$D(PATH) N PATH D
 . WRITE "Enter Path: "
 . ;
 . ;  Get old Path from last session
 . N PATHOLD
 . I $G(DUZ)>0,$D(^DISV(DUZ,$T(+0)))#2 S PATHOLD=^($T(+0)) W PATHOLD,"//"
 . ;
 . ; Read
 . ; ZEXCEPT: DTIME
 . READ PATH:$G(DTIME,300)
 . ELSE  S DONE=1 QUIT  ; Timeout
 . ;
 . ; Nothing entered
 . I PATH="" S PATH=PATHOLD
 . K PATHOLD
 . ;
 . I $G(DUZ)>0 S ^DISV(DUZ,$T(+0))=PATH
 . ;
 ;
 QUIT:$G(DONE)   ; *** QUIT ***
 ;
 N D S D=$S($ZVERSION(1)=2:"\",1:"/") ; Delimiter
 I $E(PATH,$L(PATH))'=D S PATH=PATH_D  ; Add delimiter if necessary
 N FILES
 N ZSEARCH S ZSEARCH=PATH_"*.m"
 N %F S %F=$ZSEARCH(ZSEARCH)
 QUIT:%F=""
 N CNT S CNT=1
 S FILES(CNT)=%F,CNT=CNT+1
 F  S %F=$ZSEARCH("") Q:%F=""  S FILES(CNT)=%F,CNT=CNT+1
 ;
 ;
 ; Now load each of the files into Cache, recompliering along...
 N %I F %I=0:0 S %I=$O(FILES(%I)) Q:'%I  D
 . ;
 . N FULLPATH S FULLPATH=FILES(%I)
 . N ROUTINENAME S ROUTINENAME=$P(FULLPATH,D,$L(FULLPATH,D)) ; Get last piece
 . D ASSERT($E(ROUTINENAME,$L(ROUTINENAME-1),$L(ROUTINENAME))=".m") ; Make sure we still have .m
 . S ROUTINENAME=$E(ROUTINENAME,1,$L(ROUTINENAME)-2)  ; Strip .m
 . S ROUTINENAME=$TR(ROUTINENAME,"_","%") ; Change _ to %
 . D SAVERTN(FULLPATH,ROUTINENAME) ; Save routine (read from FS and save)
 QUIT
 ;
SAVERTN(FULLPATH,RTNNAME) ; Save routine call
 N % S %=$ZUTIL(68,40,1) K % ; Work like DSM with $ZEOF.
 O FULLPATH:"R" ; Read mode
 U FULLPATH
 N RTNCODE,L
 S L=1
 N X
 F  R X:1 Q:$ZEOF  S RTNCODE(L)=X,L=L+1
 S RTNCODE(0)=L-1
 U $P C FULLPATH
 N ERR
 WRITE "LOADING "_RTNNAME,!
 D ROUTINE^%R(RTNNAME_".INT",.RTNCODE,.ERR,"CS",0)
 I $L(ERR) ZWRITE ERR
 QUIT
 ;
ASSERT(X,Y) ; Primitive Assertion Engine
 I 'X N %IO S %IO=$IO U $P W $G(Y) U %IO
 QUIT
 ;
