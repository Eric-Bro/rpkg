##What's app?
The `rpkg` is a little command-line utility which allows you to create  Mac OS X Installation packages for some .kexts files (with all needen scripts, kernel-cache-working and so on).
In fact, this app has been created as a part of Rox project, but it can be used separately as well.

## What is rpkg based on?
The utulity uses the `packworks` framework for creating package (.pkg) files:  generates a .pmdoc and uses Apple's `PackageMaker` for building a package from this doc.
At this moment there no documentation about the framework, but I'll write it as soon as the app comes from a development version to alpha.

## What're included?
1. `packworks` Framework;
2. `packworks` Framefork's Unit tests (using `GHUnit`);
3. `rpkg` utility;
4. a `packme` folder with all sources of framework;

##What if I have some Qs?
Mail me: eric.broska@me.com