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
