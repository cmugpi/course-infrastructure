# infra

Course infra for use with Autolab. This README contains documentation for
creating, testing, and maintaining your course's infrastructure.

You should fork this repo if you wish to use it as your own course's
infrastructure. The rest of the instructions are written assuming you have
already forked this repo.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Table of Contents

- [Install](#install)
- [Usage](#usage)
  - [General Notes](#general-notes)
  - [List the available commands](#list-the-available-commands)
  - [See a lab like a student does](#see-a-lab-like-a-student-does)
  - [Play around with the reference solution](#play-around-with-the-reference-solution)
  - [Install a lab to Autolab](#install-a-lab-to-autolab)
  - [Make the lab handout zipfile](#make-the-lab-handout-zipfile)
  - [Debug the autograder](#debug-the-autograder)
- [Testing & Linting](#testing-&-linting)
  - [Automated Linting](#automated-linting)
  - [Automated Testing](#automated-testing)
  - [Manual Testing](#manual-testing)
    - [Simulate a handin on Autolab](#simulate-a-handin-on-autolab)
    - [Manually run the autograder](#manually-run-the-autograder)
- [Lab Release Checklist](#lab-release-checklist)
- [Guide for Lab Authors](#guide-for-lab-authors)
  - [Lab Structure](#lab-structure)
  - [Important Files and Folders](#important-files-and-folders)
  - [Tips for Writing a Lab](#tips-for-writing-a-lab)
- [Contribute](#contribute)
  - [Git & Code Review](#git-&-code-review)
  - [Style & Naming Conventions](#style-&-naming-conventions)
  - [Autograder Output](#autograder-output)
- [Troubleshooting](#troubleshooting)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Install

There is minimal setup required before you can develop with these labs.

First, do a deep clone (because we're using submodules):

```
git clone --recursive https://github.com/cmugpi/labs
```

Next, install the [`bask`][bask] CLI, which is a simple task runner for Bash
that we use. This can be as simple as

```
brew install jez/formulae/bask
```


## Usage

This section contains tips for how to do things TAs frequently need to do. You
are **encouraged to add to this section** if you realize you are doing something
over and over again that's not documented here.

### General Notes

- Each lab shares common infrastructure. Commands that work in one lab should
  work exactly the same in another lab.
- The `build/` folder in any lab can be deleted and rebuilt at any time.
- We're using a build tool called [Bask][bask]; you may want to skim the
  [usage documentation][bask-usage].

### List the available commands

You can run `bask` to see the list of available tasks:

```shell
❯ bask
[00:00:00.000] Starting 'default'...
[00:00:00.000] Available tasks:
... snipped ...
```

### See a lab like a student does

You can get play around in a sandbox containing the files as a student would see
them (after unzipping) with the following command:

```shell
❯ bask sandbox
...
[00:00:00.000] Done staging file(s).
[00:00:00.000] See them at './build/sandbox'
...
```

### Play around with the reference solution

You can get the same sandbox as above but pre-populated with the reference
solution like this:

```shell
❯ bask sandbox_refsol
...
[00:00:00.000] Done staging file(s).
[00:00:00.000] See them at './build/sandbox-refsol'
...
```

### Install a lab to Autolab

Before you do anything, you should use the "Assessment Builder" on Autolab to
create an "assessment" for your lab.

Once you've created it, use "Edit Assessment" to set some sensible defaults.
(*TODO: expand this section*)

Next, you need to prepare all the required materials:

```shell
❯ bask autograder
...
[00:00:00.000] Done staging file(s).
[00:00:00.000] See them at './build/autolab'
...
```

Once you have all the staged files, you'll want to scp them to the lab directory
on AFS. This is a folder named like

```
/afs/cs/academic/class/15131-SEMESTER/autolab/LABNAME
```

so,

```shell
❯ scp build/autolab/* andrew:/afs/cs/academic/class/15131-SEMESTER/autolab/LABNAME
```

where `SEMESTER` and `LABNAME` are replaced appropriately.

### Make the lab handout zipfile

While `bask autograder` automatically handles creating the zipfile, if you want
to create it yourself for some reason, you can:

```shell
❯ bask handout
...
[00:00:00.000] Done staging file(s).
[00:00:00.000] See them at './build/LABNAME-handout.zip'
...
```

### Debug the autograder

Oftentimes you will need to debug a student solution, the driver, or the
autograding environment. For this, see [Manual Testing].


## Testing & Linting

We should strive to write and maintain quality labs. One of the best tools for
accomplishing this is automated and manual testing.

### Automated Linting

The most basic form of automated checks we do are checks on correct Bash usage.
For this we use a tool called [shellcheck]. Shellcheck tells you if you are
using Bash incorrectly or in a dangerous way.

Shellcheck is automatically run every time you push a branch to GitHub. You
will be able to see if Shellcheck passes or fails within each pull request that
you make.

Shellcheck can also be run locally by invoking the CI build manually:

```shell
❯ ./support/ci-build.sh
...
Linting files with Shellcheck...
...
[OK] Lint checks passed.
...
```

Finally, you are encouraged to configure your editor to print errors from
shellcheck inline. If you use Vim, you can do this by [installing
shellcheck][shellcheck] on your laptop and installing the [Syntastic][syntastic]
Vim plugin.

### Automated Testing

In addition to checking Bash usage, we run automated functional
tests<sup>†</sup> for all the labs.

These tests are not comprehensive; they only test a few submission types, and
they only check that the autograder *runs*, not that it *yields the correct
score*. This is enough for the time being, though we may want to consider
expanding these checks in the future.

<sup>†</sup> "Functional tests" are different from "unit tests". Unit tests
verify that code within a module works correctly. Functional tests verify that a
piece of software meets it's "functional requirements," which for us means that
all the labs run correctly on Autolab.

### Manual Testing

Since our automated tests aren't comprehensive, we have a number of ways of
manually testing our labs to ensure they work as well as to aid development.

#### Simulate a handin on Autolab

The first way you can manually test a lab is to craft a `handin.zip` for that
lab and simulate submitting it to Autolab.

1. Use the [sandbox] (or the [refsol sandbox]) and its `Makefile` to create a
  `handin.zip` file.
2. Move that file to `build/handin.zip`
3. Run `bask test_one`

This will capture the output from simulating a run in the autograder. You can
then manually verify things like whether it got the right score. This is very
useful as a debugging tool when writing a new lab.

#### Manually run the autograder

Sometimes you suspect that the autograder is broken, and you need to debug
what's up. For this, you can follow this recipe:

1. `bask autograder` to get the autograder files
2. Manually create a `handin.zip` file
3. Move the `handin.zip` file to `build/autolab`
4. Within `build/autolab/`, run `make -f autograde-Makefile`

These are the only steps required to run the autograder manually. This is the
same thing that `bask test_one` does, but you have a little more control over
the process, because the directory isn't deleted at the end.


## Lab Release Checklist

Before releasing any lab, you should complete the following checklist.

- [ ] [Install the lab to Autolab][install-lab]
- [ ] Verify that you can download the lab handout through Autolab
- Test that the autograder works on Autolab:
  - [ ] Use the [sandbox] to create an incorrect `handin.zip` and submit it
    - Verify that the autograder runs and reports a non-perfect score
  - [ ] Use the [refsol sandbox] to create a correct `handin.zip` and submit it
    - Make sure it gets a perfect score


## Guide for Lab Authors

Understand the contents of this section before starting to write your own lab.

### Lab Structure

First off, here's a breakdown of the folder structure of a lab:

```
myexamplelab
├── build/
│   └── ...
└── src/
    ├── dist/
    │   ├── driver/
    │   └── ...
    ├── driver-private/
    ├── driver-public/
    ├── refsol/
    ├── Baskfile -> ../shared/Baskfile
    ├── README.md
    └── config
```

### Important Files and Folders

At the very top level, there are two files:

- `config`
  - Declare lab-specific config here (like required handin files).
- `Baskfile`
  - A symlink to the shared Baskfile (see above for some useful bask targets).

Next up, all build assets are placed into the `build` folder. It's included here
for visualization--you should never have to create it yourself, and you can
safely delete and recreate it at any time.

Most of the important folders are in `src/`. Here's a list of the top level
`src/` files and folders and what they're used for.

- `dist/`
  - Everything in this folder will be seen by students in the top level of their
    handout folder, as well as inside the autograder as `src/dist`. This is the
    place for scaffold code, instructions, helper files for the lab, etc.
  - `driver/`
    - Inside `dist/` is the driver code, whose purpose is to check the student's
      work and give them feedback. It should be able to work both on Autolab as
      well as in the student's local environment.
    - There should always be an executable called `driver` in this folder which
      checks the student's work.
- `driver-public/`
  - Everything in here is copied into `dist/driver/` when **both** when creating
    the student handout folder and the autograder.
- `driver-private/`
  - Related to the above, the contents here end up in `dist/driver`, but only
    inside the autograder, not in the student handout.
  - This folder is useful for making "private" tests, i.e., tests that students
    can't see.
  - Files are copied over top of those in `driver-public`, so you *can*
    overwrite `driver-public` files in the generated output if you want to.
- `refsol`
  - The staff solutions. There should be one file for each declared required
    file in `config`.
  - Files in here are copied over top of everything in `dist/` when collecting the
    lab files, overwriting on name clashes.

### Tips for Writing a Lab

- If you're looking to copy and modify an existing lab, `pipelab` is a good
  example.

- When writing the driver, make sure that students can't log any output to the
  console. If they could, we could leak information about our autograder or
  private test cases.


## Contribute

This is how you should act when developing assignments.

### Git & Code Review

You should never push to the `master` branch directly. Instead, create a pull
request, and merge it after it's been reviewed. This ensures that at least two
people understand what a given piece of code does.

For more about why code review is important, [watch this video][code review].

Don't fork this repo. Instead, use feature branches *within this repo*. This
makes it easier for other TAs to collaborate on your work if necessary. Prefix
your feature branch names with your initials or username for clarity (i.e.,
`jez-finish-pipelab` rather than `finish-pipelab`).

Whenever you expect a response or changes from someone, assign the issue or pull
request to them with a note about what you'd like from them. Similarly,
self-assign a PR to indicate that it's a work in progress.

If someone asked you to review a PR, and you both agree that the changes are
good to go, add the "Approved" label, and let the author of a PR merge it into
`master` out of courtesy (i.e., try not to merge it for them).

### Style & Naming Conventions

Please use 2 spaces for indentation levels.

When necessary, prefer naming files using `kebab-case` (i.e.,
hyphen-separated names) instead of `snake_case` (i.e., underscore-separated
names).

Choosing good names is important. Your lab's name [must meet these
criteria][good names].

Names for assessments on Autolab should be named using UpperCamelCase and always
end in "Lab". For example: "PipeLab", "SportsLab", etc.

### Autograder Output

The autograder is the first way students will get feedback about their progress
on a lab. It's important to make this feedback as useful as possible.

The following does not apply to all autograders (TrainerLab stands out as an
example where these tips don't apply). Nonetheless, these are some good
principles to have in mind when writing an autograder.

- Feedback should be as useful as possible without revealing too much about the
  solution.
- Make one title per problem.
- Indent all feedback related to that problem by 4 spaces.
- Indent all diff or auto-generated output for that problem by 8 spaces.
- Leave one empty line between each problem
- Color success output in green
- Color failure output in red
- Color neutral information in bright white

Here's an example of the output from ForceLab:

![ForceLab output](https://cloud.githubusercontent.com/assets/5544532/18819601/c710c9b4-8361-11e6-8cfe-6fd1d9d794ae.png)

## Troubleshooting

If bask seems to be misbehaving in some way, try updating your bash.


## License

MIT License. See LICENSE.

[sandbox]: #see-a-lab-like-a-student-does
[refsol sandbox]: #play-around-with-the-reference-solution
[Manual Testing]: #manual-testing
[install-lab]: #install-a-lab-to-autolab

[bask]: https://github.com/jez/bask
[bask-usage]: https://github.com/jez/bask#usage
[shellcheck]: https://github.com/koalaman/shellcheck
[syntastic]: https://github.com/scrooloose/syntastic
[code review]: https://www.youtube.com/watch?v=PJjmw9TRB7s
[good names]: https://github.com/cmugpi/cmugpi.github.io#naming-is-important
