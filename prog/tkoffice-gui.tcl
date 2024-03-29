# ~/TkOffice/prog/tkoffice-gui.tcl
# ~/tkoffice/prog/tkoffice-gui.tcl
# Salvaged: 1nov17
# Updated for use with SQlite: Sep22
# Updated 28aug23

#NOTE: 'tklib' required for 'tablelist'
#Documentation in www.nemethi.de
	
set version 2.0
set px 5
set py 5

package require Tk

#Initiate Sqlite DB
if [catch {package require sqlite3}] {
  tk_messageBox -type ok -icon warning -message "You must install the program 'sqlite' version 3 before continuomg."
  exit
} 

if [catch {source $confFile}] {
  set initial 1
  
  tk_messageBox -type ok -icon warning -message "Sie müssen das Programm erst einrichten. Wir wechseln nun auf die Einrichtungsseite."
 
  set dbname \"dbname\"
  set currency £   
  set cond1 {}
  set cond2 {}
  set cond3 {}

} else {

  sqlite3 db $dbPath
  set initial 0

}

#TODO add catches?
source [file join $progDir tkoffice-setup.tcl]
source [file join $progDir tkoffice-procs.tcl]
source [file join $progDir tkoffice-invoice.tcl]
source [file join $progDir tkoffice-report.tcl]
source [file join $progDir tkoffice-print.tcl]

#Create title font
font create TIT
font configure TIT -family Helvetica -size 16 -weight bold

#Create top & bottom frames with fix positions
pack [frame .topF -bg steelblue3] -fill x
pack [frame .botF -bg steelblue3] -fill x -side bottom

#Firmenname
label .firmaL -textvar myComp -font "TkHeadingFont 20 bold" -fg silver -bg steelblue3 -anchor w
pack .firmaL -in .topF -side right -padx 10 -pady 3 -anchor e

#Create Notebook: (maxwidth+maxheight important to avoid overlapping of bottom frame)
set screenX [winfo screenwidth .]
set screenY [winfo screenheight .]
. conf -bg steelblue3
ttk::notebook .n 

.n conf -width [expr round($screenX / 10) * 9] -height [expr round($screenY / 10) * 8]
.n add [frame .n.t1] -text "[mc adr+orders]"
.n add [frame .n.t2] -text "[mc newInv]"
.n add [frame .n.t3] -text "[mc reports]"
.n add [frame .n.t6] -text "[mc spesen]"
.n add [frame .n.t7] -text "[mc artikel]"
.n add [frame .n.t5] -text "[mc storni]"
.n add [frame .n.t4] -text "[mc settings]"

pack .n -anchor center -padx 15 -pady 15 -fill x

set winW [winfo width .n]

button .abbruchB -text "Programm beenden" -activebackground red -command {
	db close 
	exit
	}
pack .abbruchB -in .botF -side right -pady 3 -padx 10

#Pack all frames
createTkOfficeLogo
pack [frame .umsatzF] -in .n.t1 -side bottom  -fill x

#Tab 1
pack [frame .n.t1.topF] -fill x -pady 10 -padx 10
pack [frame .n.t1.midF] -fill x -pady 10 -padx 10 ;#for permanent Headers

frame .n.t1.botF1 ;# for canvas
frame .n.t1.botF2 ;# for scrollbar
pack .n.t1.botF1 -side left -expand 1 -anchor nw 
pack .n.t1.botF2 -side right -anchor se

#Tab 2
pack [frame .n.t2.f1a -pady $py -padx $px -bd 5] -anchor nw -fill x
pack [frame .n.t2.f1 -pady $py -padx $px -bd 5] -anchor nw -fill x
pack [frame .n.t2.f2 -relief ridge -pady $py -padx $px -borderwidth 5] -anchor nw -fill x -padx 20 -pady 15
pack [frame .n.t2.f3 -pady $py -padx $px -borderwidth 5] -anchor nw -fill x
pack [frame .n.t2.bottomF] -anchor nw -padx 20 -pady 20 -fill both -expand 1

#Tab 3
pack [frame .n.t3.f1 -relief ridge -pady $py -padx 20 -borderwidth 5] -fill x
pack [frame .n.t3.bottomF] -anchor nw -padx 20 -pady 20 -fill x
#Tab 4
pack [frame .n.t4.f3 -pady $py -padx $px -borderwidth 5 -highlightbackground silver -highlightthickness 5] -anchor nw -fill x
pack [frame .n.t4.f2 -pady $py -padx $px -borderwidth 5 -highlightbackground silver -highlightthickness 5] -anchor nw -fill x
pack [frame .n.t4.f1 -pady $py -padx $px -borderwidth 5 -highlightbackground silver -highlightthickness 5] -anchor nw -fill x
pack [frame .n.t4.f5 -pady $py -padx $px -borderwidth 5 -highlightbackground silver -highlightthickness 5] -anchor nw -fill x -side left -expand 1


###############################################
# T A B 1. : A D R E S S F E N S T E R
###############################################

#Pack 3 top frames seitwärts
#Create "Adressen" title
label .adrTitel -text "Adressverwaltung" -font TIT -pady 5 -padx 5 -anchor w -fg steelblue -bg silver
pack .adrTitel -in .n.t1.topF -anchor w -fill x

##obere Frames in .n.t1.f2
pack [frame .adrF2 -bd 3 -relief flat -bg lightblue -pady $py -padx $px] -anchor nw -in .n.t1.topF -side left
pack [frame .adrF4 -bd 3 -relief flat -bg lightblue -pady $py -padx $px] -anchor nw -in .n.t1.topF -side left
pack [frame .adrF1] -anchor nw -in .n.t1.topF -side left
pack [frame .adrF3] -anchor se -in .n.t1.topF -expand 1 -side left

##create Address number 
set adrSpin [spinbox .adrSB -takefocus 1 -width 15 -bg lightblue -justify right -textvar adrNo]
focus $adrSpin

##Create search field
set adrSearch [entry .adrsearchE -width 25 -borderwidth 3 -bg beige -fg grey]
resetAdrSearch

#Create address entries, to be packed when 'changeAddress' or 'newAddress' are invoked
entry .name1E -width 50 -textvar name1 -justify left
entry .name2E -width 50 -textvar name2 -justify left
entry .streetE -width 50 -textvar street -justify left
entry .zipE -width 7 -textvar zip -justify left
entry .cityE -width 43 -textvar city -justify left
entry .tel1E -width 25 -textvar tel1 -justify right
entry .tel2E -width 25 -textvar tel2 -justify right
entry .mailE -width 25 -textvar mail -justify right
entry .wwwE -width 25 -textvar www -justify right

#create Address buttons
button .adrNewBtn -text [mc adrNew] -width 20 -command {
  #clearAddressWin
  newAddress
  }
  
button .adrChgBtn -text [mc adrChange] -width 20 -command {changeAddress $adrNo}
button .adrDelBtn -text [mc adrDelete] -width 20 -command {deleteAddress $adrNo} -activebackground red

#Pack adrF1 spinbox
pack $adrSpin -in .adrF1 -anchor nw
#Pack adrF3 buttons
pack $adrSearch .adrNewBtn .adrChgBtn .adrDelBtn -in .adrF3 -anchor ne


#########################################################################################
# T A B 1 :  I N V O I C E   L I S T
#########################################################################################

.umsatzF conf -bd 2 -relief sunken

#Create "Rechnungen" Titel
label .adrInvTitel -justify center -text "Verbuchte Rechnungen" -font TIT -pady 5 -padx 5 -anchor w -fg steelblue -bg silver

label .adrInfoPfeil -text "\u2193" -fg red -bg silver -font bold
label .adrInvInfo -anchor w -fg grey -text "[mc viewInv]"

label .creditL -text "Kundenguthaben: $currency " -font "TkCaptionFont"
label .credit2L -text "\u2196 wird bei Zahlungseingang aktualisiert" -font "TkIconFont" -fg grey
message .creditM -textvar credit -relief sunken -width 50
label .umsatzL -text "Kundenumsatz: $currency " -font "TkCaptionFont"
message .umsatzM -textvar umsatz -relief sunken -bg lightblue -width 50

#Pack midFrame
pack .adrInvTitel -in .n.t1.midF -anchor w -fill x -padx 10 -pady 0
pack .adrInfoPfeil -in .n.t1.midF -anchor w -padx 10 -side left
pack .adrInvInfo -in .n.t1.midF -anchor w -side left
  
#Umsatz unten
pack .creditL .creditM .credit2L -in .umsatzF -side left -anchor w
pack .umsatzM .umsatzL -in .umsatzF -side right -anchor e

#Create Rechnungen Kopfdaten
label .invNoH -text "Nr."  -font TkCaptionFont -justify left -anchor w -width 10
label .invDatH -text "Datum"  -font TkCaptionFont -justify left -anchor w -width 10
label .invArtH -text "Artikel" -font TkCaptionFont -justify left -anchor w -width 30
label .invSumH -text "Betrag $currency" -font TkCaptionFont -justify right -anchor w -width 10
label .invPayedSumH -text "Bezahlt $currency" -font TkCaptionFont -justify right -anchor w -width 10
label .invPayedDatH -text "Zahldatum" -font TkCaptionFont -justify left -anchor w -width 10        
label .invPaymentEntryH -text "Eingabe Zahlbetrag" -font TkCaptionFont -justify right -anchor w 
label .invCommentH -text "Anmerkung" -font TkCaptionFont -justify left -anchor w
             
#Pack labels into columns, gaps controlled by label widths & frame x-pads
##outer frame
#canvas .invC 
#pack .invC -in .n.t1.botF1 -fill both -expand 1 -padx 50 -pady 50 -side left -anchor nw
##inner frame
#pack [frame .invC.invF]
set invF .n.t1.botF1

pack [frame $invF.c1] [frame $invF.c2] [frame $invF.c3] [frame $invF.c4] [frame $invF.c5] [frame $invF.c6] [frame $invF.c7] [frame $invF.c8] -padx 10 -anchor nw -side left

##export column vars
set c1 $invF.c1
set c2 $invF.c2
set c3 $invF.c3
set c4 $invF.c4
set c5 $invF.c5
set c6 $invF.c6
set c7 $invF.c7
set c8 $invF.c8
lappend invColumnL $c1 $c2 $c3 $c4 $c5 $c6 $c7 $c8

#pack headers into columns
pack .invNoH -in $c1 -pady 7 -anchor n
pack .invDatH -in $c2 -pady 7
pack .invArtH -in $c3 -pady 7
pack .invSumH -in $c4 -pady 7
pack .invPayedSumH -in $c5 -pady 7
pack .invPayedDatH -in $c6 -pady 7
pack .invPaymentEntryH -in $c7 -pady 7
pack .invCommentH -in $c8 -pady 7 -anchor w

#Create spinbox for paging
label .invPageinfoL -text "Page" -padx 5 -state disabled
label .invNumPagesL -textvar numpages -padx 5 -state disabled
spinbox .invSB -width 3 -bg beige -state disabled 
.invSB conf -command {invSelectPage %s}
pack .invPageinfoL .invSB .invNumPagesL -in .n.t1.botF2 -side left -anchor se

	
########################################################################################
# T A B  2 :   N E W   I N V O I C E
########################################################################################

#Main Title with customer name
label .titel3 -text "[mc invCreate]" -font TIT -anchor w -pady 5 -padx 5 -fg steelblue -bg silver
label .titel3name -textvar name2 -font TIT -anchor w -pady 5 -padx 5 -fg steelblue -bg silver
pack .titel3 .titel3name -in .n.t2.f1a -fill x -anchor w -side left

#Get Zahlungsbedingungen from config
set condList ""
label .invcondL -text "Zahlungsbedingung:" -pady 10
foreach cond [list $cond1 $cond2 $cond3] { 
  if {$cond != ""} {
    lappend condList $cond
  }
} 
#Insert into spinbox
spinbox .invcondSB -width 20 -values $condList -textvar cond -bg beige
#Auftragsdatum: set to heute
label .invauftrdatL -text "\tAuftragsdatum:"
entry .invauftrdatE -width 9 -textvar auftrDat -bg beige
set auftrDat [clock format [clock seconds] -format %d.%m.%Y]
set heute $auftrDat

#Referenz
label .invrefL -text "\tIhre Referenz:"
entry .invrefE -width 20 -bg beige -textvar ref
#Int. Kommentar
label .invcomL -text "\tInterne Bemerkung:"
entry .invcomE -width 30 -bg beige -textvar comm

#Packed later by resetNewInvoiceDialog
entry .mengeE -width 7 -bg yellow -fg grey
label .subtotalL -text "Rechnungssumme: "
message .subtotalM -width 70 -bg lightblue -padx 20 -anchor w
label .abzugL -text "Auslagen: "
message .abzugM -width 70 -bg orange -padx 20 -anchor w
label .totalL -text "Buchungssumme: "
message .totalM -width 70 -bg lightgreen -padx 20 -anchor w


#Set up Artikelliste, fill later when connected to DB
menubutton .invartlistMB -text [mc artSelect] -direction below -relief raised -menu .invartlistMB.menu
menu .invartlistMB.menu -tearoff 0 ;#-postcommand createArtMenu ;#-postcommand {setArticleLine TAB2}


label .arttitL -text "Artikel Nr."

#TODO replace with tk_optionMenu????
#spinbox .invartnumSB -width 2 -command {setArticleLine TAB2}

#pack [label .artLabel -text Artikel]

#menu .artMenu -tearoff 0 -title Artikel
#bind .artLabel <1> {tk_popup .artMenu post %X %Y}
# bind .artmenuBtn <1> {tk_popup .artMenu %X %Y}
 #createArtMenu

#Make invoiceFrame
#catch {frame .invoiceFrame}
pack [frame .newInvoiceF] -in .n.t2.f3 -side bottom -fill both

#Set KundenName in Invoice window
#label .clientL -text "Kunde:" -font "TkCaptionFont" -bg lightblue
#label .clientnameL -textvariable name2 -font "TkCaptionFont"
#pack .clientnameL .clientL -in .n.t2.f1 -side right

namespace eval invoice {}
label .invartpriceL -textvar invoice::artPrice -padx 20
entry .invartpriceE -textvar invoice::artPrice
label .invartnameL -textvar invoice::artName -padx 50
label .invartunitL -textvar invoice::artUnit -padx 20
label .invarttypeL -textvar invoice::artType -padx 20

button .invSaveBtn -text [mc invEnter]
button .invCancelBtn -text [mc cancel] -command {resetNewInvDialog} -activebackground red
pack .invCancelBtn .invSaveBtn -in .n.t2.bottomF -side right


######################################################################################
# T A B  3 :  A B S C H L Ü S S E
######################################################################################
#Main Title
label .titel4 -text "Jahresabschlüsse" -font TIT -anchor nw -pady 5 -padx 5 -fg steelblue -bg silver
pack .titel4 -in .n.t3 -fill x -anchor nw

message .repM -justify left -width 300 -text [mc reportTxt]
button .repCreateBtn -text [mc reportCreate] -command {createReport}

spinbox .repJahrSB -width 4

message .news -textvar news -pady 10 -padx 10 -bd 3 -relief sunken -justify center -width 1000 -anchor n -bg steelblue3

pack [frame .n.t3.topF -padx 15 -pady 15] -fill x
pack [frame .n.t3.mainF -padx 15 -pady 15] -fill both -anchor nw
pack [frame .n.t3.botF] -fill x

pack [frame .n.t3.leftF] -in .n.t3.mainF -side right -expand 1 -fill both -anchor nw
pack [frame .n.t3.rightF] -in .n.t3.mainF -side left -fill y 

pack [frame .n.t3.rightF.saichF] -fill x
pack .repCreateBtn -in .n.t3.rightF.saichF -side left
pack .repJahrSB -in .n.t3.rightF.saichF -side left -padx 20
pack .repM -in .n.t3.rightF -anchor nw -pady 20
  
  #Create canvas, text window & scrollbar - height & width will be set by createReport
  canvas .repC -bg beige -height 500 -width 750
  text .repT

  scrollbar .repSB -orient vertical
  .repT conf -yscrollcommand {.repSB set}
  .repSB conf -command {.repT yview}
  
  #Print button - packed later by canvasReport
  button .repPrintBtn -text "[mc reportPrint]" -bg lightgreen
  pack .repSB -in .n.t3.leftF -side right -fill y
  pack .repC -in .n.t3.leftF -side right -fill both
  pack .news -in .botF -side left -anchor center -expand 1 -fill x

######################################################################################
# T A B 4 :  C O N F I G U R A T I O N
######################################################################################

setupConfig

########################################################
# T A B  5  - S P E S E N
########################################################

label .titel6 -text "[mc spesen]" -font TIT -anchor nw -fg steelblue -bg silver 
message .spesenM -width 400 -anchor nw -justify left -text "[mc spesenTxt]" 
listbox .spesenLB -width 100 -height 40 -bg lightblue

#TODO? listboxes have no yview concept, but are still scrollable!
#scrollbar .spesenSB -orient vertical
#.spesenLB conf -yscrollcommand {.spesenSB set}
#.spesenSB conf -command {.spesenSB yview}

button .spesenB -text "Jahresspesen verwalten" -command {manageExpenses}
button .spesenDeleteB -text "Eintrag löschen" -command {deleteExpenses}
button .spesenAbbruchB -text [mc cancel] -command {manageExpenses}
button .spesenAddB -text "Eintrag hinzufügen" -command {addExpenses}

entry .expnameE
entry .expvalueE

#TODO Spesenverwaltung buggy, needs exit button & must be cleared at the end!
##moved to EINSTELLUNGEN tab!
pack .titel6 -in .n.t6 -fill x -padx 20 -pady 20
pack .spesenM .spesenB -in .n.t6 -anchor nw -padx 20 -pady 20 

####################################################
# T A B  6 - S T O R N I
#####################################################
label .titel5 -text "[mc storni]" -font TIT -anchor nw -fg steelblue -bg silver 
message .storniM -width 400 -anchor nw -justify left -text "[mc storniTxt]" 

entry .stornoE -bg beige -justify left -validate focusout -vcmd {storno %s;return 0}

pack .titel5 -in .n.t5 -anchor nw -pady 25 -padx 25 -fill x
pack .storniM .stornoE -in .n.t5 -pady 25 -padx 25 -side left -anchor nw


#####################################################
# T A B  7  -  A R T I K E L 
#####################################################
label .titel7 -text "[mc artManage]" -font TIT -anchor nw -fg steelblue -bg silver 
pack .titel7 -in .n.t7 -fill x
#label .confartT -text "[mc artManage]" -font "TkHeadingFont"

message .confartM -width 800 -text "[mc artTxt]"
label .artL -text "Artikelliste" -font "TkHeadingFont"

#pack .titel7 .confartM .artL -in .n.t7 -anchor nw -pady 20 -padx 20


#These are packed/unpacked later by article procs
label .confartL -text "Artikel Nr."

namespace eval artikel {}
label .confartnameL -padx 7 -width 25 -textvar artikel::artName -anchor w
label .confartpriceL -padx 10 -width 7 -textvar artikel::artPrice -anchor w
label .confartunitL -padx 10 -width 7 -textvar artikel::artUnit -anchor w
label .confarttypeL -padx 10 -width 1 -textvar artikel::artType -anchor w

spinbox .confartnumSB -width 5 -command {setConfArticleLine}
button .confartsaveB -text [mc artSave] -command {saveArticle}
button .confartdeleteB -text [mc artDelete] -command {deleteArticle} -activebackground red
button .confartcreateB -text [mc artCreate] -command {createArticle}
entry .confartnameE -bg beige
entry .confartunitE -bg beige -textvar artikel::rabatt
entry .confartpriceE -bg beige
ttk::checkbutton .confarttypeACB -text "Auslage"
ttk::checkbutton .confarttypeRCB -text "Rabatt"

#TODO
#pack .confartcreateB -in .n.t7






#######################################################################
## F i n a l   a 	c t i o n s :    detect Fehlermeldung bzw. socket no.
#######################################################################
proc gerekmi {} {
if {[string length $res] >20} {
  NewsHandler::News $res red 
  .confdbnameE conf -text "Datenbankname eingeben" -validate focusin -validatecommand {%W conf -bg beige -fg grey ; return 0}
  .confdbUserE conf -text "Datenbanknutzer eingeben" -validate focusin -validatecommand {%W conf -text "Name eingeben" -bg beige -fg grey ; return 0}
  return 1
}

#Verify DB state
NewsHandler::QueryNews "Mit Datenbank verbunden" lightgreen
set db $res
.confdbnameE conf -state disabled
.confdbUserE conf -state disabled
.initdbB conf -state disabled

}

#TODO try below - separating "New invoice" procs from "Show old invoice" procs in tkoffice-invoice.tcl
#source [file join $progDir tkoffice-invoice.tcl]


# E x e c u t e   p r o g s
if {!$initial} {
  setAdrList
  resetAdrWin
  resetNewInvDialog
  
  updateArticleList
  resetArticleWin
  setConfArticleLine
  
  #TODO buna gerek var mI?
  createInvArticleMenu
  
  #Execute once when specific TAB opened
  bind .n <<NotebookTabChanged>> {
    set selected [.n select]
    if {$selected == ".n.t3"} {
      set t3 1
    }
  }

  resetNewInvDialog
  setAbschlussjahrSB
  


} else {

  .n select 6
}
