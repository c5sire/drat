library(readr)
library(git2r)
#library(log4r)

# setup ref to online repo
drat::addRepo("c5sire")

# TODO auto switch on Windows and Mac to correct dirs
# drat_dir = "D:/packages/drat/"
drat_dir = "/Users/reinhardsimon/Documents/projects/drat"
# get a temp dir
#setwd("d:/packages/drat/inst/hidap/")
setwd(file.path(drat_dir, "inst", "hidap" ))

#stage_dir = file.path( "D:/temp", "stage")
stage_dir = file.path( tempdir(), "stage")


unlink(stage_dir, recursive = TRUE, force = TRUE)
if(!dir.exists(stage_dir)) dir.create(stage_dir)

pkgs <- readr::read_lines("hidap_packages.txt")

x = as.character(unlist(sapply(pkgs, stringr::str_split,  "/")))
pkgn <- x[seq(2, length(x), 2)]
n = length(pkgn)
i = 1

new_pkg = 0
for(i in 1:n ){
  dp = file.path(stage_dir, pkgn[i])
  if(!dir.exists(dp)){
    # download
    url = paste0("https://github.com/", pkgs[i], ".git")
    git2r::clone(url, dp)
    new_pkg = new_pkg + 1
    #info(logger, paste0("Added package: ", pkgs[i]))
  }
}
pkg_new_msg = paste0(new_pkg, " new package(s) added.")
cat(pkg_new_msg)

# TODO simple method to check if repository is ahead

# git checkout of package
for(i in 1:n) {
  try({
    new_wd = file.path(stage_dir, pkgn[i])
    setwd(new_wd)
    devtools::build()
    devtools::build(binary = TRUE)
  })
}

setwd(stage_dir)
#pkg_bin = list.files(pattern = ".zip")
pkg_bin = list.files(pattern = ".tgz")
sapply(pkg_bin, drat::insertPackage, repodir = drat_dir)

pkg_src = list.files(pattern = ".tar.gz")
sapply(pkg_src, drat::insertPackage, repodir = drat_dir)

# after finalizing all updates:
setwd(drat_dir)
drat::archivePackages(drat_dir)

# Manuually from within drat package: branch gh-pages
# git commit

# git push origin gh-pages

