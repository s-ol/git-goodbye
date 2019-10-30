`git goodbye` is a tool for saying goodbye to GitHub.

It is a micro-tool for generating READMEs that link to the new location of a project formerly
hosted on github, and then put that README on a default branch so that people find the notice.

Usage
-----

Choose whichever implementation you feel like running and stick it in your `PATH` (or don't).
Make sure to swap out the bit that matches your new remote and links to it's public HTTP access.

Now you can visit your repos and say `$ git goodbye`.

`git goodbye` will create a README.md that points to your project's new location.
If you specify `--branch` it will create a branch called `goodbye` and commit the README there.
With `--all` it will also push the branch.
