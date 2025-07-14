%-------------------------
% Resume in Latex
% Author : Jake Gutierrez
% Based off of: https://github.com/sb2nov/resume
% License : MIT
%------------------------

\documentclass[letterpaper,11pt]{article}

\usepackage{latexsym}
\usepackage[empty]{fullpage}
\usepackage{titlesec}
\usepackage{marvosym}
\usepackage[usenames,dvipsnames]{color}
\usepackage{verbatim}
\usepackage{enumitem}
\usepackage[hidelinks]{hyperref}
\usepackage{fancyhdr}
\usepackage[english]{babel}
\usepackage{tabularx}
\input{glyphtounicode}


%----------FONT OPTIONS----------
% sans-serif
% \usepackage[sfdefault]{FiraSans}
% \usepackage[sfdefault]{roboto}
% \usepackage[sfdefault]{noto-sans}
% \usepackage[default]{sourcesanspro}

% serif
% \usepackage{CormorantGaramond}
% \usepackage{charter}


\pagestyle{fancy}
\fancyhf{} % clear all header and footer fields
\fancyfoot{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}

% Adjust margins
\addtolength{\oddsidemargin}{-0.5in}
\addtolength{\evensidemargin}{-0.5in}
\addtolength{\textwidth}{1in}
\addtolength{\topmargin}{-.5in}
\addtolength{\textheight}{1.0in}

\urlstyle{same}

\raggedbottom
\raggedright
\setlength{\tabcolsep}{0in}

% Sections formatting
\titleformat{\section}{
  \vspace{-4pt}\scshape\raggedright\large
}{}{0em}{}[\color{black}\titlerule \vspace{-5pt}]

% Ensure that generate pdf is machine readable/ATS parsable
\pdfgentounicode=1

%-------------------------
% Custom commands
\newcommand{\resumeItem}[1]{
  \item\small{
    {#1 \vspace{-2pt}}
  }
}

\newcommand{\resumeSubheading}[4]{
  \vspace{-2pt}\item
    \begin{tabular*}{0.97\textwidth}[t]{l@{\extracolsep{\fill}}r}
      \textbf{#1} & #2 \\
      \textit{\small#3} & \textit{\small #4} \\
    \end{tabular*}\vspace{-7pt}
}

\newcommand{\resumeSubSubheading}[2]{
    \item
    \begin{tabular*}{0.97\textwidth}{l@{\extracolsep{\fill}}r}
      \textit{\small#1} & \textit{\small #2} \\
    \end{tabular*}\vspace{-7pt}
}

\newcommand{\resumeProjectHeading}[2]{
    \item
    \begin{tabular*}{0.97\textwidth}{l@{\extracolsep{\fill}}r}
      \small#1 & #2 \\
    \end{tabular*}\vspace{-7pt}
}

\newcommand{\resumeSubItem}[1]{\resumeItem{#1}\vspace{-4pt}}

\renewcommand\labelitemii{$\vcenter{\hbox{\tiny$\bullet$}}$}

\newcommand{\resumeSubHeadingListStart}{\begin{itemize}[leftmargin=0.15in, label={}]}
\newcommand{\resumeSubHeadingListEnd}{\end{itemize}}
\newcommand{\resumeItemListStart}{\begin{itemize}}
\newcommand{\resumeItemListEnd}{\end{itemize}\vspace{-5pt}}

%-------------------------------------------
%%%%%%  RESUME STARTS HERE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%


\begin{document}

\begin{center}
    \textbf{\Huge \scshape Karanja Mutahi} \\ \vspace{3pt}
    \small (+44) 07880967494 $|$ \href{mailto:mutahi.henry@gmail.com}{\underline{mutahi.henry@gmail.com}} $|$ 
    \href{https://linkedin.com/in/karanjamutahi}{\underline{linkedin.com/in/karanjamutahi}} $|$
    \href{https://github.com/karanjamutahi}{\underline{github.com/karanjamutahi}}
\end{center}


%-----------EDUCATION-----------
\section{Education}
  \resumeSubHeadingListStart
    \resumeSubheading
      {Jomo Kenyatta University of Agriculture \& Technology}{Nairobi,}
      {Bachelor of Science in Electrical \& Electronics Engineering}{Sep 2015 - Nov 2021}
  \resumeSubHeadingListEnd


%-----------EXPERIENCE-----------
\section{Experience}
  \resumeSubHeadingListStart
  
  \resumeSubheading
      {Software Engineer}{July 2021 - Present}
      {Goldman Sachs}{London, UK}
      \resumeItemListStart
        \resumeItem{Implemented a job to send periodic alerts of built-up errors that increased visibility of system faults and \textbf{led to a 19\% increase in resolved exceptions.}}
        \resumeItem{Implemented a continuous deployment pipeline to Kubernetes that introduced code versioning for preproduction environments, led to \textbf{faster release cycles (every two days from once a week)} and faster, safer rollbacks. }
        \resumeItem{Implemented a gRPC web service to manage loan trades and persist data on Spanner. Led to \textgreater90\% reduction in data quality issues due to a clear data contract.}
      \resumeItemListEnd
    
    \resumeSubheading
      {Software Engineer}{April 2021 -- July 2021}
      {Microsoft}{Nairobi, KE}
      \resumeItemListStart
        \resumeItem{Removed dead code surrounding a deprecated feature and reworked associated tests that touched about 4\% of the module's code base}
      \resumeItemListEnd
      
    \resumeSubheading
      {Software Engineering Intern}{July 2020 -- Aug 2020}
      {Goldman Sachs}{London, UK}
      \resumeItemListStart
        \resumeItem{Implemented a proof of concept of a distributed cache service on Apache Ignite which \textbf{reduced initial fetch time by 55\% across all deplomeyment regions. }}
        \resumeItem{Implemented a metrics collection service in Prometheus format which served as a service level indicator. \textbf{Increased the firm's monitored services by 2 \& improved the team's SRE compliance}}
      \resumeItemListEnd
      
% -----------Multiple Positions Heading-----------
%    \resumeSubSubheading
%     {Software Engineer I}{Oct 2014 - Sep 2016}
%     \resumeItemListStart
%        \resumeItem{Apache Beam}
%          {Apache Beam is a unified model for defining both batch and streaming data-parallel processing pipelines}
%     \resumeItemListEnd
%    \resumeSubHeadingListEnd
%-------------------------------------------

    \resumeSubheading
      {Software Engineering Contractor}{July 2019 -- Feb 2020}
      {Novek Enterprises}{Nairobi, KE}
      \resumeItemListStart
        \resumeItem{Implemented a mobile money billing feature and an MQTT telemetry feature for a proof of concept of a liquid cooking oil vending machine in C++. }
    \resumeItemListEnd

    \resumeSubheading
      {Software Engineering Intern}{July 2018 -- Nov 2018}
      {BRCK Inc.}{Nairobi, KE}
      \resumeItemListStart
        \resumeItem{Implemented a visualization script in Python to fetch datapoints from IoT devices in the field and display them on a Google Sheet for monthly customer reports. \textbf{Reduced report generation time from 4 hours to 15 minutes}}
      \resumeItemListEnd

  \resumeSubHeadingListEnd


%-----------PROJECTS-----------
\section{Projects}
    \resumeSubHeadingListStart
      \resumeProjectHeading
          {\textbf{Jacobian Project} $|$ \emph{Flask, Vue.js, Nuxt.js, PostgreSQL,Docker}}{\href{https://jacobianproject.vercel.app}{\color{blue}Link}}
          \resumeItemListStart
            \resumeItem{Developed a full-stack web application using with Flask serving a REST API with Server-Side-Rendered Vue (Nuxt.js) as the frontend}
          \resumeItemListEnd

      \resumeProjectHeading
          {\textbf{Mess Bot} $|$ \emph{Telegram Bot API, Node.JS, NLTK}}{\href{https://t.me/jku_mess_bot}{\color{blue}Link}}
          \resumeItemListStart
            \resumeItem{Built a Telegram Chat Bot to facilitate asynchronous food ordering and collection from the school cafeteria}
            \resumeItem{Learned about handling free-form text input via tokenization}
          \resumeItemListEnd
    \resumeSubHeadingListEnd

%
%-----------PROGRAMMING SKILLS-----------
\section{Technical Skills}

 \begin{itemize}[leftmargin=0.15in, label={}]
    \small{\item{
     \textbf{Languages}{: Java, Python, Javascript, C/C++, Golang} \\
     \textbf{Frameworks}{: React, Vue js, Flask, Spring, Tailwind, Gorilla} \\
     \textbf{Tools \& Platforms}{: Git, Docker, GCP, Azure, Kubernetes, CI/CD }
    }}
 \end{itemize}

%-------------------------------------------

%------------LEADERSHIP EXPERIENCE--------
\section{Awards}
    \resumeItemListStart
        \resumeItem{Shadowed the CTO following good performance on the Goldman Sachs Internship program. Got a first hand view of high level decisions and learned a lot about leading a large technology organisation}
        \resumeItem{Won the National Level of the Microsoft Imagine Cup 2018}
    \resumeItemListEnd

\end{document}
