package main

import (
	"flag"
	"log"

	"install/internal/install"
)

var (
	path = flag.String("path", ".", "base path to files")
)

func main() {
	flag.Parse()

	_install := install.New(
		*path,
	)
	if err := _install.Run(); err != nil {
		log.Fatalln(err)
	}
}
