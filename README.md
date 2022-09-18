# Slack Emoji Fetcher

A small utility that allows you to download all the custom emojis you've spent years collecting and sharing across your favourite Slack workspaces.

### Why?

There is a non-zero number of times I've left a gig and wanted to take my emojis with me so I could share them with new coworkers. There is also a non-zero number of times I've been asked by _former_ coworkers to send them all our custom emojis for the same reason. I am lazy and this utility makes the process incredibly simple.

## Requirements

Before you begin using `dq`, you will need the following installed on your machine:

1. [jq](https://awesomeopensource.com/project/elangosundar/awesome-README-templates)
2. Bash version 4, or higher.

## Installation

The command is completely self-contained in a single Bash script. Drop it in your system's `$PATH` and you're good to go. In the following example, we're saving it directly to `/usr/local/bin/dq`:

```bash
$ curl -s https://git.io/JiIu4 > /usr/local/bin/slack-emoji-fetcher
$ chmod a+x /usr/local/bin/slack-emoji-fetcher 
$ slack-emoji-fetcher --version
1.0.0
```

## Usage

Before you start liberating your emojis, you will need the following:
1. Your Slack worspace, or team, id
2. Your Slack session cookie.
3. The API token `slack-emoji-fetcher` will use to make requests on your behalf.

### Help Output
```
$ slack-emoji-fetcher --help
slack-emoji-fetcher - Download custom emojis from any Slack workspace.

Usage:
  slack-emoji-fetcher [options]
  slack-emoji-fetcher --help | -h
  slack-emoji-fetcher --version | -v

Options:
  --help, -h
    Show this help

  --version, -v
    Show version number

  --workspace-id ID (required)
    The unique identifier for your Slack workspace.

  --token TOKEN (required)
    The unique token associated with the API requests for the target Slack
    workspace.

  --cookie COOKIE (required)
    The value of the "d" cookie header used to authenticate with the target
    Slack workspace.

  --count COUNT
    The number of results to page through at a time.
    Default: 10

  --destination DESTINATION
    The directory in which emojis will be saved.
    Default: .

  --dry-run
    Queries the emoji endpoint, but does not save the results to disk.

  --debug
    Use to `set -x` for Bash while also activating high verbosity for curl
    commands. Useful for troubleshooting requests.

Examples:
  slack-emoji-fetcher --workspace-id=XXX --token=XXX --cookie=XXX
  slack-emoji-fetcher --workspace-id=XXX --token=XXX --cookie=XXX --debug --dry-run
  slack-emoji-fetcher --workspace-id=XXX --token=XXX --cookie=XXX --count=100 --destination="${HOME}/Downloads/emojis" --dry-run
```
    
## Building & Contributing

This tool is written in Bash, but built with [Bashly](https://bashly.dannyb.co/). Perform the following steps to begin developing locally:

1. Install Bashly locally with `gem install bashly`.
2. Clone this repository with `git@github.com:wilhelm-murdoch/slack-emoji-fetcher.git`.
3. Modify the tool's command configuration in `src/bashly.yml`.
4. Run `bashly g` from the root of this project to stub out any new commands or update any help documentation.
5. Start coding your new command from the stubbed Bash script in `src/*_command.sh`.
6. Run `bashly g` every time you wish to test your progress as Bashly consolidates all changes to the `dq` script located at the root of this project.

Contributions are always welcome. Just create a PR and remember to be nice.
## Acknowledgements

This stupid little tool couldn't be possible without the following projects:

 - [jq](https://awesomeopensource.com/project/elangosundar/awesome-README-templates)
 - [Bashly](https://bulldogjob.com/news/449-how-to-write-a-good-readme-for-your-github-project)
 - [readme.so](https://readme.so/)

## License

[Unlicense](https://choosealicense.com/licenses/unlicense/)

  