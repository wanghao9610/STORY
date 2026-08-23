\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{stys/story}[2026/08/23 v0.1 Generic STORY dissertation class]

\newif\ifstory@draft
\story@drafttrue
\DeclareOption{draft}{\story@drafttrue\PassOptionsToClass{draft}{book}}
\DeclareOption{final}{\story@draftfalse\PassOptionsToClass{final}{book}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax
\LoadClass[12pt,openany]{book}

\RequirePackage[letterpaper,margin=1in,bindingoffset=0.25in]{geometry}
\RequirePackage[T1]{fontenc}
\RequirePackage{lmodern}
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

\newcommand{\story@university}{University Name}
\newcommand{\story@department}{Department or Program}
\newcommand{\story@degree}{Doctor of Philosophy}
\newcommand{\story@advisor}{Advisor Name}
\newcommand{\story@committee}{Committee Members}
\newcommand{\story@graduationdate}{Graduation Date}
\newcommand{\story@submissionstatement}{A dissertation submitted in partial fulfillment of the requirements for the degree of}
\newcommand{\story@copyrightyear}{\the\year}

\newcommand{\university}[1]{\gdef\story@university{#1}}
\newcommand{\department}[1]{\gdef\story@department{#1}}
\newcommand{\degree}[1]{\gdef\story@degree{#1}}
\newcommand{\advisor}[1]{\gdef\story@advisor{#1}}
\newcommand{\committee}[1]{\gdef\story@committee{#1}}
\newcommand{\graduationdate}[1]{\gdef\story@graduationdate{#1}}
\newcommand{\submissionstatement}[1]{\gdef\story@submissionstatement{#1}}
\newcommand{\copyrightyear}[1]{\gdef\story@copyrightyear{#1}}

\renewcommand{\maketitle}{%
  \begin{titlepage}
    \centering
    {\Large\bfseries\color{StoryBlue}\@title\par}
    \vspace{2.5cm}
    {\large by\par}
    \vspace{0.5cm}
    {\Large\@author\par}
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
    {Advisor: \story@advisor\par}
    \vspace{0.4cm}
    {Committee: \story@committee\par}
    \vfill
    {\copyright\ \story@copyrightyear\ \@author\par}
  \end{titlepage}
}

\newenvironment{storyabstract}
  {\cleardoublepage\chapter*{Abstract}\addcontentsline{toc}{chapter}{Abstract}}
  {\clearpage}

\newenvironment{storyacknowledgements}
  {\cleardoublepage\chapter*{Acknowledgements}\addcontentsline{toc}{chapter}{Acknowledgements}}
  {\clearpage}

\endinput
