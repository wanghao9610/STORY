\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{stys/story}[2026/09/24 v0.4 English and Chinese STORY thesis class]

\newif\ifstory@draft
\newif\ifstory@chinese
\newif\ifstory@cjk
\story@drafttrue
\story@chinesefalse
\story@cjkfalse
\DeclareOption{draft}{\story@drafttrue}
\DeclareOption{final}{\story@draftfalse}
\DeclareOption{en}{\story@chinesefalse}
\DeclareOption{english}{\story@chinesefalse}
\DeclareOption{zh}{\story@chinesetrue}
\DeclareOption{chinese}{\story@chinesetrue}
\DeclareOption{cjk}{\story@cjktrue}
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

%% A4 is the near-universal thesis paper size outside North America and the
%% default for Chinese institutions; a letterpaper program can override this in
%% its official template layer.
\RequirePackage[a4paper,margin=1in,bindingoffset=0.25in]{geometry}
%% The cjk option lets an English thesis typeset Chinese text, such as a
%% required Chinese abstract: under XeLaTeX or LuaLaTeX it loads ctex with the
%% zh branch's fonts and scheme=plain, which leaves English headings and layout
%% as they are. Under pdfLaTeX it stops with an error; the zh branch ignores it.
%% iftex loads first so a skipped branch still sees \iftutex as a conditional.
\RequirePackage{iftex}
\ifstory@chinese\else
  \ifstory@cjk
    \iftutex
      \RequirePackage[UTF8,scheme=plain,fontset=fandol]{ctex}
    \else
      \ClassError{stys/story}
        {The cjk option needs XeLaTeX or LuaLaTeX, not pdfLaTeX.\MessageBreak
         Add `\@percentchar\space !TeX program = xelatex' (or lualatex)\MessageBreak
         as the entry point's first line}
        {Chinese text needs ctex, which this class loads only under XeLaTeX or LuaLaTeX.}
      \story@cjkfalse
    \fi
  \fi
  \ifstory@cjk\else
    \RequirePackage[T1]{fontenc}
    \RequirePackage{lmodern}
  \fi
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
  \newcommand{\story@degree}{学位名称}
  \newcommand{\story@advisor}{导师姓名}
  \newcommand{\story@committee}{}
  \newcommand{\story@graduationdate}{完成日期}
  \newcommand{\story@submissionstatement}{提交说明}
\else
  \newcommand{\story@university}{University Name}
  \newcommand{\story@department}{Department or Program}
  \newcommand{\story@degree}{Degree Name}
  \newcommand{\story@advisor}{Advisor Name}
  \newcommand{\story@committee}{}
  \newcommand{\story@graduationdate}{Graduation Date}
  \newcommand{\story@submissionstatement}{Submission Statement}
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
    \ifx\story@submissionstatement\@empty\else
      {\story@submissionstatement\par}
      \vspace{0.4cm}
    \fi
    {\large\bfseries\story@degree\par}
    \vspace{0.8cm}
    {\story@department\par}
    {\story@university\par}
    \vspace{0.8cm}
    {\story@graduationdate\par}
    \vfill
    \ifstory@chinese
      {指导教师：\story@advisor\par}
      \ifx\story@committee\@empty\else
        \vspace{0.4cm}
        {学位评定委员会：\story@committee\par}
      \fi
    \else
      {Advisor: \story@advisor\par}
      \ifx\story@committee\@empty\else
        \vspace{0.4cm}
        {Committee: \story@committee\par}
      \fi
    \fi
    \vfill
    {\copyright\ \story@copyrightyear\ \@author\par}
  \end{titlepage}
}

%% storyabstract and \storykeywords take an optional language, en or zh, that
%% defaults to the class language, so a thesis can also carry an abstract in
%% its other language. Chinese text in an English thesis needs the cjk option.
\newcommand{\story@language}{\ifstory@chinese zh\else en\fi}
\newif\ifstory@zhtext
\newcommand{\story@textlanguage}[1]{%
  \edef\story@tempa{#1}\def\story@tempb{zh}%
  \ifx\story@tempa\story@tempb
    \story@zhtexttrue
  \else
    \story@zhtextfalse
    \def\story@tempb{en}%
    \ifx\story@tempa\story@tempb\else
      \ClassError{stys/story}{Unknown language `\story@tempa'}
        {The optional language of storyabstract and \string\storykeywords\space is en or zh.}%
    \fi
  \fi}

\newenvironment{storyabstract}[1][\story@language]
  {\story@textlanguage{#1}%
   \cleardoublepage
   \ifstory@zhtext
     \chapter*{摘要}\addcontentsline{toc}{chapter}{摘要}%
   \else
     \chapter*{Abstract}\addcontentsline{toc}{chapter}{Abstract}%
   \fi}
  {\clearpage}

\newcommand{\storykeywords}[2][\story@language]{%
  \story@textlanguage{#1}%
  \par\medskip\noindent\textbf{\ifstory@zhtext 关键词：\else Keywords: \fi}#2}

\ifstory@chinese
  \newenvironment{storyacknowledgements}
    {\cleardoublepage\chapter*{致谢}\addcontentsline{toc}{chapter}{致谢}}
    {\clearpage}

  \newenvironment{storydeclaration}
    {\cleardoublepage\chapter*{声明}\addcontentsline{toc}{chapter}{声明}}
    {\clearpage}

  \crefname{chapter}{章}{章}
  \crefname{section}{节}{节}
  \crefname{figure}{图}{图}
  \crefname{table}{表}{表}
  \crefname{equation}{式}{式}
  \crefname{appendix}{附录}{附录}
\else
  \newenvironment{storyacknowledgements}
    {\cleardoublepage\chapter*{Acknowledgements}\addcontentsline{toc}{chapter}{Acknowledgements}}
    {\clearpage}

  \newenvironment{storydeclaration}
    {\cleardoublepage\chapter*{Declaration}\addcontentsline{toc}{chapter}{Declaration}}
    {\clearpage}
\fi

\endinput
