# asdf-maven

[Maven](https://en.wikipedia.org/wiki/Apache_Maven)
plugin for the [asdf](https://github.com/asdf-vm/asdf) version manager.

## Install

After installing [asdf](https://github.com/asdf-vm/asdf),
you can add this plugin like this:

```bash
asdf plugin-add maven
```

and install new versions like this:

```bash
asdf install maven 3.5.4
```

and switch versions like this:

```bash
asdf global maven 3.5.4
```

## Mirror

Set `ASDF_MAVEN_MIRROR` to a mirror of `https://archive.apache.org/dist/maven` (no trailing
slash needed) to keep apache.org out of the loop entirely:

```bash
export ASDF_MAVEN_MIRROR=https://nexus.example.com/repository/maven-mirror
```

`install` downloads from `$ASDF_MAVEN_MIRROR/maven-<major>/<version>/binaries/`, and `list-all`
and `latest-stable` read the `maven-2/`, `maven-3/` and `maven-4/` directory listings from the same
mirror instead of `maven.apache.org`. If the mirror can't be listed, `list-all` fails rather than
falling back to apache.org. Snapshots aren't listed in mirror mode.

Without the variable, versions come from the Maven release history page and snapshot metadata, and
downloads come from `archive.apache.org`.

## Reading

Read the [asdf readme](https://github.com/asdf-vm/asdf)
for instructions on how to install and manage versions of any language.

If you have trouble with any expected features,
have any feature requests or want to contribute,
please [do an issue](https://github.com/skotchpine/asdf-maven/issues).

## Development

- asdf's [creating-plugins.md](https://github.com/asdf-vm/asdf/blob/master/docs/creating-plugins.md)
- [Bash Hackers Wiki](http://wiki.bash-hackers.org/)
