// RUN: not --crash %target-swift-ide-test -code-completion -code-completion-token=A -source-filename=%s
enum b:a{var f={static#^A^#