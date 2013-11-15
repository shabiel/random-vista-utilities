KBANTCLN ; VEN/SMH - Clean Taskman Environment ;2013-11-15  1:36 PM
 ;;nopackage;0.1
 ; License: Public Domain
 ; Author not responsible for use of this routine.
 ; Author coyly recommends not using this on production accounts.
 ;
 ; This routine cleans up Taskman globals for a new environment.
 ;
 I $$PROD^XUPROD() W "PRODUCTION SYSTEM. WILL NOT RUN.",! QUIT
 ;
START ;
 D ^ZTMGRSET
 D ^DINIT
 ;
CONST ; Constant Integers
 N KMAXJOB S KMAXJOB=30  ; Maximum M processes on the system
 ;
ENV ; We get environment variables here.
 S U="^"
 ;
 N Y D GETENV^%ZOSV ; Y=UCI^VOL^NODE^BOX LOOKUP
 N UCI S UCI=$P(Y,U)
 N VOL S VOL=$P(Y,U,2)
 N NODE S NODE=$P(Y,U,3) ; Cache Namespace on Cache; hostname on GT.M.
 N BOX S BOX=$P(Y,U,4) ; VOL:NODE
 ;
KSP ; Kernel System Parameters cleanup. Fall through.
 N KBANI S KBANI=0
 N GREFC S GREFC=$$ROOT^DILFD(8989.304,",1,",1) ; Closed File Root for Volume Multiple
 N GREFO S GREFO=$$ROOT^DILFD(8989.304,",1,",0) ; Open File Root for Volume Multiple
 F  S KBANI=$O(@GREFC@(KBANI)) Q:'KBANI  D
 . N DA,DIK S DA(1)=1,DA=KBANI,DIK=GREFO D ^DIK ; Kill each entry in Vol subfile
 ;
 ; DEBUG.ASSERT - Make sure that the file is empty
 I $D(@GREFC)#10 S $EC=",U1,"
 ; DEBUG.ASSERT
 ;
 N KBANFDA
 S KBANFDA(8989.304,"+1,1,",.01)=VOL
 S KBANFDA(8989.304,"+1,1,",2)=30 ; 30 jobs by default.
 ;
 N KBANERR ; For errors
 D UPDATE^DIE("E",$NA(KBANFDA),"",$NA(KBANERR)) ; File data
 I $D(KBANERR) S $EC=",U1," ; if error filing, crash
 ;
F14P5 ; 14.5 clean-up. Fall through.
 D KF(14.5) ; Bye bye file 14.5
 ;
 N KBANFDA
 S KBANFDA(14.5,"+1,",.01)=VOL ; Volume Set
 S KBANFDA(14.5,"+1,",.1)="GENERAL PURPOSE VOLUME SET" ; Type
 S KBANFDA(14.5,"+1,",1)="NO"  ; Inhibit Logons?
 S KBANFDA(14.5,"+1,",2)=""    ; Link Access?
 S KBANFDA(14.5,"+1,",3)="NO"  ; Out of Service?
 S KBANFDA(14.5,"+1,",4)="NO"  ; Required Volume Set
 S KBANFDA(14.5,"+1,",5)=UCI   ; Taskman Files UCI
 S KBANFDA(14.5,"+1,",6)=""   ; Taskman Files Volume Set
 S KBANFDA(14.5,"+1,",7)=""    ; Replacement Volume Set
 S KBANFDA(14.5,"+1,",8)=0     ; Days to keep old tasks
 S KBANFDA(14.5,"+1,",9)="Yes" ; Signon/Production Volume Set
 ;
 N KBANERR ; For errors
 D UPDATE^DIE("E",$NA(KBANFDA),"",$NA(KBANERR)) ; File data
 I $D(KBANERR) S $EC=",U1," ; if error filing, crash
 ;
F14P6 ; 14.6 clean-up. Fall through
 ; Unfortunately, there is a nasty DIC("S") on the input transform that doesn't
 ; work with the updater, but works with ^DIC. We avoid that by entering internal
 ; values only.
 D KF(14.6) ; Bye bye file 14.6
 ;
 N KBANFDA
 S KBANFDA(14.6,"+1,",.01)=UCI  ; From UCI
 S KBANFDA(14.6,"+1,",1)=1 ; From Volume Set (pointer) (created above)
 S KBANFDA(14.6,"+1,",2)="" ; To Volume Set (pointer) 
 S KBANFDA(14.6,"+1,",3)="" ; To UCI
 ;
 N KBANERR ; For errors
 D UPDATE^DIE("",$NA(KBANFDA),"",$NA(KBANERR)) ; File data (Internal Format)
 I $D(KBANERR) S $EC=",U1," ; if error filing, crash
 ;
F14P7 ; 14.7 clean-up. Fall through
 D KF(14.7) ; Bye bye file 14.7
 ;
 N KBANFDA
 S KBANFDA(14.7,"+1,",.01)=BOX    ;BOX-VOLUME PAIR (RF), [0;1]
 S KBANFDA(14.7,"+1,",1)=""       ;RESERVED (S), [0;2]
 S KBANFDA(14.7,"+1,",2)=""       ;LOG TASKS? (S), [0;3]
 S KBANFDA(14.7,"+1,",3)=""       ;DEFAULT TASK PRIORITY (NJ2,0), [0;4]
 S KBANFDA(14.7,"+1,",4)=""       ;TASK PARTITION SIZE (NJ3,0), [0;5]
 S KBANFDA(14.7,"+1,",5)=0        ;SUBMANAGER RETENTION TIME (NJ3,0), [0;6] TODO: Better values for Cache
 S KBANFDA(14.7,"+1,",6)=.80*$$KRNMAXJ(VOL)\1      ;TASKMAN JOB LIMIT (RNJ4,0), [0;7] 80 % OF Kernel Job Limit
 S KBANFDA(14.7,"+1,",7)=0        ;TASKMAN HANG BETWEEN NEW JOBS (NJ2,0), [0;8]
 S KBANFDA(14.7,"+1,",8)="G"      ;MODE OF TASKMAN (RS), [0;9]
 S KBANFDA(14.7,"+1,",9)=""       ;VAX ENVIROMENT FOR DCL (F), [0;10]
 S KBANFDA(14.7,"+1,",10)=""      ;OUT OF SERVICE (RS), [0;11]
 S KBANFDA(14.7,"+1,",11)=0       ;MIN SUBMANAGER CNT (NJ2,0), [0;12]
 S KBANFDA(14.7,"+1,",12)=""      ;TM MASTER (P14.7'), [0;13]
 S KBANFDA(14.7,"+1,",13)=""      ;Balance Interval (NJ3,0), [0;14]
 S KBANFDA(14.7,"+1,",21)=""      ;LOAD BALANCE ROUTINE (F), [2;E1,75]
 S KBANFDA(14.7,"+1,",31)=1       ;Auto Delete Tasks (S), [3;1]
 S KBANFDA(14.7,"+1,",32)=1       ;Manager Startup Delay (NJ3,0), [3;2]
 ;
 N KBANERR ; For errors
 D UPDATE^DIE("",$NA(KBANFDA),"",$NA(KBANERR)) ; File data (Internal Format)
 I $D(KBANERR) S $EC=",U1," ; if error filing, crash
 ;
ZTSK  K ^%ZTSK  ; ^%ZTSK clean-up
ZTSCH K ^%ZTSCH ; ^%ZTSCH clen-up
 ;
F19P2 ; 19.2 clean-up; Fall through.
 N GREFC S GREFC=$$ROOT^DILFD(19.2,"",1) ; Closed File Root for Option Scheduling
 N GREFO S GREFO=$$ROOT^DILFD(19.2,"",0) ; Open File Root for Option Scheduling
 ;
 ; Walk through entries
 N KBANI S KBANI=0
 F  S KBANI=$O(@GREFC@(KBANI)) Q:'KBANI  D
 . N DA,DIK S DA=KBANI,DIK=GREFO D ^DIK ; Kill each entry
 ;
 N KBANI,OPT
 N KBANFDA
 F KBANI=1:1 S OPT=$T(F19P2OPT+KBANI) Q:$P(OPT,";;",2)="<<END>>"  D
 . N NODE S NODE=$P(OPT,";;",2)    ; Node
 . N OS S OS=$P(NODE,U,4)          ; M VM (Open-NT or GT.M)
 . I $L(OS),^%ZOSF("OS")'[OS QUIT  ; If OS is defined and it's not ours, quit
 . ;
 . N NAME S NAME=$P(NODE,U)
 . N STARTUP,TIME
 . D
 . . N N2 S N2=$P(NODE,U,2)
 . . S STARTUP=$S(N2="S":"STARTUP",1:"")
 . . S TIME=$S(N2'="S":N2,1:"")
 . ;
 . N RESCHFREQ S RESCHFREQ=$P(NODE,U,3)
 . N OS S OS=$P(NODE,U,4)
 . ;
 . S KBANFDA(19.2,"+"_KBANI_",",.01)=NAME       ; NAME (R*P19'), [0;1]
 . S KBANFDA(19.2,"+"_KBANI_",",2)=TIME         ; QUEUED TO RUN AT WHAT TIME (DX), [0;2]
 . S KBANFDA(19.2,"+"_KBANI_",",6)=RESCHFREQ    ; RESCHEDULING FREQUENCY (FX), [0;6]
 . S KBANFDA(19.2,"+"_KBANI_",",9)=$G(STARTUP)  ; SPECIAL QUEUEING (SX), [0;9]
 ;
 N KBANERR ; For errors
 D UPDATE^DIE("E",$NA(KBANFDA),"",$NA(KBANERR)) ; File data (External Format)
 I $D(KBANERR) S $EC=",U1," ; if error filing, crash
 ;
DEV ; Device File Clean-up
 ; Delete Volume field for each device.
 N KBANI S KBANI=0
 N KBANFDA
 F  S KBANI=$O(^%ZIS(1,KBANI)) Q:'KBANI  S KBANFDA(3.5,KBANI_",",1.9)="@"
 N KBANERR
 D FILE^DIE("",$NA(KBANFDA),$NA(KBANERR))
 I $D(KBANERR) S $EC=",U1,"
 ;
MSP ; Mailman Site Parameters Clean-up
 N KBANFDA S KBANFDA(4.3,"1,",7.5)="@" ; CPU/VOL in MSP
 N KBANERR
 D FILE^DIE("",$NA(KBANFDA),$NA(KBANERR))
 I $D(KBANERR) S $EC=",U1,"
 ;
END QUIT  ; THE END
 ;
 ;
 ;
F19P2OPT ; Map: Option Name; Startup or time to schedule; resched freq; OS-specific
 ;;XMRONT^S^^OpenM
 ;;XWB LISTENER STARTER^S^^OpenM
 ;;XUSER-CLEAR-ALL^S
 ;;XUDEV RES-CLEAR^S
 ;;XU PROC CNT CLUP^N+5'^1H^GT.M
 ;;XMAUTOPURGE^T+1@0010^1D
 ;;XMCLEAN^T+1@0015^1D
 ;;XQBUILDTREEQUE^T+1@0020^1D
 ;;XQ XUTL $J NODES^T+1@0025^1D
 ;;XUERTRP AUTO CLEAN^T+1@0030^1D
 ;;XUTM QCLEAN^T+1@0035^1D
 ;;<<END>>
KF(FN,IENS) ; Kill File; Private Procedure
 ; FN = File Number; pass by value. Required.
 ; IENS = IENs; pass by value. Optional.
 ; NB: Will not work for files under ^DIC as this deletes their definition as well
 N GREF S GREF=$$ROOT^DILFD(FN,$G(IENS),1) ; Close File Root
 Q:GREF["^DIC"  ; Don't delete files stored in ^DIC
 Q:GREF=""      ; No invalid files.
 N % S %=@GREF@(0) ; Save off zero node
 S $P(%,U,3,4)="" ; remove last touched and newest record markers
 K @GREF ; bye
 S @GREF@(0)=% ; restore zero node
 QUIT
KRNMAXJ(VOL) ; Max Jobs on this volume in the Kernel; Private $$
 N X S X=$O(^XTV(8989.3,1,4,"B",VOL,0))
 N J S J=$S(X>0:^XTV(8989.3,1,4,X,0),1:"ROU^^1")
 Q $P(J,U,3)
