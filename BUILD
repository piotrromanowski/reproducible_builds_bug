load("@io_bazel_rules_docker//container:container.bzl", "container_image")
load("@io_bazel_rules_go//go:def.bzl", "go_binary")
load("@rules_proto//proto:defs.bzl", "proto_library")
load("@io_bazel_rules_go//proto:def.bzl", "go_proto_library")

load(":rule.bzl", "upload_image")

proto_library(
    name = "foo_proto",
    srcs = ["foo.proto"],
)

go_proto_library(
    name = "foo_go_proto",
    importpath = "github.com/bazelbuild/rules_go/tests/core/go_proto_library/foo",
    proto = ":foo_proto",
)

go_binary(
    name = "runner",
    srcs = ["main.go"],
    deps = [":foo_go_proto"],
)

go_binary(
    name = "some_binary",
    srcs = ["main.go"],
    deps = [":foo_go_proto"],
)

container_image(
    name = "go_image",
    base = "@go_image_base//image",
    files = [":some_binary"],
    cmd = ["/some_binary"]
)

upload_image(
    name = "go_image_upload",
    images = [
      ":go_image",
    ],
)
