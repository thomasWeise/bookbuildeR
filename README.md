# An R Package for Building Books or Documents using `pandoc`

[<img alt="Travis CI Build Status" src="http://img.shields.io/travis/thomasWeise/bookbuildeR/master.svg" height="20"/>](http://travis-ci.org/thomasWeise/bookbuildeR/)

## 1. Introduction

This is an `R` package intended for building electronic books from [pandoc's markdown flavor](http://pandoc.org/MANUAL.html#pandocs-markdown) by using, well, [pandoc](http://pandoc.org/) and [`R`](http://www.r-project.org/).
You can see it in action in our project [An Introduction to Optimization Algorithms](https://github.com/thomasWeise/aitoa), which is written in Markdown and automatically converted to [pdf](http://thomasweise.github.io/aitoa/aitoa.pdf), [html](http://thomasweise.github.io/aitoa/aitoa.html), 
[epub](http://thomasweise.github.io/aitoa/aitoa.epub), and [azw3](http://thomasweise.github.io/aitoa/aitoa.azw3) by using this package.
Our package aims at making it easier to dynamically write books and even publish them online by reducing most of the work to the invocation of a single command.
It therefore extends the standard tools provided by pandoc with a set of additional commands.

The package is the basis for our [docker](https://en.wikipedia.org/wiki/Docker_(software)) container "[thomasWeise/docker-bookbuilder](http://hub.docker.com/r/thomasweise/docker-bookbuilder/)".
The sources of this container are provided in the [GitHub](http://www.github.com) repository [thomasWeise/docker-bookbuilder](https://github.com/thomasWeise/docker-bookbuilder).
The container includes all necessary software components needed to run and build electronic books by using the scripts here, such as complete installations of [pandoc](http://pandoc.org/), [`R`](http://www.r-project.org/), and [TeX Live](http://tug.org/texlive/).

It is suitable for the integration into a CI environment, which can be used to completely automate the development of electronic books.

## 2. Extented Markdown

In order to allow for an easy way to work on books, especially for the fields of computer science and mathematics, several additional commands are provided.

### 2.1. Added Functionality

The core facility is the hierarchical inclusion and referencing of files, which allows for a more 'decentralized' working method, where the global book structure results from the locally included files and does not need to be known in the root document.
Thus, you can more easily modify the book structure by including files and nesting folders in your current working position without going back and forth to the main document.
These allow, for instance, to define and reference proof/definition/...-like environments that are converted to markdown.

Furthermore, it allows dynamically linking to a "source code repository".
Let's say you write a book about Java.
You would then probably want to have a lot of programming examples.
You can keep these in a separate source code repository, e.g., on GitHub.
This repository could also feature build and test scripts, etc., and could be a fully functional application or library.
The book's sources then can reside in a different repository and are thus separate from the programming code examples.
You can specify this repository as `codeRepo` in the book's YAML metadata.
The source code repository is automatically cloned during the book building process and all of its files are accessible.
You even have access to the commit id of the source code repository, so that you can print it in the book and thus allow the readers to go back to exactly the right version of the code even if you further improve the code in the future.

Since the package provides scripts to be used from the command line, it is designed to hard-fail on any error.

This package, together with a complete installation of [pandoc](http://pandoc.org/), [`R`](http://www.r-project.org/), [TeX Live](http://tug.org/texlive/), and all needed tools is available as a Docker image at http://hub.docker.com/r/thomasweise/docker-bookbuilder.
Thus, you can use it as tool for all your book-writing purposes.
You may even integrate it with [Travis CI](http;//travis-ci.org) and [GitHub](http://www.github.com), as described [here](http://iao.hfuu.edu.cn/157) to achieve a fully-atumated book writing and publishing tool chain.

### 2.2. Provided Commands

You can now use the following commands in your markdown:

- `\relativel.path{path}` is a path expression relative to the currently processed file's directory which will be resolved to be relative to the root folder of the document. This is intended to allow you to place chapters and sections in a hierarchical folder structure and their contained images in sub-folders, while referencing them relatively from the current path.
- `\relative.input{file}` is a command similar to `\relativel.path`. If this command is used, it must be the only text/command on the current line. It will resolve the path to `file` relative to the directory of the current file and *recursively* include that file. This is another tool to allow for building documents structured in chapters, sections, and folders without needed to specify the overall, global structure anywhere and instead specify the inclusion of files where they are actually needed. 
- `\meta.time` prints the current date and time.
- `\meta.date` prints the current date.
- `\meta.year` prints the current year.
- `\text.block{type}{label}{body}` creates a text block by putting the title-cased `type` together with the block number in front in double-emphasis (the blocks of each type are numbered separately) and then the `body`. `\text.block{definition}{d1}{blabla} \text.block{definition}{d2}{blubblub}` will render to `**Defininition&nbsp;1:**&nbsp;blabla**Defininition&nbsp;2:**&nbsp;blubblub`. Blocks can be referenced in the text via their `label` in `\text.ref{label}`. The goal is to achieve theorem-style environments, but on top of markdown.
- `\text.ref{label}` references a text block with the same label (see command above). In the example given above, `\text.ref{d2}` would render to `Definition&nbsp;2`.
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

With out package and associated docker container, you can conveniently build your electronic book on your computer with a single command.
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

Since the book's sources are available as GitHub repository, our readers can file issues to the repository, with change suggestions, discovered typos, or with questions to add clarification.
They may even file pull requests with content to include.

### 4.1. The Repository

In order to use our workflow, you need to first have an account at [GitHub](http://www.github.com/) and then create an open repository for your book.
GitHub is built around the distributed version control system [git](http://git-scm.com/), for which a variety of [graphical user interfaces](http://git-scm.com/downloads/guis) exist - see, e.g., of [here](http://git-scm.com/downloads/guis).
If you have a Debian-based Linux system, you can install the basic `git` client with command line interface as follows: `sudo apt-get install git`.
You can use either this client or such a GUI to work with your repository.

We suggest that in your main branch of the repository, you put a folder `book` where all the raw sources and graphics for your book go.
In the repository root folder, you can then leave the non-book-related things, like `README.md`, `.travis.yml`, and `LICENSE.md`. At this step, you should choose a license for your project, maybe a [creative commons](http://creativecommons.org/) one, if you want.

You should now put a file named "book.md" into the "book" folder of your repository, it could just contain some random text for now, the real book comes later.

### 4.2. The `gh-pages` Branch

Since we want the book to be automatically be built and published to the internet, we should have a `gh-pages` branch in our repository as well.
I assume that you have a Unix/Linux system with `git` installed.
In that case, you can do this as follows (based on [here](http://stackoverflow.com/questions/13969050) and [here](http://stackoverflow.com/questions/34100048)), by replacing `YOUR_USER_NAME` with your user name and `YOUR_REPOSITORY` with your repository name:

    git clone --depth=50 --branch=master https://github.com/YOUR_USER_NAME/YOUR_REPOSITORY.git YOUR_USER_NAME/YOUR_REPOSITORY
    cd YOUR_USER_NAME/YOUR_REPOSITORY
    git checkout --orphan gh-pages
    ls -la |awk '{print $9}' |grep -v git |xargs -I _ rm -rf ./_ 
    git rm -rf .
    git commit --allow-empty -m "root commit"
    git push origin gh-pages

You can now safely delete the folder `YOUR_USER_NAME/YOUR_REPOSITORY` that was created during this procedure.
If you go to the settings page of your repository, it should now display something like "` Your site is published at https://YOUR_USER_NAME.github.io/YOUR_REPOSITORY/`" under point "GitHub Pages".
This is where your book will later go.

### 4.3. Personal Access Token

Later, we will use [Travis CI](http://travis-ci.org/) to automatically build your book and to automatically deploy it the GitHub pages branch of your repository.
For the latter, Travis will need a so-called personal access token, as described [here](http://docs.travis-ci.com/user/deployment/pages/).
You need to create such a token following the steps detailed [here](http://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/).
Basically, you go to your personal settings page for your GitHub account, click "Developer Settings" and then "Personal Access Tokens".
You click "Generate new token" and confirm your password.
Then you need to choose `public_repo` and click "Generate token".
Make sure you store the token as text somewhere safe, we need this token text later on.

### 4.4. Travis CI: Building and Deployment

With that in place, we can now setup [Travis CI](http://travis-ci.org/) for automated building and deployment.
You can get a Travis account easily and even sign in with GitHub.
When you sign into Travis, it should show you a list with your public GitHub repositories.
You need to should enable your book repository for automated build.

Click on the now-activated repository in Travis and click "More Settings".
Scroll down to "Environment Variables" and then add a variable named "GITHUB_TOKEN".
As value, copy the text of the personal access token that we have created in the previous step.

### 4.5. `.travis.yml`

Now we need to finally tell Travis how to build our book, and this can be done by placing a file called `.travis.yml` into the root folder of your GitHub repository.
This file should have the following contents, where `YOUR_BOOK_OUTPUT_BASENAME` should be replaced with the base name of the files to be generated (e.g., "myBook" will result in "myBook.pdf" and "myBook.epub" later):

    sudo: required
    
    language: generic
    
    services:
      - docker
    
    script:
    - |
      baseDir="$(pwd)" &amp;&amp;\
      inputDir="${baseDir}/book" &amp;&amp;\
      outputDir="${baseDir}/output" &amp;&amp;\
      mkdir -p "${outputDir}" &amp;&amp;\
      docker run -v "${inputDir}/":/input/ \
                 -v "${outputDir}/":/output/ \
                 -e TRAVIS_COMMIT=$TRAVIS_COMMIT \
                 -e TRAVIS_REPO_SLUG=$TRAVIS_REPO_SLUG \
                 -t -i thomasweise/docker-bookbuilder book.md YOUR_BOOK_OUTPUT_BASENAME &amp;&amp;\
      cd "${outputDir}"
    
    deploy:
      provider: pages
      skip-cleanup: true
      github-token: $GITHUB_TOKEN
      keep-history: false
      on:
        branch: master
      target-branch: gh-pages
      local-dir: output


After adding this file, commit the changes and push the commit to the repository.
Shortly thereafter, a new Travis build should start.
If it goes well, it will produce three files, namely "`http://YOUR_USER_NAME.github.io/YOUR_REPOSITORY/YOUR_BOOK_OUTPUT_BASENAME.pdf`", "`http://YOUR_USER_NAME.github.io/YOUR_REPOSITORY/YOUR_BOOK_OUTPUT_BASENAME.html`", "`http://YOUR_USER_NAME.github.io/YOUR_REPOSITORY/YOUR_BOOK_OUTPUT_BASENAME.epub`", and "`http://YOUR_USER_NAME.github.io/YOUR_REPOSITORY/YOUR_BOOK_OUTPUT_BASENAME.azw3`", as well as
"`http://YOUR_USER_NAME.github.io/YOUR_REPOSITORY/index.html`" (where `YOUR_USER_NAME` will be the lower-case version of your user name). You can link them from the README.md file that you probably have in your project's root folder.

### 4.6. Interaction with Source Code Repository

As discussed above, there are several commands for inte racting with a source code repository.
The idea is as follows: You can write your book online, by keeping the *book sources* in a GitHub repository.
Whenever you make a commit to the repository, the book's pdf and epub files will be rebuilt, so the newest book version is always online.

If you write a book related to, e.g., computer science, you may have lots of example codes in some programming language in your book.
I think that it is often nice to not just have examples on some "meta-level," but to have real, executable programs as examples.
Of course, you may choose to print snippets of them in the book only, but they should be available "in full" somewhere.

For this purpose, the *code repository* exists.
It can be a second GitHub repository, where you keep your programming examples.
This second repository may have an independent build cycle, e.g., be a [Maven](http://maven.apache.org/) build with unit tests executed on Travis CI, as well.
You can specify the URL of this repository as `codeRepo` in the YAML meta data of your book and then use commands such as `\repo.code{path}{lines}{tags}`, `\repo.listing{label}{caption}{language}{path}{lines}{tags}`, `\repo.name`, and `\repo.commit` to directly access files in the meta information of this repository.

If you do that, you may choose to follow the approach given in [plume-lib/trigger-travis](http://github.com/plume-lib/trigger-travis) to automatically trigger a build of your book when a commit to your source code repository happens.
This is a good idea, because this way your book will stay up-to-date when you, e.g., fix bugs in your example codes or refactor them.
Each time your example code repository passes the automatic build process, your book's build process will be triggered and the book will be compiled and published anew.

This concept means that you can edit your source code examples completely independently from the book.
You could even write a book about an application you develop on GitHub and cite its sources wherever you want.
By using the `trigger-travis` approach, you will get a new version of the book whenever you change the book *and* whenever you change the source code.

### 4.7. Infrastructure

While we have already discussed the interplay of GitHub and Travis CI to get your book compiled, we have omitted one more element of our infrastructure: [Docker](http://www.docker.com).
Docker allows us to build something like very light-weight virtual machines (I know, they are not strictly virtual machines).
For this purpose, we can build images, which are basically states of a file system.
Our Travis builds load such an image, namely [thomasweise/docker-bookbuilder](http://hub.docker.com/r/thomasweise/docker-bookbuilder/), which provides my [bookbuildeR](http://github.com/thomasWeise/bookbuildeR) `R` package on top of an `R` installation ([thomasweise/docker-pandoc-r](http://hub.docker.com/r/thomasweise/docker-pandoc-r/)) on top of a Pandoc installation ([thomasweise/docker-pandoc](http://hub.docker.com/r/thomasweise/docker-pandoc/)) on top of a TeX Live installation ([thomasweise/docker-texlive-full](http://hub.docker.com/r/thomasweise/docker-texlive-full/)).
Of course, you could also use any of these containers locally or extend them in any way you want, in order to use different tools or book building procedures.
 
## 5. Related Projects and Components

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
  + [docker-texlive-full](http://github.com/thomasWeise/docker-texlive-full) is the container which is the basis for [docker-pandoc](http://github.com/thomasWeise/docker-pandoc). It holds a complete installation of TeX Live and its sources are [here](http://github.com/thomasWeise/docker-texlive-full) while it is located [here](http://hub.docker.com/r/thomasweise/docker-texlive-full/).
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
