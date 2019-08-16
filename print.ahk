args:=""
Loop, %0%
{
    param := %A_Index%
	num = %A_Index%
	args := args . param
}
if(args="")
	args:=A_WorkingDir

language:="Matlab"
ext:="m"

body=
(
\documentclass{article}
\usepackage[left=5mm, top=5mm, bottom=5mm, right=5mm]{geometry}
\usepackage{listings}
\usepackage[usenames,dvipsnames]{color}
\lstdefinestyle{customasm}{
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
\usepackage[colorlinks=true,linkcolor=blue]{hyperref} 
\begin{document}
\tableofcontents
\newpage
)

if(IsDirectory(args))
{
    Loop, Files, %args%\*.%ext%, RF
    {
        selFile:=A_LoopFileLongPath
        SplitPath, selFile,name,dir,,name_no_ext
        dir:=StrReplace(dir, args, ".")
        selFile:=StrReplace(selFile, "\","/")
        dir:=StrReplace(dir, "\","/")
        name:=StrReplace(name,"_","\_")
        path:=dir . "/" . name
body=%body%
(

\section{%path%}
\lstinputlisting[style=customasm]{"%selFile%"}
)
    }
}

body=%body%
(

\end{document}
)

FileDelete, %A_ScriptDir%\print.tex
FileAppend, %body%, %A_ScriptDir%\print.tex

RunWait, %comspec% /k pdflatex.exe -synctex=1 --shell-escape -interaction=nonstopmode "print".tex && exit || pause && exit, %A_ScriptDir%

SplitPath, args, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

selFile=%OutDir%\%OutFileName%.pdf
FileMove, %A_ScriptDir%\print.pdf, %OutDir%\%OutFileName%.pdf

Run, %selFile%

return

IsDirectory(selFile)
{
	FileGetAttrib, Attributes, %selFile%
	return FileExist(selFile) && InStr(Attributes, "D")
}