!++
!   DESCRIP.MMS
!
!   MMS/MMK description file for building WATCHER.
!
!   Copyright (c) 2010, Matthew Madison.
!   Copyright (c) 2013, Endless Software Solutions.
!
!   All rights reserved.
!
!   Redistribution and use in source and binary forms, with or without
!   modification, are permitted provided that the following conditions
!   are met:
!
!       * Redistributions of source code must retain the above
!         copyright notice, this list of conditions and the following
!         disclaimer.
!       * Redistributions in binary form must reproduce the above
!         copyright notice, this list of conditions and the following
!         disclaimer in the documentation and/or other materials provided
!         with the distribution.
!       * Neither the name of the copyright owner nor the names of any
!         other contributors may be used to endorse or promote products
!         derived from this software without specific prior written
!         permission.
!
!   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
!   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
!   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
!   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
!   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
!   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
!   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
!   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
!   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
!   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!
!   To build WATCHER using MMS on OpenVMS AXP, use the command
!
!   	$ MMS/MACRO=__AXP__=1
!
!   MMK automatically defines this macro on AXP systems.
!
!-   

.INCLUDE VERSION.MMS
.IFDEF __IA64__
MG_VMSVER	= V82
ARCH 	= I64
OPT 	= .ALPHA_OPT
L32 	= .L32I
.ENDIF
.IFDEF __AXP__
MG_VMSVER   	= V6
ARCH 	= AXP
OPT  	= .ALPHA_OPT
L32  	= .L32E
.ENDIF
.IFDEF __VAX__
MG_VMSVER   	= V543
ARCH 	= VAX
OPT  	= .OPT
L32  	= .L32
.ENDIF
MG_FACILITY 	= WATCHER
KITNAME	    	= $(MG_FACILITY).ZIP
PRIMARY_TARGET	= ALL
.IFDEF __MADGOAT_BUILD__
BINDIR = MG_BIN:[$(MG_FACILITY)]
ETCDIR = MG_ETC:[$(MG_FACILITY)]
KITDIR = MG_KIT:[$(MG_FACILITY)]
SRCDIR = MG_SRC:[$(MG_FACILITY)]
.ELSE
BINDIR = SYS$DISK:[.BIN-$(ARCH)]
ETCDIR = SYS$DISK:[.ETC-$(ARCH)]
KITDIR = SYS$DISK:[.KIT-$(ARCH)]
SRCDIR = SYS$DISK:[]
.ENDIF

.SUFFIXES : $(L32) .R32 .PS .PDF
.R32$(L32) :
    $(BLISS)/LIB=$(MMS$TARGET) $(MMS$SOURCE)

.FIRST
    @ IF F$PARSE("$(BINDIR)") .EQS. "" THEN CREATE/DIR $(BINDIR)
    @ DEFINE/NOLOG BIN_DIR $(BINDIR)
    @ IF F$PARSE("$(ETCDIR)") .EQS. "" THEN CREATE/DIR $(ETCDIR)
    @ DEFINE/NOLOG ETC_DIR $(ETCDIR)
    @ IF F$PARSE("$(KITDIR)") .EQS. "" THEN CREATE/DIR $(KITDIR)
    @ DEFINE/NOLOG KIT_DIR $(KITDIR)
    @ DEFINE/NOLOG SRC_DIR $(SRCDIR)

{}.R32{$(ETCDIR)}$(L32) :
    $(BLISS)/LIB=$(MMS$TARGET) $(MMS$SOURCE)
{}.B32{$(BINDIR)}.OBJ :
    $(BLISS)$(BFLAGS) $(MMS$SOURCE)
{}.MSG{$(BINDIR)}.OBJ :
    $(MESSAGE) $(MSGFLAGS) $(MMS$SOURCE)
{}.CLD{$(BINDIR)}.OBJ :
    $(SETCMD) $(SETCMDFLAGS) $(MMS$SOURCE)

.PS.PDF :
    < DEFINE/USER GS_LIB SYS$SYSDEVICE:[GS.LIB],SYS$SYSDEVICE:[GS.FONTS]
    < GS == "$SYS$SYSDEVICE:[GS.BIN]GS.EXE_$(MMSARCH_NAME)"
    - PIPE GS "-sDEVICE=pdfwrite" "-dBATCH" "-dNOPAUSE" "-sOutputFile=$(MMS$TARGET)" $(MMS$SOURCE) > $(MMS$TARGET:.pdf=.gs_out)
    > TYPE $(MMS$TARGET:.pdf=.gs_out)
    > IF F$SEARCH("$(MMS$TARGET:.pdf=.gs_out)") .NES. "" THEN DELETE/NOLOG $(MMS$TARGET:.pdf=.gs_out);*
    > DELETE/SYMBOL/GLOBAL GS
    > IF F$SEARCH("_TEMP_*.*") .NES. "" THEN DELETE/NOLOG _TEMP_*.*;*

.IFDEF __IA64__
REGMAP = /ALPHA_REGISTER_MAPPING/VARIANT=1
.ELSE
REGMAP =
.ENDIF
.IFNDEF __VAX__
SYSEXE = /SYSEXE
MCH = /NOMACHINE
CHK = /CHECK=ALIGN
.IFDEF DBG
OPTIM = /NOOPT
.ENDIF
.ELSE
SYSSTB = ,SYS$SYSTEM:SYS.STB/SELECT
MCH = /MACHINE=NOOBJ
CHK =
.IFDEF DBG
OPTIM = /OPT=LEVEL:0
.ENDIF
.ENDIF

!LINKFLAGS   = /EXEC=$(MMS$TARGET)/NOMAP$(MAP)/NOTRACE$(DBG)
!BFLAGS	    = /OBJECT=$(MMS$TARGET)$(DBG)/NOLIST$(MCH)$(LIS)$(OPTIM)$(CHK)

WCP_MODULES = WCP,WCP_SHOW,WCP_MISC,WCP_CMDIO,CONFIG,PARSE_TIMES,WCP_CLD,-
    	      WCP_CMD_CLD,WCP_MSG

WCH_MODULES = WATCHER,COLLECT,LOG,FORCE,CONFIG,DECW_DISPLAY,WATCHER_MSG,MEM

.IFDEF __MADGOAT_BUILD__
.IFDEF __AXP__
ALL_EXTRA = ,$(BINDIR)V6_PERFORM_DISCONNECT.OBJ,$(BINDIR)V7_PERFORM_DISCONNECT.OBJ
.ENDIF
.IFDEF __VAX__
ALL_EXTRA = ,$(BINDIR)V5_PERFORM_DISCONNECT.OBJ,$(BINDIR)V6_PERFORM_DISCONNECT.OBJ
.ENDIF
.ENDIF

ALL : $(BINDIR)WATCHER.EXE, $(BINDIR)WCP.EXE, $(BINDIR)FORCE_EXIT.EXE, $(ALL_EXTRA)
    @ !

CLEAN :
    - DELETE $(ETCDIR)*.*;*
    - DELETE $(KITDIR)*.*;*
    - DELETE $(BINDIR)*.*;*

$(BINDIR)WATCHER.EXE	 : $(BINDIR)WATCHER.OLB($(WCH_MODULES)),-
    	    	           $(BINDIR)PERFORM_DISCONNECT.OBJ,-
    	    	    	   $(SRCDIR)WATCHER$(OPT),$(ETCDIR)VERSION.OPT
    LIBRARY/OUTPUT=$(BINDIR)WATCHER.OLB/COMPRESS $(BINDIR)WATCHER.OLB
    $(LINK)$(LINKFLAGS)$(SYSEXE) $(SRCDIR)WATCHER$(OPT)/OPT,$(ETCDIR)VERSION.OPT/OPT

$(BINDIR)WCP.EXE    	 : $(BINDIR)WCP.OLB($(WCP_MODULES)),$(ETCDIR)VERSION.OPT
    LIBRARY/OUTPUT=$(BINDIR)WCP.OLB/COMPRESS $(BINDIR)WCP.OLB
    $(LINK)$(LINKFLAGS) $(ETCDIR)VERSION.OPT/OPT,$(BINDIR)WCP.OLB/INCLUDE=WCP/LIB

$(BINDIR)FORCE_EXIT.EXE  : $(BINDIR)FORCE_EXIT.OBJ
    $(LINK)$(LINKFLAGS) $(MMS$SOURCE)

$(KITDIR)WCP_HELPLIB.HLB : $(KITDIR)WCP_HELPLIB.HLP
    LIBRARY/CREATE/HELP $(MMS$TARGET) $(MMS$SOURCE)

$(KITDIR)WCP_HELPLIB.HLP : $(SRCDIR)WCP_HELPLIB.RNH

$(BINDIR)MEM.OBJ,-
$(BINDIR)WATCHER.OBJ,-
$(BINDIR)COLLECT.OBJ,-
$(BINDIR)FORCE.OBJ,-
$(BINDIR)LOG.OBJ    	 : $(ETCDIR)WATCHER$(L32),$(ETCDIR)WATCHER_PRIVATE$(L32)

$(BINDIR)WCP.OBJ,-
$(BINDIR)WCP_SHOW.OBJ,-
$(BINDIR)WCP_MISC.OBJ,-
$(BINDIR)CONFIG.OBJ 	 : $(ETCDIR)WATCHER$(L32),$(ETCDIR)WCP$(L32)

$(BINDIR)WCP_CMDIO.OBJ 	 : $(ETCDIR)WCP$(L32)

$(BINDIR)DECW_DISPLAY.OBJ : $(SRCDIR)DECW_DISPLAY.B32
    $(BLISS)$(BFLAGS)$(REGMAP) $(MMS$SOURCE)

.IFDEF __AXP__
$(BINDIR)V6_PERFORM_DISCONNECT.OBJ : $(SRCDIR)PERFORM_DISCONNECT.B32,-
				     $(ETCDIR)V6_LIB$(L32)
    $(BLISS)$(BFLAGS)/VARIANT=6 $(MMS$SOURCE)
$(BINDIR)V7_PERFORM_DISCONNECT.OBJ : $(SRCDIR)PERFORM_DISCONNECT.B32,-
				     $(ETCDIR)V7_LIB$(L32)
    $(BLISS)$(BFLAGS)/VARIANT=7 $(MMS$SOURCE)

$(ETCDIR)V6_LIB$(L32) : $(SRCDIR)V6_LIB.ALPHA_REQ
    $(BLISS)$(BFLAGS)/NOOBJECT/LIBRARY=$(MMS$TARGET) $(MMS$SOURCE)+SYS$LIBRARY:STARLET.REQ
$(ETCDIR)V7_LIB$(L32) : $(SRCDIR)V7_LIB.ALPHA_REQ
    $(BLISS)$(BFLAGS)/NOOBJECT/LIBRARY=$(MMS$TARGET) $(MMS$SOURCE)+SYS$LIBRARY:STARLET.REQ
.ENDIF
.IFDEF __VAX__
$(BINDIR)V5_PERFORM_DISCONNECT.OBJ : $(SRCDIR)PERFORM_DISCONNECT.B32,-
				     $(ETCDIR)V5_LIB$(L32)
    $(BLISS)$(BFLAGS)/VARIANT=5 $(MMS$SOURCE)
$(BINDIR)V6_PERFORM_DISCONNECT.OBJ : $(SRCDIR)PERFORM_DISCONNECT.B32,-
				     $(ETCDIR)V6_LIB$(L32)
    $(BLISS)$(BFLAGS)/VARIANT=6 $(MMS$SOURCE)

$(ETCDIR)V5_LIB$(L32) : $(SRCDIR)V5_LIB.REQ
    $(BLISS)$(BFLAGS)/NOOBJECT/LIBRARY=$(MMS$TARGET) $(MMS$SOURCE)+SYS$LIBRARY:STARLET.REQ
$(ETCDIR)V6_LIB$(L32) : $(SRCDIR)V6_LIB.REQ
    $(BLISS)$(BFLAGS)/NOOBJECT/LIBRARY=$(MMS$TARGET) $(MMS$SOURCE)+SYS$LIBRARY:STARLET.REQ
.ENDIF
.IFDEF __IA64__
$(BINDIR)PERFORM_DISCONNECT.OBJ : $(SRCDIR)PERFORM_DISCONNECT.B32,-
				  $(ETCDIR)LIB$(L32)
    $(BLISS)$(BFLAGS)$(REGMAP)/VARIANT=8 $(MMS$SOURCE)

$(ETCDIR)LIB$(L32) : $(SRCDIR)LIB.IA64_REQ
    $(BLISS)/I32/TERMINAL=NOERRORS/ALPHA_REGISTER_MAPPING-
	    /LIBRARY=$(MMS$TARGET) $(MMS$SOURCE)+SYS$LIBRARY:STARLET.REQ
.ELSE
$(BINDIR)PERFORM_DISCONNECT.OBJ : $(SRCDIR)PERFORM_DISCONNECT.B32
    $(BLISS)$(BFLAGS)$(REGMAP) $(MMS$SOURCE)
.ENDIF

$(ETCDIR)WATCHER$(L32)	    	: $(ETCDIR)FIELDS$(L32)
$(ETCDIR)WATCHER_PRIVATE$(L32)	: $(ETCDIR)WATCHER$(L32), $(ETCDIR)FIELDS$(L32)
$(ETCDIR)WCP$(L32)   	     	: $(ETCDIR)WATCHER$(L32), $(ETCDIR)FIELDS$(L32)

DOC      = DOCUMENT
DOCFLAGS = /CONTENTS/NOPRINT/OUTPUT=$(MMS$TARGET)/DEVICE=BLANK_PAGES/SYMBOLS=$(ETCDIR)DYNAMIC_SYMBOLS.SDML
BRFLAGS  = /CONTENTS/NOPRINT/OUTPUT=$(MMS$TARGET)/SYMBOLS=$(ETCDIR)DYNAMIC_SYMBOLS.SDML
DOCFILES = $(SRCDIR)COPYRIGHT.SDML,$(ETCDIR)DYNAMIC_SYMBOLS.SDML

$(KITDIR)WATCHER_DOC.PS : $(SRCDIR)WATCHER_DOC.SDML,$(DOCFILES)
    @ IF F$TRNLNM("DECC$SHR") .NES. "" THEN DEFINE/USER DECC$SHR SYS$SYSROOT:[SYSLIB]DECC$SHR
    $(DOC) $(DOCFLAGS) $(MMS$SOURCE) SOFTWARE.REFERENCE PS
$(KITDIR)WATCHER_DOC.PDF : $(KITDIR)WATCHER_DOC.PS

$(KITDIR)WATCHER_DOC.TXT : $(SRCDIR)WATCHER_DOC.SDML,$(DOCFILES)
    @ IF F$TRNLNM("DECC$SHR") .NES. "" THEN DEFINE/USER DECC$SHR SYS$SYSROOT:[SYSLIB]DECC$SHR
    $(DOC) $(DOCFLAGS) $(MMS$SOURCE) SOFTWARE.REFERENCE MAIL

$(KITDIR)WATCHER_DOC.HTML : $(SRCDIR)WATCHER_DOC.SDML,$(DOCFILES)
    @ IF F$TRNLNM("DECC$SHR") .NES. "" THEN DEFINE/USER DECC$SHR SYS$SYSROOT:[SYSLIB]DECC$SHR
    $(DOC) $(BRFLAGS) $(MMS$SOURCE) SOFTWARE.REFERENCE HTML /INDEX

$(KITDIR)WATCHER$(NUM_VERSION).RELEASE_NOTES : $(SRCDIR)RELEASE_NOTES.SDML,-
					       $(DOCFILES)
    @ IF F$TRNLNM("DECC$SHR") .NES. "" THEN DEFINE/USER DECC$SHR SYS$SYSROOT:[SYSLIB]DECC$SHR
    $(DOC) $(DOCFLAGS) $(MMS$SOURCE) SOFTWARE.REFERENCE MAIL

$(ETCDIR)DYNAMIC_SYMBOLS.SDML : $(SRCDIR)VERSION.MMS
    @GENERATE_SYMBOLS $(MMS$SOURCE) $(MMS$TARGET)

$(ETCDIR)VERSION.OPT : $(SRCDIR)VERSION.MMS
    @ CLOSE/NOLOG VEROPT
    @ OPEN/WRITE VEROPT $(MMS$TARGET)
    @ WRITE VEROPT "IDENT=""$(TEXT_VERSION)"""
    @ CLOSE/NOLOG VEROPT

.IFDEF __MADGOAT_BUILD__
DIST_TOP : $(SRCDIR)AAAREADME.DOC,$(SRCDIR)AAAREADME.TOO,$(ETCDIR)VERSION.OPT,-
    	   $(SRCDIR)LINK.COM,$(SRCDIR)WATCHER.OPT,-
    	   $(SRCDIR)V5_WATCHER.OPT,$(SRCDIR)V6_WATCHER.OPT,$(SRCDIR)WATCHER.IA64_OPT,-
    	   $(SRCDIR)WATCHER.ALPHA_OPT,$(SRCDIR)V6_WATCHER.ALPHA_OPT,-
    	   $(SRCDIR)V7_WATCHER.ALPHA_OPT,$(SRCDIR)DECW_STARTLOGIN.COM,-
    	   $(SRCDIR)WATCHER_STARTUP.COM,$(SRCDIR)WATCHER_SHUTDOWN.COM,-
    	   $(SRCDIR)WATCHER.COM,$(SRCDIR)WATCHER_LOGOUT.TEMPLATE,-
    	   $(SRCDIR)SAMPLE_CONFIG.WCP,$(SRCDIR)WATCHER_MAIL.COM,$(KITDIR)WCP_HELPLIB.HLB
    PURGE $(MMS$SOURCE_LIST)
    BACKUP $(MMS$SOURCE_LIST) DIST_ROOT:[DIST]/OWNER=PARENT

DIST_VAX : $(BINVAX)WATCHER.OLB,$(BINVAX)WCP.OLB,-
    	   $(BINVAX)V5_PERFORM_DISCONNECT.OBJ,-
    	   $(BINVAX)V6_PERFORM_DISCONNECT.OBJ,-
    	   $(BINVAX)FORCE_EXIT.OBJ
    PURGE $(MMS$SOURCE_LIST)
    BACKUP $(MMS$SOURCE_LIST) DIST_ROOT:[DIST.BIN-VAX]/OWNER=PARENT

DIST_AXP : $(BINAXP)WATCHER.OLB,$(BINAXP)WCP.OLB,-
    	   $(BINAXP)V6_PERFORM_DISCONNECT.OBJ,-
    	   $(BINAXP)V7_PERFORM_DISCONNECT.OBJ,-
    	   $(BINAXP)FORCE_EXIT.OBJ
    PURGE $(MMS$SOURCE_LIST)
    BACKUP $(MMS$SOURCE_LIST) DIST_ROOT:[DIST.BIN-ALPHA]/OWNER=PARENT

DIST_I64 : $(BINI64)WATCHER.OLB,$(BINI64)WCP.OLB,-
    	   $(BINI64)PERFORM_DISCONNECT.OBJ,-
    	   $(BINI64)FORCE_EXIT.OBJ
    PURGE $(MMS$SOURCE_LIST)
    BACKUP $(MMS$SOURCE_LIST) DIST_ROOT:[DIST.BIN-IA64]/OWNER=PARENT

DIST_DOC : $(KITDIR)WATCHER_DOC.PS,$(KITDIR)WATCHER_DOC.PDF,-
	   $(KITDIR)WATCHER_DOC.TXT,$(KITDIR)WATCHER_DOC.HTML,-
	   $(KITDIR)WATCHER$(NUM_VERSION).RELEASE_NOTES

SRC1	  = $(SRCDIR)COLLECT.B32,$(SRCDIR)CONFIG.B32,$(SRCDIR)DECW_DISPLAY.B32,$(ETCDIR)VERSION.OPT,-
    	    $(SRCDIR)FIELDS.R32,$(SRCDIR)FORCE.B32,$(SRCDIR)LOG.B32,$(SRCDIR)MEM.B32,$(SRCDIR)PARSE_TIMES.B32,$(SRCDIR)WATCHER.B32,-
    	    $(SRCDIR)WATCHER.R32,$(SRCDIR)WATCHER_DOC.SDML,$(SRCDIR)WATCHER_MSG.MSG,$(SRCDIR)WATCHER_PRIVATE.R32,-
    	    $(SRCDIR)WCP.B32,$(SRCDIR)WCP.R32,$(SRCDIR)WCP_CLD.CLD,$(SRCDIR)WCP_CMDIO.B32,$(SRCDIR)PERFORM_DISCONNECT.B32
SRC2	  = $(SRCDIR)WCP_CMD_CLD.CLD,$(SRCDIR)WATCHER.OPT,$(SRCDIR)V5_WATCHER.OPT,$(SRCDIR)V6_WATCHER.OPT,-
    	    $(SRCDIR)WATCHER.ALPHA_OPT,$(SRCDIR)V6_WATCHER.ALPHA_OPT,$(SRCDIR)V7_WATCHER.ALPHA_OPT,-
    	    $(SRCDIR)WCP_HELPLIB.RNH,$(SRCDIR)WCP_MISC.B32,$(SRCDIR)WCP_MSG.MSG,$(SRCDIR)WCP_SHOW.B32,-
    	    $(SRCDIR)DESCRIP.MMS,$(SRCDIR)COMPILE.COM,$(SRCDIR)FORCE_EXIT.B32,$(ETCDIR)DYNAMIC_SYMBOLS.SDML

SOURCE    : $(SRC1),$(SRC2)
    PURGE $(SRC1)
    PURGE $(SRC2)
    BACKUP $(SRC1) DIST_ROOT:[DIST.SOURCE]/OWNER=PARENT
    BACKUP $(SRC2) DIST_ROOT:[DIST.SOURCE]/OWNER=PARENT
.ENDIF
