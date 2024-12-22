# PowerToys Run Plugin Manager

![preview](https://github.com/user-attachments/assets/94489f6f-0301-4427-8c44-2f801201c64f)

This is a cli tool to manage PowerToys Run plugins. It can be used to install, uninstall, update, list, and import plugins.

## Installation

Download binary from [releases](https://github.com/8LWXpg/ptr/releases) page.

or build from source:

```
cargo install --git https://github.com/8LWXpg/ptr.git
```

### Features

- Easy to use command line interface with informative help messages.
- Automatically download and install plugins from GitHub.
- Restart PowerToys after installing or removing plugins.
- Update all plugins with a single command.
- Restore plugins from a configuration file.

## Limitations

If you have any suggestions for these limitations, feel free to open an issue.

- This tool only supports plugins hosted on GitHub.
- The plugin release must be a zip file with either `x64` or `arm64` in the file name, or the tool will prompt you to specify the asset.
- The zip structure must be like this:
  ```
  something-x64.zip
  └── anyPluginName
      |   plugin.dll
      └── plugin files...
  ```

For more general pattern matching and downloading, check another tool I wrote: [gpm](https://github.com/8LWXpg/gpm).


## Usage

This tool will create a file at `%LOCALAPPDATA%\Microsoft\PowerToys\PowerToys Run\Plugins\version.toml` to store installed plugins.

```
Usage: ptr.exe <COMMAND>

Commands:
  add         Add a plugin [aliases: a]
  update      Update plugins [aliases: u]
  remove      Remove plugins [aliases: r]
  list        List all installed plugins [aliases: l]
  pin         Pin plugins so it's not updated with `update --all` [aliases: p]
  import      Import plugins from configuration file [aliases: i]
  restart     Restart PowerToys
  completion  Generate shell completion (PowerShell)
  help        Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version
```

### Add

```
Usage: ptr.exe add <NAME> <REPO>

Arguments:
  <NAME>  The name of the plugin, can be anything.
  <REPO>  The GitHub repository of the plugin

Options:
  -v, --version <VERSION>  The target version of the plugin
  -h, --help               Print help
```

e.g.

```
ptr a GitHubRepo 8LWXpg/PowerToysRun-GitHubRepo
```

### Update

```
Usage: ptr.exe update [OPTIONS] [NAME]...

Arguments:
  [NAME]...  The name of the plugins to update

Options:
  -a, --all                Update all plugins
  -v, --version <VERSION>  Version to update to
  -h, --help               Print help
```

e.g.
```
ptr u -a
```

```
ptr u Plugin1 Plugin2 -v v1.1.0 -v 1.2.0
```

### Remove

```
Usage: ptr.exe remove [NAME]...

Arguments:
  [NAME]...  The name of the plugins to remove

Options:
  -h, --help  Print help
```

e.g.
```
ptr r GitHubRepo ProcessKiller
```

### List

```
Usage: ptr.exe list
```

### Pin

```
Usage: ptr.exe pin <COMMAND>

Commands:
  add     Add pins [aliases: a]
  remove  Remove pins [aliases: r]
  list    List pins [aliases: l]
  reset   Clear all pins
  help    Print this message or the help of the given subcommand(s)

Options:
  -h, --help  Print help
```

### Import

This reads the configuration file at `%LOCALAPPDATA%\Microsoft\PowerToys\PowerToys Run\Plugins\version.toml`.

```
Usage: ptr.exe import [OPTIONS]

Options:
  -d, --dry-run  Update the configuration file without downloading the plugin
  -h, --help     Print help
```

### Restart

```
Usage: ptr.exe restart
```

### Completion

```
Usage: ptr.exe completion
```

```pwsh
(ptr completion) -join "`n" | iex
```

## Why Rust?

The `clap` crate in Rust is very powerful and easy to use for building command line applications, so I chose Rust to build this tool.
