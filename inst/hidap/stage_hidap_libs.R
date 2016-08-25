library(readr)
library(git2r)
library(log4r)

# setup ref to online repo
drat::addRepo("c5sire")
drat_dir = "D:/packages/drat/"

# stage_hidap_libs

# get a temp dir
setwd("d:/packages/drat/inst/hidap/")
stage_dir = file.path( "D:/temp", "stage")
if(!dir.exists(stage_dir)) dir.create(stage_dir)

logger <- create.logger(logfile = 'debugging_hidap2drat.log', level = "WARN")

# get list of hidap packages

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
    info(logger, paste0("Added package: ", pkgs[i]))
  }
}
pkg_new_msg = paste0(new_pkg, " new package(s) added.")
cat(pkg_new_msg)
info(logger, pkg_new_msg)

# TODO simple method to check if repository is ahead

# git status of package
# old_wd = getwd()
# pkg_status = logical(n)
#
# for(i in 1:n) {
#   try({
#     new_wd = file.path(stage_dir, pkgn[i])
#     setwd(new_wd)
#     status = capture.output( git2r::status())
#     # check if change to prior version
#     pkg_status[i] <- status == "working directory clean"
#   })
# }
#
# # remove unchanged packages from list
# pkg_chg = pkgs[!pkg_status]
# if(length(pkg_chg) == 0) stop("No packages changed.")


# if list has at least one updated package:

# git checkout of package


for(i in 1:n) {
  try({
    new_wd = file.path(stage_dir, pkgn[i])
    setwd(new_wd)
    # create src package
    devtools::build()
    devtools::build(binary = TRUE)
  })
}

setwd(stage_dir)
pkg_bin = list.files(pattern = ".zip")
sapply(pkg_bin, drat::insertPackage, repodir = drat_dir)

pkg_src = list.files(pattern = ".tar.gz")
sapply(pkg_src, drat::insertPackage, repodir = drat_dir)

# after finalizing all updates:
setwd(drat_dir)

# git commit
#repo = "https://github.com/c5sire/drat.git"
repo = git2r::init(drat_dir)
git2r::commit(repo, "update packages by script")

# git push

# log result

