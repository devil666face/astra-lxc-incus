package main

import (
	"flag"
	"log"

	"install/internal/install"
)

var (
	path       = flag.String("path", ".", "base path to files")
	disablemic = flag.Bool("nomic", false, "not disable mic control")
)

func main() {
	flag.Parse()

	_install := install.New(
		*path,
		*disablemic,
	)
	if err := _install.Run(); err != nil {
		log.Fatalln(err)
	}
}
