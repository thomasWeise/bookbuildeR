# An R Package for Building Books or Documents using `pandoc`

[<img alt="Travis CI Build Status" src="https://img.shields.io/travis/thomasWeise/bookbuildeR/master.svg" height="20"/>](https://travis-ci.org/thomasWeise/bookbuildeR/)

# Introduction

This is an `R` package intended for building electronic books from [pandoc's markdown flavor](http://pandoc.org/MANUAL.html#pandocs-markdown) by using, well, [pandoc](http://pandoc.org/) and [`R`](http://www.r-project.org/).
Since the package provides scripts to be used from the command line, it is designed to hard-fail on any error.

# Provided Commands

You can now use the following commands in your markdown:

- `\relativel.path{path}` is a path expression relative to the currently processed file's directory which will be resolved to be relative to the root folder of the document. This is intended to allow you to place chapters and sections in a hierarchical folder structure and their contained images in sub-folders, while referencing them relatively from the current path.
- `\relativel.input{file}` is a command similar to `\relativel.path`. If this command is used, it must be the only text/command on the current line. It will resolve the path to `file` relative to the directory of the current file and *recursively* include that file. This is another tool to allow for building documents structured in chapters, sections, and folders without needed to specify the overall, global structure anywhere and instead specify the inclusion of files where they are actually needed. 
- `\meta.time` prints the current date and time.
- `\meta.date` prints the current date.
- `\text.block{type}{label}{body}` creates a text block by putting the title-cased `type` together with the block number in front in double-emphasis (the blocks of each type are numbered separately) and then the `body`. `\text.block{definition}{d1}{blabla} \text.block{definition}{d2}{blubblub}` will render to `**Defininition&nbsp;1:**&nbsp;blabla**Defininition&nbsp;2:**&nbsp;blubblub` Blocks can be referenced in the text via their `label` in `\text.ref{label}`. The goal is to achieve theorem-style environments, but on top of markdown.
- `\text.ref{label}` references a text block with the same label (see command above). In the example given above, `\text.ref{d2}` would render to `Definition&nbsp;2`.
- `\relative.code{path}{lines}{tags}` inserts the content of a file identified by the path `path` which is interpreted relative to the current file. Different from `\relative.input`, this is intented for reading code and this command therefore provides two content selection mechanisms: `lines` allows you to specify lines to insert, e.g., `20:22,1:4,7` would insert the lines 1 to 4, 7, and 20 to 22 (in that order). `tags` allows you to specify a comma-separated list of tags. A tag is a string, say "example1", and then everything between a line containing "start example1" and a line "end example1" is included. The idea is that you would put these start and end markers into line comments (in R starting with "#", in Java with "//"). If you specify multiple tags, the corresponding bodies are merged. If you specify both \code{lines} and \code{tags}, we first apply the line selection and then the tag selection only on the selected lines.
- `\repo.code{path}{lines}{tags}` if and only if you specify a `codeRepo` url in your YAML metadata of the book, you can use this command, which allows you to download and access a repository with source code. This way, you can have a book project in one repository and a repository with separate, working, executable examples somewhere else. This second repository, identified by `codeRepo`, will be cloned once. Then, the path `path` is interpreted relative to the root path of the repository and you can include code from that repository in the same fashion as with `\relative.code`.

The following commands will only work within Travis.CI builds and (intentionally) crash otherwise:

- `\meta.repository` get the repository in format `owner/repository`
- `\meta.commit` get the commit id

## License

The copyright holder of this package is Prof. Dr. Thomas Weise (see Contact).
The package is licensed under the  GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007.
    
## Contact

If you have any questions or suggestions, please contact
[Prof. Dr. Thomas Weise](http://iao.hfuu.edu.cn/team/director) of the
[Institute of Applied Optimization](http://iao.hfuu.edu.cn/) at
[Hefei University](http://www.hfuu.edu.cn) in
Hefei, Anhui, China via
email to [tweise@hfuu.edu.cn](mailto:tweise@hfuu.edu.cn).
