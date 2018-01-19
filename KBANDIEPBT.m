KBANDIEPBT ; OSE/SMH - Input, Print, and Sort Template Analysis;2018-01-19  5:09 PM
 ;;0.1;OSEHRA;
 ;
 ; This routine finds non-self files that are pointed to by a template
 ; 
DIBT ; [Public] Sort template analysis
 ; place to output
 n outputData
 d DIBTCOL(.outputData)
 d DIBTOUT(.outputData,"/tmp/","DIBTOUT.csv")
 quit
 ;
DIET ; [Public] Input template analysis
 n outputData
 d DIETCOL(.outputData)
 d DIETOUT(.outputData,"/tmp/","DIETOUT.csv")
 ; 1) ^DIE(2327,0) = SAM TEST^3180119.1701^@^200^1^@^3180119
 ; 2) ^DIE(2327,"DIAB",3,0,200,0) = TITLE:
 ; 3) ^DIE(2327,"DR",1,200) = .01;9;^3.1^DIC(3.1,^^S I(0,0)=D0 S Y(1)=$S($D(^VA(200,D0,0)):^(0),1:"") S X=$P(Y(1),U,9),X=X  S D(0)=+X S X=$S(D(0)>0:D(0),1:"");
 ; 4) ^DIE(2327,"DR",2,3.1) = .01;
 quit
 ;
 ; for each template
DIBTCOL(outputData) ; [Private]
 n dibt f dibt=0:0 s dibt=$o(^DIBT(dibt)) q:'dibt  d
 . quit:'$data(^DIBT(dibt,0))                 ; get valid ones only
 . new name s name=$p(^DIBT(dibt,0),U)
 . new file s file=$p(^DIBT(dibt,0),U,4)
 . n isSort s isSort=$order(^DIBT(dibt,2,0))  ; make sure they are sort templates
 . if 'isSort quit
 . ;
 . ; walk through each field
 . n line f line=0:0 s line=$order(^DIBT(dibt,2,line)) quit:'line  do
 .. n lineData ; We have some variances on how the data is stored (lines below)
 .. i $d(^(line))#2   s lineData=^DIBT(dibt,2,line)
 .. i $d(^(line,0))#2 s lineData=^DIBT(dibt,2,line,0)
 .. ;
 .. ; some vital data
 .. n lineFile s lineFile=$piece(lineData,U)
 .. i '$data(^DD(lineFile)) quit  ; bad DD
 .. n lineField s lineField=$piece(lineData,U,2)
 .. n lineFieldSpec s lineFieldSpec=$p(lineData,U,3)
 .. ;
 .. ; if it's the same file, and not a relational field, we are not interested
 .. i lineFile=file,lineField'[":" quit
 .. ;
 .. ; if the parent is the same file, and ditto, we are still not interested
 .. i $$PARENT(lineFile)=file,lineField'[":" quit
 .. ;
 .. ; We are interested
 .. ; Do we have the field?
 .. i lineField="" do
 ... ; no we don't so get the fields using DICOMP
 ... n X
 ... d EXPR^DICOMP(lineFile,"dmFITSL",lineFieldSpec)
 ... i '$d(X) quit
 ... ; X("USED")="404.51^.07;404.57^.02"
 ... i X("USED")="" quit  ; not an expression that uses fields
 ... n pairs,pair f pairs=1:1:$l(X("USED"),";") d
 .... s pair=$p(X("USED"),";",pairs)
 .... n thisFile  s thisFile=$p(pair,U,1)
 .... n thisField s thisField=$p(pair,U,2)
 .... s outputData(file,thisFile,thisField)=dibt_U_name
 .. e  s outputData(file,lineFile,lineField)=dibt_U_name
 quit
 ;
DIBTOUT(outputData,outputPath,outputFile) ; [Private] Export the data
 n POP
 d OPEN^%ZISH("file1",outputPath,outputFile,"W")
 i POP quit
 u IO
 n file,dstFile,dstField,dibtIEN,dibtName
 n c s c=","
 w "SORT TEMPALTE IEN,SORT TEMPLATE NAME,SOURCE FILE,DESTINATION FILE,DESTINATION FIELD",!
 f file=0:0 s file=$o(outputData(file)) q:'file  d
 . f dstFile=0:0 s dstFile=$o(outputData(file,dstFile)) q:'dstFile  d
 .. f dstField=0:0 s dstField=$o(outputData(file,dstFile,dstField)) q:'dstField  d
 ... n data s data=outputData(file,dstFile,dstField)
 ... s dibtIEN=$p(data,U,1)
 ... s dibtName=$p(data,U,2)
 ... w dibtIEN_c_dibtName_c_file_c_dstFile_c_dstField,!
 d CLOSE^%ZISH("file1")
 quit
 ;
PARENT(subfile) ; [Private] Find out who my parent is
 ; WARNING: Recursive algorithm
 if $data(^DD(subfile,0,"UP")) quit $$PARENT(^("UP"))
 quit subfile
