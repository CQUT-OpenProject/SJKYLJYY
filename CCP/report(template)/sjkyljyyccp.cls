\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sjkyljyyccp}[2026/11/02 SJKYLJYY database-design report]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{cqutreport}}
\ProcessOptions\relax
\LoadClass{cqutreport}

\RequirePackage[a4paper,top=2.54cm,bottom=2.54cm,left=3.18cm,right=3.18cm]{geometry}
\RequirePackage{array}
\RequirePackage{xcolor}
\RequirePackage{listings}
\RequirePackage{needspace}
\RequirePackage{hyperref}
\hypersetup{hidelinks,plainpages=false,pdftitle={数据库设计实践项目报告书}}
\graphicspath{{assets/}}
\pagestyle{plain}

\ctexset{
  contentsname = {目\quad 录},
  section = {
    name = {,},
    number = \arabic{section},
    format = \heiti\bfseries\zihao{3},
    aftername = \quad,
    beforeskip = 12pt,
    afterskip = 6pt
  },
  subsection = {
    number = \arabic{section}.\arabic{subsection},
    format = \heiti\bfseries\zihao{4},
    aftername = \quad,
    beforeskip = 8pt,
    afterskip = 4pt
  }
}
\setcounter{tocdepth}{2}
\setcounter{secnumdepth}{3}

% 保证标题下方留有正文空间，避免填写提示换页后留下孤立标题。
\let\report@originalsection\section
\renewcommand{\section}{\Needspace{5\baselineskip}\report@originalsection}
\let\report@originalsubsection\subsection
\renewcommand{\subsection}{\Needspace{4\baselineskip}\report@originalsubsection}

% 封面信息在 template.tex 中填写，默认保留原 Word 框架的空白。
\newcommand{\reportproject}{数据库设计}
\newcommand{\reporttopic}{}
\newcommand{\reportclass}{}
\newcommand{\reportnumber}{}
\newcommand{\reportname}{}
\newcommand{\reportphone}{}
\newcommand{\reportteacher}{}
\newcommand{\reportdate}{2026.10—2026.11}
\newcommand{\reportpartners}{}

\newcommand{\coverfield}[2]{%
  \makebox[2.2cm][l]{#1}： &
  \underline{\makebox[7.4cm][c]{#2}}\\[0.38cm]
}

\newcommand{\makecover}{%
  \hypersetup{pageanchor=false}%
  \begin{titlepage}
    \thispagestyle{empty}
    \begingroup
    \setstretch{1}
    \centering
    \vspace*{0.3cm}
    \makebox[\textwidth][c]{\cqutCoverLogoHorizontal[11.8cm]}\par
    \vspace{1.3cm}
    {\heiti\bfseries\fontsize{42pt}{54pt}\selectfont 实践项目报告书\par}
    \vspace{1.5cm}
    {\zihao{4}\bfseries
      \begin{tabular}{>{\raggedleft\arraybackslash}p{2.6cm}@{\hspace{0.3cm}}l}
        \coverfield{实践项目}{\reportproject}
        \coverfield{实践题目}{\reporttopic}
        \noalign{\vskip 0.35cm}
        \coverfield{班\hfill 级}{\reportclass}
        \coverfield{学\hfill 号}{\reportnumber}
        \coverfield{姓\hfill 名}{\reportname}
        \coverfield{联系电话}{\reportphone}
        \coverfield{指导老师}{\reportteacher}
        \coverfield{实验时间}{\reportdate}
        \coverfield{同组同学}{\reportpartners}
      \end{tabular}\par
    }
    \vfill
    {\zihao{4}\bfseries 计算机科学与工程学院\quad 计算机实验室（中心）\par}
    \vspace*{0.5cm}
    \endgroup
  \end{titlepage}%
  \pagenumbering{arabic}%
  \hypersetup{pageanchor=true}%
}

\newcommand{\makereportcontents}{%
  \begingroup
    \ctexset{section={format=\centering\heiti\zihao{2},beforeskip=0pt,afterskip=20pt}}%
    \tableofcontents
  \endgroup
  \clearpage
}

% 原框架中的红色文字是填写说明，完成报告时应替换为实际内容。
\newcommand{\templatehint}[1]{%
  \begingroup
    \color{red}\zihao{5}\setstretch{1.5}%
    #1\par
  \endgroup
}

% SQL 可直接用 lstlisting 排版，或用 \lstinputlisting 导入独立脚本。
\lstdefinestyle{reportsql}{
  language=SQL,
  basicstyle=\ttfamily\cqutCodeFontSize,
  keywordstyle=\bfseries,
  commentstyle=\color{gray},
  columns=fullflexible,
  keepspaces=true,
  breaklines=true,
  showstringspaces=false,
  tabsize=4,
  frame=single,
  aboveskip=0.6em,
  belowskip=0.6em
}
\lstset{style=reportsql}

\endinput
