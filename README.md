# An R Package for Building Books or Documents using `pandoc`

[<img alt="Travis CI Build Status" src="http://img.shields.io/travis/thomasWeise/bookbuildeR/master.svg" height="20"/>](http://travis-ci.org/thomasWeise/bookbuildeR/)

1. [Introduction](#1-introduction)
2. [Features via Extented Markdown](#2-features-via-extented-markdown)
3. [Running the Tool Chain Locally](#3-automated-local-book-compilation-based-on-pandoc-calibre-and-docker)
4. [Running the Tool Chain in the Cloud / via GitHub + Travis CI](#4-an-automatic-online-book-building-approach-by-using-github-and-travis-ci)
5. [Related Projects and Building Blocks](#5-related-projects-and-components)
6. [License](#6-license)
7. [Contact](#7-contact)
8. [Links](#8-links)

**[This package is now obsolete and no longer maintained. Please check `thomasWeise/bookbuilderpy` for a new and improved version.](https://github.com/thomasWeise/bookbuilderpy)**

## 1. Introduction

This is an `R` package intended for building electronic books from [pandoc's markdown flavor](http://pandoc.org/MANUAL.html#pandocs-markdown) by using, well, [pandoc](http://pandoc.org/) and [`R`](http://www.r-project.org/).
You can see it in action in our project [An Introduction to Optimization Algorithms](https://github.com/thomasWeise/aitoa), which is written in Markdown and automatically converted to [pdf](http://thomasweise.github.io/aitoa/aitoa.pdf), [html](http://thomasweise.github.io/aitoa/aitoa.html), 
[epub](http://thomasweise.github.io/aitoa/aitoa.epub), and [azw3](http://thomasweise.github.io/aitoa/aitoa.azw3) by using this package.
Our package aims at making it easier to dynamically write books and even publish them online by reducing most of the work to the invocation of a single command.
It therefore extends the standard tools provided by pandoc with a set of additional commands.

The package is the basis for our [docker](https://en.wikipedia.org/wiki/Docker_(software)) container "[thomasweise/docker-bookbuilder](http://hub.docker.com/r/thomasweise/docker-bookbuilder/)" at Docker Hub.
The sources of this container are provided in the [GitHub](http://www.github.com) repository [thomasWeise/docker-bookbuilder](https://github.com/thomasWeise/docker-bookbuilder).
The container includes all necessary software components needed to run and build electronic books by using the scripts here, such as complete installations of [pandoc](http://pandoc.org/), [`R`](http://www.r-project.org/), and [TeX Live](http://tug.org/texlive/).

It is suitable for the integration into a CI environment, which can be used to completely automate the development of electronic books.

**[This package is now obsolete and no longer maintained. Please check `thomasWeise/bookbuilderpy` for a new and improved version.](https://github.com/thomasWeise/bookbuilderpy)**

## 2. Features via Extented Markdown

If you use this tool chain, you will write the book in [pandoc flavored markdown flavor](http://pandoc.org/MANUAL.html#pandocs-markdown).
However, we introduce some additional features to make life easier.
For instance, pandoc traditionally processes a list of files sequentially.
If you write a larger book, however, you may sometimes want to insert a section as a new file into a chapter.
Thus, we add commands so that you can structure your book as a hierarchy of files where each file can "include" other files, making it unnecessary to maintain a global file order in a single location.
Also, you may want to include the current date or repository commit into the book &ndash; and there are now commands for that as well.
Thus, we provide several additional commands to ease the work on books, especially for the fields of computer science and mathematics.

### 2.1. Added Functionality

The core facility is the hierarchical inclusion and referencing of files, which allows for a more 'decentralized' working method, where the global book structure results from the locally included files and does not need to be known in the root document.
You can easily modify the book structure by including files and nesting folders in your current working directory without going back and forth to the main document.
We also add commands also allow you to define and reference proof/definition/...-like environments.

Furthermore, the added commands allow for dynamically linking to a "source code repository".
Let's say you write a book about Java.
You would then probably want to have a lot of programming examples.
You can keep these in a separate source code repository, e.g., on GitHub.
This repository could also feature build and test scripts, etc., and could be a fully functional application or library.
The book's sources then can reside in a different repository and are thus separate from the programming code examples.
You can specify this repository as `codeRepo` in the book's [YAML](http://en.wikipedia.org/wiki/Yaml) metadata.
The source code repository is automatically cloned during the book building process and all of its files are accessible.
You even have access to the commit id of the source code repository, so that you can print it in the book and thus allow the readers to go back to exactly the right version of the code even if you further improve the code in the future.

The scripts of our package are to be used from the command line.
The functions are is designed to hard-fail on any error, so you can directly see if there is a problem instead of having some garbage output somewhere in your compiled book.

This package, together with a complete installation of [pandoc](http://pandoc.org/), [`R`](http://www.r-project.org/), [TeX Live](http://tug.org/texlive/), [calibre](http://calibre-ebook.com), and all other necessary tools is available as a Docker image at http://hub.docker.com/r/thomasweise/docker-bookbuilder.
Thus, you can use it as tool for all your book-writing purposes.
You may even integrate it with [Travis CI](http;//travis-ci.org) and [GitHub](http://www.github.com), as described [here](http://iao.hfuu.edu.cn/157) to achieve a fully-automated book writing and publishing tool chain.

### 2.2. Provided Commands

You can now use the following commands in your markdown:

- `\relative.path{path}` is a path expression relative to the currently processed file's directory which will be resolved to be relative to the root folder of the document. This is intended to allow you to place chapters and sections in a hierarchical folder structure and their contained images in sub-folders, while referencing them relatively from the current path.
- `\relative.input{file}` is a command similar to `\relativel.path`. If this command is used, it must be the only text/command on the current line. It will resolve the path to `file` relative to the directory of the current file and *recursively* include that file. This is another tool to allow for building documents structured in chapters, sections, and folders without needed to specify the overall, global structure anywhere and instead specify the inclusion of files where they are actually needed. 
- `\meta.time` prints the current date and time.
- `\meta.date` prints the current date.
- `\meta.year` prints the current year.
- `\text.block{type}{label}{body}` creates a text block by putting the title-cased `type` together with the block number in front in double-emphasis (the blocks of each type are numbered separately) and then the `body`. `\text.block{definition}{d1}{blabla} \text.block{definition}{d2}{blubblub}` will render to `**Defininition&nbsp;1:**&nbsp;blabla**Defininition&nbsp;2:**&nbsp;blubblub` in the Markdown to be processed by pandoc. Blocks can be referenced in the text via their `label` in `\text.ref{label}`. The goal is to achieve theorem-style environments, but on top of markdown.
- `\text.ref{label}` references a text block with the same label (see command above). In the example given above, `\text.ref{d2}` would render to `Definition&nbsp;2` in the Markdown.
- `\relative.code{path}{lines}{tags}` inserts the content of a file identified by the path `path` which is interpreted relative to the current file. Different from `\relative.input`, this is intented for reading code and this command therefore provides two content selection mechanisms: `lines` allows you to specify lines to insert, e.g., `20:22,1:4,7` would insert the lines 1 to 4, 7, and 20 to 22 (in that order). `tags` allows you to specify a comma-separated list of tags. A tag is a string, say "example1", and then everything between a line containing "start example1" and a line "end example1" is included. The idea is that you would put these start and end markers into line comments (in R starting with "#", in Java with "//"). If you specify multiple tags, the corresponding bodies are merged. If you specify both \code{lines} and \code{tags}, we first apply the line selection and then the tag selection only on the selected lines.
- `\repo.code{path}{lines}{tags}` if and only if you specify a `codeRepo` url in your YAML metadata of the book, you can use this command, which allows you to download and access a repository with source code. This way, you can have a book project in one repository and a repository with separate, working, executable examples somewhere else. This second repository, identified by `codeRepo`, will be cloned once. Then, the path `path` is interpreted relative to the root path of the repository and you can include code from that repository in the same fashion as with `\relative.code`.
- `\repo.listing{label}{caption}{language}{path}{lines}{tags}` puts the result of `\repo.code{path}{lines}{tags}` into a markdown/pandoc-crossref compatible listing environment that can be referenced via `[@label]` (where `label` should start with `lst:`), has caption `caption`, and is formatted for programming language `language`. Furthermore, this method also automatically removes meta-comments, such as `/** ... */` in Java or `#' ..` in R, a feature currently only implemented for Java and R. If the source code repository resides on GitHub, this method will also append a link of the form `(src)` to the caption which goes to the file in the repository.
- `\repo.name` is replaced with  the source code repository name provided as `codeRepo` in the YAML metadata, without a trailing `.git`, if any.
- `\repo.commit` is replaced with the commit of the source code repository that was downloaded an during the book building procedure.
- `\direct.r{rcode}` directly executes a piece `rcode` of `R` code. If the code writes any output via, e.g., `cat(..)`, then this output is pasted into the file. If the code does not produce such output, the its return value is transformed to a string and pasted.
- `\relative.r{path}` similar to `\direct.r`, but instead execute the file refered by `path`, which is relative to the current directory.

The following commands will only work within [Travis CI](http://travis-ci.org/) builds and (intentionally) crash otherwise:

- `\meta.repository` get the repository in format `owner/repository`, taken from the environment variable `TRAVIS_REPO_SLUG` or, if that is not defined, `REPOSITORY`
- `\meta.commit` get the commit id, taken from the environment variable `TRAVIS_COMMIT`, or, if that not exists, `COMMIT`

### 2.3. Graphics

Generally, we suggest to use only [vector graphics](http://en.wikipedia.org/wiki/Vector_graphics) in your books, as opposed to [raster graphics](http://en.wikipedia.org/wiki/Raster_graphics) like [`jpg`](http://en.wikipedia.org/wiki/JPEG) or [`png`](http://en.wikipedia.org/wiki/Portable_Network_Graphics).
Don't use `jpg` or `png` for anything different from photos.
Vector graphics can scale well and have a higher quality when being printed or when being zoomed in.
Raster graphics often get blurry or even display artifacts.

In my opinion, the best graphics format to use in conjunction with our tool is [`svg`](http://en.wikipedia.org/wiki/Scalable_Vector_Graphics) (and, in particular, its compressed variant `svgz`).
You can create `svg` graphics using the open-source editor [Inkscape](http://en.wikipedia.org/wiki/Inkscape) or software such as [Adobe Illustrator](http://en.wikipedia.org/wiki/Adobe_Illustrator) or [Corel DRAW](http://en.wikipedia.org/wiki/CorelDRAW).

We provide the small tool [ultraSvgz](http://github.com/thomasWeise/ultraSvgz), which runs under Linux and can create very small, minified and compressd `svgz` files from `svg`s.
Our tool suite supports `svgz` fully and such files tend to actually be smaller than [`pdf`](http://en.wikipedia.org/wiki/PDF) or [`eps`](http://en.wikipedia.org/wiki/Encapsulated_PostScript) graphics.

## 3. Automated Local Book Compilation based on `pandoc`, `calibre`, and `docker`

You can apply this package locally to a book or document you write on your computer.
In order to avoid installing all required software and even to avoid messing with `R`, you can use the [docker container](http://hub.docker.com/r/thomasweise/docker-bookbuilder/) we have developed for this purpose.
[Docker](https://en.wikipedia.org/wiki/Docker_(software)) is something like a light-weight virtual machine, and our container is basically a copy of a complete Linux installation with all required components that you can run on your local computer.

By using our container, the following output formats will automatically be generated:

- [`PDF`](http://en.wikipedia.org/wiki/Pdf) for reading on the computer and/or printing,
- [`EPUB3`](http://en.wikipedia.org/wiki/EPUB) for reading on most mobile phones or other hand-held devices,
- [`AZW3`](http://en.wikipedia.org/wiki/Kindle_File_Format) for reading on [Kindle](http://en.wikipedia.org/wiki/Amazon_Kindle) and similar devices, and
- stand-alone [`HTML5`](http://en.wikipedia.org/wiki/HTML5) for reading in a web browser on any device.

Additionally, a file named `index.html` will be created, which is a rundimentary directory index listing the above four generated files with their sizes and description.

If you have Linux and docker installed on your system, all what it takes is the following command:

      docker run -v "INPUT_DIR":/input/ \
                 -v "OUTPUT_DIR":/output/ \
                 -e COMMIT=MY_COMMIT \
                 -e REPOSITORY=MY_REPOSITORY_NAME \
                 -t -i thomasweise/docker-bookbuilder BOOK_ROOT_MD_FILE YOUR_BOOK_OUTPUT_BASENAME

Here, it is assumed that

- `INPUT_DIR` is the directory where your book sources reside, let's say `/home/my/book/sources/`.
- `BOOK_ROOT_MD_FILE` is the root file of your book, say `book.md` (in which case, the full path of `book.md` would be `/home/my/book/sources/book.md`). Notice that you can specify only a single file, but this file can reference other files in sub-directories of `INPUT_DIR` by using commands such as  `\relative.input`.
- `OUTPUT_DIR` is the output directory where the compiled files should be placed, e.g., `/home/my/book/compiled/`. This is where the resulting files will be placed.
- `YOUR_BOOK_OUTPUT_BASENAME` is the basis for the names of the compiled files, e.g., `coolBook`, which would lead to the creation of `coolBook.pdf`, `coolBook.html`, and `coolBook.epub` in the folder references by `OUTPUT_DIR`.
- If you make use of the command `\meta.commit`, you need to tell the container a commit-id. Only in this case, you need to specify the parameter "`-e COMMIT=MY_COMMIT`", where `MY_COMMIT` must be replaced with that id. Otherwise, you can leave this parameter away.
- If you make use of the command `\meta.repository`, you need to tell the container a commit-id. Only in this case, you need to specify the parameter "`-e REPOSITORY=MY_REPOSITORY_NAME`", where `MY_REPOSITORY_NAME` must be replaced with that id. Otherwise, you can leave this parameter away.

And that's it.
No software installation, besides docker, is required.
The container brings all required tools, scripts, packages, and what not.
Additionally, in the section below you can see how the whole build process can be automated by using continuous integration tool chains.

## 4. An Automatic Online-Book Building Approach by Using `GitHub` and `Travis-CI`

With our package and associated docker container, you can conveniently build your electronic book on your computer with a single command.
However, you can also integrate the whole process with a [version control](http://en.wikipedia.org/wiki/Version_control) software like [Git](http://en.wikipedia.org/wiki/Git) and a [continuous integration](http://en.wikipedia.org/wiki/Continuous_integration) framework.
Then, you can automate the compilation of your book to run every time you change your book sources.
Actually, there are several open source and free environments that you can use to that for you for free &ndash; in exchange for you making your book free for everyone to read.

First, both for writing and hosting the book, we suggest to use a [GitHub](http://www.github.com/) repository, very much like the one for the book I just began working on [here](http://github.com/thomasWeise/aitoa).
The book should be written in [Pandoc's markdown](http://pandoc.org/MANUAL.html#pandocs-markdown) syntax, which allows us to include most of the stuff we need, such as equations and citation references, with the additional comments listed above.
For building the book, we will use [Travis CI](http://travis-ci.org/), which offers a free integration with GitHub to build open source software - triggered by repository commits.

Every time you push a commit to your book repository, Travis CI will be notified, and check out the repository.
But we have to tell Travis CI what to do with out book's sources, namely to compile them with [Pandoc](http://pandoc.org/), which we have packaged with all necessary tools and filters into a [docker container](http://hub.docker.com/r/thomasweise/docker-bookbuilder/).
Once Travis has finished downloading the container and building the book with it, it can "deploy" the produced files.

For this purpose, we make use of [GitHub Pages](http://help.github.com/articles/what-is-github-pages/), a feature of [GitHub](http://www.github.com) which allows you to have a website for a repository.
So we simply let Travis deploy the compiled book, in PDF and EPUB, to the book's repository website.
Once the repository, website, and Travis build procedure are all set up, we can concentrate on working on our book and whenever some section or text is finished, commit, and enjoy the automatically new versions.

Having your book sources on GitHub brings several additional advantages, for instance:

- Since the book's sources are available as GitHub repository, our readers can file issues to the repository, with change suggestions, discovered typos, or with questions to add clarification.
- They may even file pull requests with content to include.
- You could also write a book collaboratively &ndash; like a software project. This might also be interesting for students who write course notes together.

### 4.1. The Repository

In order to use our workflow, you need to first have an account at [GitHub](http://www.github.com/) and then create an open repository for your book.
GitHub is built around the distributed version control system [git](http://git-scm.com/), for which a variety of [graphical user interfaces](http://git-scm.com/downloads/guis) exist - see, e.g., of [here](http://git-scm.com/downloads/guis).
If you have a Debian-based Linux system, you can install the basic `git` client with command line interface as follows: `sudo apt-get install git`.
You can use either this client or such a GUI to work with your repository.

Before you create the repository and interact with it, I suggest that you have a bare minimum book ready locally.

First, create a repository on `GitHub`, maybe with a `README.md` file.
You should choose a license for your project, maybe a [creative commons](http://creativecommons.org/) one, if you want.

You should now put a file named "book.md" into the root folder of your repository, it could just contain some random text for now, the real book comes later.

 
## 5. Related Projects and Components

**[This package is now obsolete and no longer maintained. Please check `thomasWeise/bookbuilderpy` for a new and improved version.](https://github.com/thomasWeise/bookbuilderpy)**

### 5.1. Own Contributed Projects and Components

The following components have been contributed by us to provide this tool chain.
They are all open source and available on GitHub.

- The `R` package [bookbuildeR](http://github.com/thomasWeise/bookbuildeR) providing the commands wrapping around pandoc and extending Markdown to automatically build electronic books.
- "An Introduction to Optimization Algorithms," is a book we are currently working on. It is work in progress, but can serve as an example on how to use this tool chain.
  + [aitoa](http://github.com/thomasWeise/aitoa) the repository for the sources of the book,
  + [aitoa-code](http://github.com/thomasWeise/aitoa-code) the repository for the sources of the example programs used in and referenced by the book,
  + [aitoa.pdf](http://thomasweise.github.io/aitoa/aitoa.pdf) the pdf version of the book, generated automatically by this tool chain,
  + [aitoa.html](http://thomasweise.github.io/aitoa/aitoa.html) the html version of the book, generated automatically by this tool chain,
  + [aitoa.epub](http://thomasweise.github.io/aitoa/aitoa.epub) the epub version of the book, and
  + [aitoa.awz3](http://thomasweise.github.io/aitoa/aitoa.awz3) the awz3 version of the book. generated automatically by this tool chain (the epub format is not yet working well).
- A hierarchy of docker containers forms the infrastructure for the automated builds:
  + [docker-bookbuilder](http://github.com/thomasWeise/docker-bookbuilder) is the docker container that can be used to compile an electronic book based on our tool chain. [Here](http://github.com/thomasWeise/docker-bookbuilder) you can find it on GitHub and [here](http://hub.docker.com/r/thomasweise/docker-bookbuilder/) on docker hub.
  + [docker-pandoc-r](http://github.com/thomasWeise/docker-pandoc-r) is a docker container with a complete pandoc, TeX Live, and R installation. It forms the basis for [docker-bookbuilder](http://github.com/thomasWeise/docker-bookbuilder) and its sources are [here](http://github.com/thomasWeise/docker-pandoc-r) while it is located [here](http://hub.docker.com/r/thomasweise/docker-pandoc-r/) on docker hub.
  + [docker-pandoc-calibre](http://github.com/thomasWeise/docker-pandoc-calibre) is the container which is the basis for [docker-pandoc-r](http://github.com/thomasWeise/docker-pandoc-r). It holds a complete installation of pandoc, [calibre](http://calibre-ebook.com), which is used to convert EPUB3 to AZW3, and TeX Live and its sources are [here](http://github.com/thomasWeise/docker-pandoc-calibre) while it is located [here](http://hub.docker.com/r/thomasweise/docker-pandoc-calibre/).
  + [docker-pandoc](http://github.com/thomasWeise/docker-pandoc) is the container which is the basis for [docker-pandoc-calibre](http://github.com/thomasWeise/docker-pandoc-calibre). It holds a complete installation of pandoc and TeX Live and its sources are [here](http://github.com/thomasWeise/docker-pandoc) while it is located [here](http://hub.docker.com/r/thomasweise/docker-pandoc/).
  + [docker-texlive-thin](http://github.com/thomasWeise/docker-texlive-thin) is the container which is the basis for [docker-pandoc](http://github.com/thomasWeise/docker-pandoc). It holds a complete installation of TeX Live and its sources are [here](http://github.com/thomasWeise/docker-texlive-thin) while it is located [here](http://hub.docker.com/r/thomasweise/docker-texlive-thin/).
- The `R` package [utilizeR](http://github.com/thomasWeise/utilizeR) holds some utility methods used by [bookbuildeR](http://github.com/thomasWeise/bookbuildeR).

### 5.2. Related Projects and Components Used

- [pandoc](http://pandoc.org/), with which we convert markdown to HTML, pdf, and epub, along with several `pandoc` filters, namely
   + [`pandoc-citeproc`](http://github.com/jgm/pandoc-citeproc),
   + [`pandoc-crossref`](http://github.com/lierdakil/pandoc-crossref),
   + [`latex-formulae-pandoc`](http://github.com/liamoc/latex-formulae), and
   + [`pandoc-citeproc-preamble`](http://github.com/spwhitton/pandoc-citeproc-preamble)
and the two `pandoc` templates
   + [Wandmalfarbe/pandoc-latex-template](http://github.com/Wandmalfarbe/pandoc-latex-template/), an excellent `pandoc` template for LaTeX by [Pascal Wagler](http://github.com/Wandmalfarbe)
   + the [GitHub Pandoc HTML5 template](http://github.com/tajmone/pandoc-goodies/tree/master/templates/html5/github) by [Tristano Ajmone](http://github.com/tajmone)
- [TeX Live](http://tug.org/texlive/), a [LaTeX](http://en.wikipedia.org/wiki/LaTeX) installation used by pandoc for generating the pdf output
- [`R`](http://www.r-project.org/), the programming language in which this package is written
- [docker](https://en.wikipedia.org/wiki/Docker_(software)), used to create containers in which all required software is pre-installed,
- [`cabal`](http://www.haskell.org/cabal/), the compilation and package management system via which pandoc is obtained,
- [`calibre`](http://calibre-ebook.com), which allows us to convert epub to awz3 files
- [`imagemagick`](http://www.imagemagick.org/) used by `pandoc` for image conversion
- [`ghostscript`](http://ghostscript.com/), used by our script to include all fonts into a pdf
- [`poppler-utils`](http://poppler.freedesktop.org/), used by our script for checking whether the pdfs are OK.

## 6. License

The copyright holder of this package is Prof. Dr. Thomas Weise (see Contact).
The package is licensed under the GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007.
This package also contains third-party components which are under the following licenses;

### 6.1. [Wandmalfarbe/pandoc-latex-template](http://github.com/Wandmalfarbe/pandoc-latex-template)

We include the pandoc LaTeX template from [Wandmalfarbe/pandoc-latex-template](http://github.com/Wandmalfarbe/pandoc-latex-template) by Pascal Wagler and John MacFarlane, which is under the [BSD 3 license](http://github.com/Wandmalfarbe/pandoc-latex-template/blob/master/LICENSE). For this, the following terms hold:

    % Copyright (c) 2018, Pascal Wagler;  
    % Copyright (c) 2014--2018, John MacFarlane
    % 
    % All rights reserved.
    % 
    % Redistribution and use in source and binary forms, with or without 
    % modification, are permitted provided that the following conditions 
    % are met:
    % 
    % - Redistributions of source code must retain the above copyright 
    % notice, this list of conditions and the following disclaimer.
    % 
    % - Redistributions in binary form must reproduce the above copyright 
    % notice, this list of conditions and the following disclaimer in the 
    % documentation and/or other materials provided with the distribution.
    % 
    % - Neither the name of John MacFarlane nor the names of other 
    % contributors may be used to endorse or promote products derived 
    % from this software without specific prior written permission.
    % 
    % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
    % "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    % LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    % FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    % COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    % INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    % BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    % LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    % CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    % LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    % ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    % POSSIBILITY OF SUCH DAMAGE.
    %%
    
    %%
    % For usage information and examples visit the GitHub page of this template:
    % http://github.com/Wandmalfarbe/pandoc-latex-template
    %%
    
### 6.2 [tajmone/pandoc-goodies HTML Template](http://github.com/tajmone/pandoc-goodies)

We include the pandoc HTML-5 template from [tajmone/pandoc-goodies](http://github.com/tajmone/pandoc-goodies) by Tristano Ajmone, Sindre Sorhus, and GitHub Inc., which is under the [MIT license](http://raw.githubusercontent.com/tajmone/pandoc-goodies/master/templates/html5/github/LICENSE). For this, the following terms hold:

    MIT License
    
    Copyright (c) Tristano Ajmone, 2017 (github.com/tajmone/pandoc-goodies)
    Copyright (c) Sindre Sorhus <sindresorhus@gmail.com> (sindresorhus.com)
    Copyright (c) 2017 GitHub Inc.
    
    "GitHub Pandoc HTML5 Template" is Copyright (c) Tristano Ajmone, 2017, released
    under the MIT License (MIT); it contains readaptations of substantial portions
    of the following third party softwares:
    
    (1) "GitHub Markdown CSS", Copyright (c) Sindre Sorhus, MIT License (MIT).
    (2) "Primer CSS", Copyright (c) 2016 GitHub Inc., MIT License (MIT).
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.


## 7. Contact

If you have any questions or suggestions, please contact
[Prof. Dr. Thomas Weise](http://iao.hfuu.edu.cn/team/director) of the
[Institute of Applied Optimization](http://iao.hfuu.edu.cn/) at
[Hefei University](http://www.hfuu.edu.cn) in
Hefei, Anhui, China via
email to [tweise@hfuu.edu.cn](mailto:tweise@hfuu.edu.cn) and [tweise@gmx.de](mailto:tweise@gmx.de).

### 8. Links

- **[thomasWeise/bookbuilderpy](https://github.com/thomasWeise/bookbuilderpy)**
- [personal post](https://www.linkedin.com/feed/update/urn:li:activity:6540439180223307776)
- [personal article](https://www.linkedin.com/pulse/writing-books-github-have-travis-ci-automatically-compile-weise/)
- [post on institute website](http://iao.hfuu.edu.cn/157)
