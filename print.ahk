args:=""
Loop, %0%
{
    param := %A_Index%
	num = %A_Index%
	args := args . param
}
if(args="")
	args:=A_WorkingDir

languages:=["Matlab", "Python"]
extensions:=["m","py"]
SplitPath, args, title
title:=StrReplace(title,"_","\_")
body=
(
\documentclass{article}
\usepackage[left=5mm, top=5mm, bottom=5mm, right=5mm]{geometry}
\usepackage{listings}
\usepackage[usenames,dvipsnames]{color}
)
Loop, % extensions._MaxIndex(){
    ext:=extensions[A_Index]
    language:=languages[A_Index]
section=
(
\lstdefinestyle{custom%ext%}{
  belowcaptionskip=1\baselineskip,
  xleftmargin=\parindent,
  language=%language%,
  breaklines=true,
  basicstyle=\footnotesize\ttfamily,
  commentstyle=\itshape\color{Gray},
  stringstyle=\color{Black},
  keywordstyle=\bfseries\color{OliveGreen},
  identifierstyle=\color{blue},
  xleftmargin=1em,
}
)
body:=body . section
}
section=
(
\usepackage[colorlinks=true,linkcolor=blue,linktocpage=true,linktoc=all]{hyperref}
\title{%title%}
\begin{document}
\maketitle
\label{toc}
\tableofcontents
\newpage
)
body:=body . section

if(IsDirectory(args))
{
    Loop, % extensions._MaxIndex(){
        ext:=extensions[A_Index]
        Loop, Files, %args%\*.%ext%, RF
        {
            selFile:=A_LoopFileLongPath
            SplitPath, selFile,name,dir,,name_no_ext
            dir:=StrReplace(dir, args . "\")
            dir:=StrReplace(dir, args)
            selFile:=StrReplace(selFile, "\","/")
            if(dir<>"")
                path:=dir . "/" . name
            else
                path:=name
            path:=StrReplace(path,"\","/")
            path:=StrReplace(path,"_","\_")
            path:="./" . path
    ; \section{\hyperref[toc]{%path%}}
    body=%body%
    (

    \section{%path%}
    \lstinputlisting[style=custom%ext%]{"%selFile%"}
    )
        }
    }
}

body=%body%
(

\end{document}
)

FileDelete, %A_ScriptDir%\print.tex
FileDelete, %A_ScriptDir%\print.synctex.gz
FileDelete, %A_ScriptDir%\print.aux
FileDelete, %A_ScriptDir%\print.log
FileDelete, %A_ScriptDir%\print.out
FileDelete, %A_ScriptDir%\print.toc
Sleep, 500
FileAppend, %body%, %A_ScriptDir%\print.tex

RunWait, %comspec% /k pdflatex.exe -synctex=1 --shell-escape -interaction=nonstopmode "print".tex && pdflatex.exe -synctex=1 --shell-escape -interaction=nonstopmode "print".tex && exit || pause && exit, %A_ScriptDir%

SplitPath, args, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

selFile=%OutDir%\%OutFileName%.pdf
FileMove, %A_ScriptDir%\print.pdf, %OutDir%\%OutFileName%.pdf, 1

Run, %selFile%

return

IsDirectory(selFile)
{
	FileGetAttrib, Attributes, %selFile%
	return FileExist(selFile) && InStr(Attributes, "D")
}