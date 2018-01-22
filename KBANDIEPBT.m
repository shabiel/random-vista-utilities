KBANDIEPBT ; OSE/SMH - Input, Print, and Sort Template Analysis;2018-01-22  12:47 PM
 ;;0.1;OSEHRA;
 ;
 ; This routine finds non-self files that are pointed to by a template
 ; 
DIBT ; [Public] Sort template analysis
 n outputData
 d DIBTCOL(.outputData)
 d DIBTOUT(.outputData,"/tmp/","DIBTOUT.csv")
 quit
 ;
DIET ; [Public] Input template analysis
 n outputData
 d DIETCOL(.outputData)
 d DIETOUT(.outputData,"/tmp/","DIETOUT.csv")
 quit
 ;
 ; 
DIBTCOL(outputData) ; [Private] Sort Template Data Collection
 ; for each template
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
 ... ;
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
 .. ;
 .. ; we have a field. Take it at face value
 .. e  s outputData(file,lineFile,lineField)=dibt_U_name
 quit
 ;
DIBTOUT(outputData,outputPath,outputFile) ; [Private] Sort Template Data Output
 n POP
 d OPEN^%ZISH("file1",outputPath,outputFile,"W")
 i POP quit
 u IO
 n file,dstFile,dstField,dibtIEN,dibtName
 n c s c=","
 w "SORT TEMPLATE IEN,SORT TEMPLATE NAME,SOURCE FILE,DESTINATION FILE,DESTINATION FIELD",!
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
DIETCOL(outputData) ; [Private] Input Template Data Collection
 ; for each template
 ; s outputData(file,thisFile,thisField)=dibt_U_name
 n diet f diet=0:0 s diet=$o(^DIE(diet)) q:'diet  do
 . quit:'$data(^DIE(diet,0))                 ; get valid ones only
 . new name s name=$p(^DIE(diet,0),U)
 . new file s file=$p(^DIE(diet,0),U,4)
 . ;
 . ; for each file in the input template
 . n line f line=0:0 s line=$o(^DIE(diet,"DR",line)) q:line>98  q:line=""  do  ; 99 is reserved for some compiled code
 .. n lineFile f lineFile=0:0 s lineFile=$o(^DIE(diet,"DR",line,lineFile)) q:'lineFile  q:(lineFile'=+lineFile)  do
 ... if lineFile=file quit  ; DR file same as our file; not interested
 ... if $$PARENT(lineFile)=file quit  ; ditto, for parent
 ... n fields s fields=^DIE(diet,"DR",line,lineFile)
 ... n fieldIndex,field f fieldIndex=1:1:$l(fields,";") do
 .... s field=$piece(fields,";",fieldIndex)
 .... ;
 .... ; various tests for the field
 .... i field="" quit       ; empty field. Can happen!
 .... ;
 .... n X s X=field d ^DIM  ; is it M code?
 .... i $d(X) quit          ; line is M code
 .... ;
 .... ; range like .01:5
 .... i $l(field,":")=2,(+$p(field,":"))=$p(field,":") do  quit
 ..... n start s start=$p(field,":",1)
 ..... n end     s end=$p(field,":",2)
 ..... i $data(^DD(lineFile,start)) s outputData(file,lineFile,start)=diet_U_name
 ..... n eachField s eachField=start
 ..... f  s eachField=$o(^DD(lineFile,eachField)) q:eachField>end  q:eachField=""  do
 ...... s outputData(file,lineFile,eachField)=diet_U_name
 .... ;
 .... i $e(field)="@" quit  ; jump to another place in the template. Not a field
 .... s field=+field
 .... i '$data(^DD(lineFile,field)) quit  ; field doesn't exist
 .... s outputData(file,lineFile,field)=diet_U_name
 quit
 ;
DIETOUT(outputData,outputPath,outputFile) ; [Private] Input Template Data Output
 n POP
 d OPEN^%ZISH("file1",outputPath,outputFile,"W")
 i POP quit
 u IO
 n file,dstFile,dstField,dietIEN,dietName
 n c s c=","
 w "INPUT TEMPLATE IEN,INPUT TEMPLATE NAME,SOURCE FILE,DESTINATION FILE,DESTINATION FIELD",!
 f file=0:0 s file=$o(outputData(file)) q:'file  d
 . f dstFile=0:0 s dstFile=$o(outputData(file,dstFile)) q:'dstFile  d
 .. f dstField=0:0 s dstField=$o(outputData(file,dstFile,dstField)) q:'dstField  d
 ... n data s data=outputData(file,dstFile,dstField)
 ... s dietIEN=$p(data,U,1)
 ... s dietName=$p(data,U,2)
 ... w dietIEN_c_dietName_c_file_c_dstFile_c_dstField,!
 d CLOSE^%ZISH("file1")
 quit
 ;
PARENT(subfile) ; [Private] Find out who my parent is
 ; WARNING: Recursive algorithm
 if $data(^DD(subfile,0,"UP")) quit $$PARENT(^("UP"))
 quit subfile
