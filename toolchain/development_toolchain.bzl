def create(scala_toolchain):
  scala_toolchain(
      name = "main-toolchain",
      dependency_mode = "direct",
      scalacopts = [
                  "-encoding",
                  "UTF-8",
                  "-feature",
                  "-unchecked",
                  #"-Xfatal-warnings",
                  "-deprecation",
                  "-language:existentials",
                  "-language:higherKinds",
                  "-language:implicitConversions",
                  #"-Ywarn-dead-code",
                  #"-Ywarn-numeric-widen",
                  #"-Ywarn-value-discard",
                  #"-Xlint:-unused,_",
                  #"-Ywarn-unused:imports",
                  "-Yrangepos",
              ],
      strict_deps_mode = "warn",
      unused_dependency_checker_mode = "warn",
      visibility = ["//visibility:public"],
  )

  toolchain(
      name = "main-scala_toolchain",
      toolchain = "main-toolchain",
      toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
      visibility = ["//visibility:public"],
  )
