\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sjkyljyyexp}[2026/10/18 SJKYLJYY experiment report]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{cqutreport}}
\ProcessOptions\relax
\LoadClass{cqutreport}

\RequirePackage[a4paper,top=2.2cm,bottom=2.2cm,left=2.5cm,right=2.5cm]{geometry}
\RequirePackage{array}

\setlength{\parindent}{2em}
\setlength{\parskip}{0.25em}
\linespread{1.2}
\pagestyle{plain}
\renewcommand{\labelenumi}{\arabic{enumi}．}
\ctexset{section={format=\heiti\zihao{4},number=\chinese{section},
  aftername=、,beforeskip=1em,afterskip=0.5em}}

\newcommand{\reportclass}{}
\newcommand{\reportnumber}{}
\newcommand{\reportname}{}
\newcommand{\reportteacher}{}
\newcommand{\reportdate}{}

\newcommand{\coverfield}[2]{%
  \makebox[2.0cm][s]{#1} &
  \underline{\makebox[7.3cm][c]{#2}}\\[0.56cm]
}

\newcommand{\sqlname}[1]{\allowbreak{\ttfamily\small #1}}
\newcounter{task}
\newcommand{\task}[1]{%
  \refstepcounter{task}
  \par\addvspace{0.6em}
  \noindent\textbf{\thetask．}#1\par\nobreak
}
\newcommand{\answerarea}[1][2.5cm]{%
  \nobreak\vspace{0.25em}
  \noindent\fbox{%
    \begin{minipage}[t][#1][t]{\dimexpr\linewidth-2\fboxsep-2\fboxrule\relax}
      \small SQL 语句与执行结果：
    \end{minipage}%
  }\par
}
\setlength{\fboxsep}{7pt}
\setlength{\fboxrule}{0.4pt}

\newcommand{\makecover}{%
  \begin{titlepage}
    \thispagestyle{empty}
    \centering
    \vspace*{0.3cm}
    \cqutCoverLogoHorizontal[11.2cm]\par
    \vspace{1.5cm}
    {\heiti\zihao{1} 实验报告书\par}
    \vspace{0.85cm}
    {\heiti\zihao{3} 实验名称：\underline{\makebox[8.2cm][c]{项目一 SQL 语句实践}}\par}
    \vspace{1.85cm}
    {\zihao{4}
      \begin{tabular}{>{\raggedleft\arraybackslash}p{2.0cm}@{\hspace{0.45cm}}p{7.3cm}}
        \coverfield{班\hfill 级}{\reportclass}
        \coverfield{学\hfill 号}{\reportnumber}
        \coverfield{姓\hfill 名}{\reportname}
        \coverfield{指导老师}{\reportteacher}
        \coverfield{实验时间}{\reportdate}
      \end{tabular}
    }
    \vfill
    {\zihao{4} 计算机科学与工程学院\quad 计算机实验室（中心）\par}
    \vspace*{0.5cm}
  \end{titlepage}%
  \setcounter{page}{1}%
}

\endinput
