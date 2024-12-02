
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{phsshinytestgolem}`

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Installation

You can install the development version of `{phsshinytestgolem}` like
so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Run

You can launch the application by running:

``` r
phsshinytestgolem::run_app()
```

## About

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2024-11-25 12:40:09 GMT"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ══ Documenting ═════════════════════════════════════════════════════════════════
#> ℹ Installed roxygen2 version (7.3.2) doesn't match required (7.1.1)
#> ✖ `check()` will not re-document this package
#> ── R CMD check results ─────────────────────── phsshinytestgolem 0.0.0.9000 ────
#> Duration: 1m 11.2s
#> 
#> ❯ checking DESCRIPTION meta-information ... WARNING
#>   Non-standard license specification:
#>     What license is it under?
#>   Standardizable: FALSE
#> 
#> 0 errors ✔ | 1 warning ✖ | 0 notes ✔
#> Error: R CMD check found WARNINGs
```

``` r
covr::package_coverage()
#> Error in loadNamespace(x): there is no package called 'covr'
```
