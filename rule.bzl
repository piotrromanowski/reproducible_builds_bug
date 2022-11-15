load("@io_bazel_rules_docker//container:providers.bzl", "ImageInfo")


def _upload_image_impl(ctx):
  image_parts = ctx.attr.images[0][ImageInfo].container_parts

  output = ctx.outputs.executable
  cmd = ["#!/bin/sh -e"] + \
        ['echo "uploading image ..."'] + \
        ["touch %s" % ctx.outputs.repo.path] + \
        ['cat %s > %s' % (image_parts["config_digest"].path, ctx.outputs.repo.path)]

  layers = []
  for shasum in image_parts["blobsum"]:
    layers.append('echo "\n" >> %s' % ctx.outputs.repo.path)
    layers.append('cat %s >> %s' % (shasum.path, ctx.outputs.repo.path))

  args = ctx.actions.args()
  args.add("--out")
  args.add(ctx.outputs.f.path)
  ctx.actions.run(
    executable = ctx.executable.runner,
    outputs = [ctx.outputs.f],
    arguments = [args],
    inputs = [image_parts["config_digest"]] + image_parts["blobsum"],
  )

  cmd = cmd + layers
  ctx.actions.run_shell(
      inputs = [image_parts["config_digest"]] + image_parts["blobsum"],
      command = "\n".join(cmd),
      outputs = [ctx.outputs.repo],
  )

  cmd = ["#!/bin/sh -e"] + \
        ['echo "uploading image ..."']
  output = ctx.outputs.executable
  ctx.actions.write(
      content = "\n".join(cmd),
      output = output,
      is_executable = True,
  )

  #runfiles = ctx.runfiles(
  #    files = artifact_files,
  #    transitive_files = transitive_files,
  #)
  return DefaultInfo(
      files = depset([ctx.outputs.repo]),
      #runfiles = runfiles,
  )

upload_image = rule(
  _upload_image_impl,
  executable = True,
  attrs = {
    "images": attr.label_list(
        allow_files = True,
    ),
    "runner": attr.label(
      executable = True,
      cfg = "host",
      default = Label("//:runner"),
    ),
  },
  outputs = {
      "repo": "%{name}.json",
      "f": "%{name}.f",
  },
)
