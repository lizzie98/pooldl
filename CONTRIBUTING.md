# Contributing

## Command Line Tools

Generate JSON dataclasses:
`dart run build_runner watch --delete-conflicting-outputs`.

Update the icon (`assets/icon.png`):
`dart run flutter_launcher_icons`.

## Deploy

Install build tool: `dart pub global activate fastforge`. Then follow these
instructions:
https://fastforge.dev/makers/appimage

Run `fastforge release --name local` to build.
