package main

import (
    "fmt"

    log "github.com/Sirupsen/logrus"

    "github.com/vasily-chertkov/repo-versioning/c"
)

func main() {
    fmt.Println("BEGIN A")
    fmt.Println(common.EXPORTED_VALUE)
    fmt.Println("END A")

    log.Infof("some useless info")
}

