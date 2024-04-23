package main

import (
	"fmt"
	"os"

	"github.com/spf13/pflag"
)

func main() {
	flags := pflag.NewFlagSet(os.Args[0], pflag.ContinueOnError)
	args, err := ParseArgs(flags, os.Args)
	if err != nil {
		// argument parsing failure
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(2)
	}
	if args.Help {
		flags.PrintDefaults()
		os.Exit(2)
	}
}
