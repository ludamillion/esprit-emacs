#!/bin/bash
emacs --quick --batch --load=ert \
      --load=test/esprit-line-test.el \
      --load=test/esprit-line-segment-vc-test.el \
      --funcall=ert-run-tests-batch-and-exit
