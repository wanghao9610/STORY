\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{stys/story}[2026/08/23 v0.2 English and Chinese STORY dissertation class]

\newif\ifstory@draft
\newif\ifstory@chinese
\story@drafttrue
\story@chinesefalse
\DeclareOption{draft}{\story@drafttrue}
\DeclareOption{final}{\story@draftfalse}
\DeclareOption{en}{\story@chinesefalse}
\DeclareOption{english}{\story@chinesefalse}
\DeclareOption{zh}{\story@chinesetrue}
\DeclareOption{chinese}{\story@chinesetrue}
\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{book}%
  \PassOptionsToClass{\CurrentOption}{ctexbook}%
}
\ProcessOptions\relax

\ifstory@draft
  \PassOptionsToClass{draft}{book}
  \PassOptionsToClass{draft}{ctexbook}
\else
  \PassOptionsToClass{final}{book}
  \PassOptionsToClass{final}{ctexbook}
\fi

\ifstory@chinese
  \LoadClass[UTF8,scheme=chinese,fontset=fandol,zihao=-4,openany]{ctexbook}
\else
  \LoadClass[12pt,openany]{book}
\fi

\RequirePackage[letterpaper,margin=1in,bindingoffset=0.25in]{geometry}
\ifstory@chinese\else
  \RequirePackage[T1]{fontenc}
  \RequirePackage{lmodern}
\fi
\RequirePackage{microtype}
\RequirePackage{setspace}
\RequirePackage{xcolor}
\RequirePackage{graphicx}
\RequirePackage{booktabs}
\RequirePackage{amsmath,amssymb}
\RequirePackage[numbers,sort&compress]{natbib}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage[nameinlink,noabbrev]{cleveref}

\definecolor{StoryBlue}{HTML}{173B57}
\definecolor{StoryGold}{HTML}{B58A3A}
\hypersetup{colorlinks=true,linkcolor=StoryBlue,citecolor=StoryBlue,urlcolor=StoryBlue}
\onehalfspacing
\setcounter{secnumdepth}{3}
\setcounter{tocdepth}{2}
\raggedbottom

\ifstory@chinese
  \newcommand{\story@university}{学校名称}
  \newcommand{\story@department}{院系或培养单位}
  \newcommand{\story@degree}{博士学位}
  \newcommand{\story@advisor}{导师姓名}
  \newcommand{\story@committee}{学位评定委员会成员}
  \newcommand{\story@graduationdate}{完成日期}
  \newcommand{\story@submissionstatement}{学位论文}
\else
  \newcommand{\story@university}{University Name}
  \newcommand{\story@department}{Department or Program}
  \newcommand{\story@degree}{Doctor of Philosophy}
  \newcommand{\story@advisor}{Advisor Name}
  \newcommand{\story@committee}{Committee Members}
  \newcommand{\story@graduationdate}{Graduation Date}
  \newcommand{\story@submissionstatement}{A dissertation submitted in partial fulfillment of the requirements for the degree of}
\fi
\newcommand{\story@copyrightyear}{\the\year}

\newcommand{\university}[1]{\gdef\story@university{#1}}
\newcommand{\department}[1]{\gdef\story@department{#1}}
\newcommand{\degree}[1]{\gdef\story@degree{#1}}
\newcommand{\advisor}[1]{\gdef\story@advisor{#1}}
\newcommand{\committee}[1]{\gdef\story@committee{#1}}
\newcommand{\graduationdate}[1]{\gdef\story@graduationdate{#1}}
\newcommand{\submissionstatement}[1]{\gdef\story@submissionstatement{#1}}
\newcommand{\copyrightyear}[1]{\gdef\story@copyrightyear{#1}}
\newcommand{\storylocalized}[2]{%
  \ifstory@chinese#2\else#1\fi}

\renewcommand{\maketitle}{%
  \begin{titlepage}
    \centering
    {\Large\bfseries\color{StoryBlue}\@title\par}
    \vspace{2.5cm}
    \ifstory@chinese
      {\large 作者：\@author\par}
    \else
      {\large by\par}
      \vspace{0.5cm}
      {\Large\@author\par}
    \fi
    \vfill
    {\story@submissionstatement\par}
    \vspace{0.4cm}
    {\large\bfseries\story@degree\par}
    \vspace{0.8cm}
    {\story@department\par}
    {\story@university\par}
    \vspace{0.8cm}
    {\story@graduationdate\par}
    \vfill
    \ifstory@chinese
      {指导教师：\story@advisor\par}
      \vspace{0.4cm}
      {学位评定委员会：\story@committee\par}
    \else
      {Advisor: \story@advisor\par}
      \vspace{0.4cm}
      {Committee: \story@committee\par}
    \fi
    \vfill
    {\copyright\ \story@copyrightyear\ \@author\par}
  \end{titlepage}
}

\ifstory@chinese
  \newenvironment{storyabstract}
    {\cleardoublepage\chapter*{摘要}\addcontentsline{toc}{chapter}{摘要}}
    {\clearpage}

  \newenvironment{storyacknowledgements}
    {\cleardoublepage\chapter*{致谢}\addcontentsline{toc}{chapter}{致谢}}
    {\clearpage}

  \newenvironment{storydeclaration}
    {\cleardoublepage\chapter*{声明}\addcontentsline{toc}{chapter}{声明}}
    {\clearpage}

  \newcommand{\storykeywords}[1]{\par\medskip\noindent\textbf{关键词：}#1}

  \crefname{chapter}{章}{章}
  \crefname{section}{节}{节}
  \crefname{figure}{图}{图}
  \crefname{table}{表}{表}
  \crefname{equation}{式}{式}
  \crefname{appendix}{附录}{附录}
\else
  \newenvironment{storyabstract}
    {\cleardoublepage\chapter*{Abstract}\addcontentsline{toc}{chapter}{Abstract}}
    {\clearpage}

  \newenvironment{storyacknowledgements}
    {\cleardoublepage\chapter*{Acknowledgements}\addcontentsline{toc}{chapter}{Acknowledgements}}
    {\clearpage}

  \newenvironment{storydeclaration}
    {\cleardoublepage\chapter*{Declaration}\addcontentsline{toc}{chapter}{Declaration}}
    {\clearpage}

  \newcommand{\storykeywords}[1]{\par\medskip\noindent\textbf{Keywords: }#1}
\fi

\endinput
