
<!-- TOC -->

- [GitHub Actions](#github-actions)
  - [Udemy course](#udemy-course)
  - [Book](#book)
- [Git courses](#git-courses)
  - [Git course in PL - YouTube](#git-course-in-pl---youtube)
  - [Git course in EN - Udemy](#git-course-in-en---udemy)
- [Overview](#overview)
  - [GitHub Actions Components](#github-actions-components)
- [Notes and link from following course](#notes-and-link-from-following-course)
  - [Repository for sections 1 to 4 and 4, 5](#repository-for-sections-1-to-4-and-4-5)
  - [About GitHub-hosted runners](#about-github-hosted-runners)
  - [Workflow syntax for GitHub Actions](#workflow-syntax-for-github-actions)

<!-- /TOC -->

# GitHub Actions

## Udemy course

- The Complete GitHub Actions & Workflows Guide
    - https://www.udemy.com/course/github-actions/

## Book

- Automating Workflows with GitHub Actions
  - https://learning.oreilly.com/library/view/automating-workflows-with/9781800560406/

___

# Git courses

## Git course in PL - YouTube

- Git course
  - https://www.youtube.com/watch?v=tvHVafvw16Y&list=PLj-pbEqbjo6AKsJ8oE2pvIqsb15mxdrxs&ab_channel=Zaprogramuj%C5%BBycie


## Git course in EN - Udemy

- The Git & Github Bootcamp
  - https://www.udemy.com/course/git-and-github-bootcamp/niefree


___

# Overview

GitHub Actions is a continuous integration and continuous delivery (CI/CD) platform that allows you to automate your build, test, and deployment pipeline. You can create workflows that build and test every pull request to your repository, or deploy merged pull requests to production.

GitHub Actions goes beyond just DevOps and lets you run workflows when other events happen in your repository. For example, you can run a workflow to automatically add the appropriate labels whenever someone creates a new issue in your repository.

GitHub provides Linux, Windows, and macOS virtual machines to run your workflows, or you can host your own self-hosted runners in your own data center or cloud infrastructure.


## GitHub Actions Components


- Workflows

A workflow is a configurable automated process that will run one or more jobs. Workflows are defined by a YAML file checked in to your repository and will run when triggered by an event in your repository, or they can be triggered manually, or at a defined schedule.


- Events

An event is a specific activity in a repository that triggers a workflow run. For example, activity can originate from GitHub when someone creates a pull request, opens an issue, or pushes a commit to a repository. You can also trigger a workflow run on a schedule, by posting to a REST API, or manually.


- Jobs

A job is a set of steps in a workflow that execute on the same runner. Each step is either a shell script that will be executed, or an action that will be run. Steps are executed in order and are dependent on each other. Since each step is executed on the same runner, you can share data from one step to another. For example, you can have a step that builds your application followed by a step that tests the application that was built.


- Actions

An action is a custom application for the GitHub Actions platform that performs a complex but frequently repeated task. Use an action to help reduce the amount of repetitive code that you write in your workflow files. An action can pull your git repository from GitHub, set up the correct toolchain for your build environment, or set up the authentication to your cloud provider.


- Runners

A runner is a server that runs your workflows when they're triggered. Each runner can run a single job at a time. GitHub provides Ubuntu Linux, Microsoft Windows, and macOS runners to run your workflows; each workflow run executes in a fresh, newly-provisioned virtual machine. GitHub also offers larger runners, which are available in larger configurations.

___

# Notes and link from following course

The Complete GitHub Actions & Workflows Guide
- https://www.udemy.com/course/github-actions/


## Repository for sections 1 to 4 and 4, 5

- https://github.com/alialaa/github-actions-course
- https://github.com/alialaa/github-actions-course-react



## About GitHub-hosted runners

- https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-software

GitHub offers hosted virtual machines to run workflows. The virtual machine contains an environment of tools, packages, and settings available for GitHub Actions to use.

Runners are the machines that execute jobs in a GitHub Actions workflow. For example, a runner can clone your repository locally, install testing software, and then run commands that evaluate your code.


## Workflow syntax for GitHub Actions

A workflow is a configurable automated process made up of one or more jobs. You must create a YAML file to define your workflow configuration.

https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions

