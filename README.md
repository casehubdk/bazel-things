# Bazel things
## Dependencies
This is a wrapper for maven dependencies which just exposes dependencies in a composable manner.
### Usage
In your `WORKSPACE` or some dependency file import the rules via `http_archive`.
```starlark
http_archive(
    name = "scala_things",
    sha256 = "zipSha",
    strip_prefix = "bazel-things%s" % commit_sha,
    url = "https://github.com/valdemargr/bazel-things/archive/%s.zip" % commit_sha,
)

load("@scala_things//:dependencies/init.bzl", "bazel_things_dependencies")
bazel_things_dependencies()
```
Then dependencies can be declared anywhere, as an example let the following be in the file `//dependencies.bzl`.
```starlark
load("@scala_things//:dependencies/dependencies.bzl", "java_dependency", "scala_dependency", "scala_fullver_dependency", "make_scala_versions")

scala_versions = make_scala_versions(
    "2",
    "13",
    "6",
)

some_dependencies = [
  scala_dependency("org.typelevel", "cats-effect", "3.0.1"),
  scala_fullver_dependency("org.typelevel", "kind-projector", "0.11.3"),
  java_dependency("org.apache.poi", "poi", "4.1.2")
]
```
At some point the effectful installation must be invoked.
```starlark
load("@scala_things//:dependencies/dependencies.bzl", "install_dependencies", "to_string_version")
load("//:dependencies.bzl", "some_dependencies", "scala_versions")

install_dependencies(some_dependencies, scala_versions)
```
Note that if you have multiple projects, either declared in a monorepo or distributed, you can indeed pull the child repo's maven dependencies for building.
```starlark
git_repository(
   name = "scala_project_some_inhouse_project",
   ...
)

# load local dependency list
load("//:dependencies.bzl", "some_dependencies", "scala_versions")

# load some_inhouse_project dependency list
load("@scala_project_some_inhouse_project//:dependencies.bzl", some_inhouse_project_deps = "some_dependencies")

install_dependencies(some_dependencies + some_inhouse_project_deps, scala_versions)
```
The `to_string_version` can also be used as parameter to the official scala bazel rules to configure the compiler version.
```starlark
load("@scala_things//:dependencies/dependencies.bzl", "install_dependencies", "to_string_version")
load("//:dependencies.bzl", "some_dependencies", "scala_versions")
...
# scala
rules_scala_version = "b85d1225d0ddc9c376963eb0be86d9d546f25a4a"  # update this as needed

http_archive(
    name = "io_bazel_rules_scala",
    sha256 = "f6fa4897545e8a93781ad8936d5a59e90e2102918e8997a9dab3dc5c5ce2e09e",
    strip_prefix = "rules_scala-%s" % rules_scala_version,
    type = "zip",
    url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip" % rules_scala_version,
)

load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")
load("//:dependencies.bzl", "scala_versions")

scala_config(to_string_version(scala_versions))
```
## Metals integration
I use metals with vim.
Bazel cannot generate bloop generation as of now, so I have also written a python script which can emit bloop configuration if `rules_jvm_external` are used.
Say the directory with your sources is named `src`, the script should be invoked as follows.
```bash
mkdir .bloop
bazel-things/metals-config/write_bloop_config.py --name src > .bloop/src.json
```
