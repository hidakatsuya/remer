# Rexer: Redmine Extension manager

Rexer is a tool for managing Redmine Extension, which means Redmine [Plugin](https://www.redmine.org/projects/redmine/wiki/Plugins) and [Theme](https://www.redmine.org/projects/redmine/wiki/Themes) in this tool.

It is mainly aimed at helping with the development of Redmine and its plugins, allowing you to define extensions in a Ruby DSL and install, uninstall, update, and switch between different sets of the extensions.

[![Build](https://github.com/hidakatsuya/rexer/actions/workflows/build.yml/badge.svg)](https://github.com/hidakatsuya/rexer/actions/workflows/build.yml)
[![Gem Version](https://badge.fury.io/rb/rexer.svg)](https://badge.fury.io/rb/rexer)

## Installation

```
gem install rexer
```

## Supported Redmine

Rexer is tested with Redmine v5.1 and trunk.

## Usage

### Quick Start

First, create a `.extensions.rb` file in the root directory of the Redmine application.

```ruby
theme :bleuclair, github: { repo: "farend/redmine_theme_farend_bleuclair", branch: "support-propshaft" }

plugin :view_customize, github: { repo: "onozaty/redmine-view-customize", tag: "v3.5.2" }
plugin :redmine_issues_panel, git: { url: "https://github.com/redmica/redmine_issues_panel", tag: "v1.0.2" }
```

Then, run the following command in the root directory of the Redmine application.

```
rex install
```

This command installs plugins and themes defined in the `.extensions.rb` file and generates the `.extensions.lock` file.

> [!NOTE]
> The `.extensions.lock` file is a file that locks the state of the installed extensions, but it's NOT a file that locks the version of the extensions.

If you want to uninstall the extensions, run the following command.

```
rex uninstall
```

This command uninstalls the extensions and deletes the `.extensions.lock` file.

### Commands

```
$ rex
Commands:
  rex help [COMMAND]  # Describe available commands or one specific command
  dev envs            # Show the list of defined environments in .extensions.rb
  rex install [ENV]   # Install extensions for the specified environment
  rex state           # Show the current state of the installed extensions
  rex switch [ENV]    # Uninstall extensions for the currently installed environment and install extensions for the specified environment
  rex uninstall       # Uninstall extensions for the currently installed environment
  rex update          # Update extensions for the currently installed environment to the latest version
  rex version         # Show Rexer version
```

### Defining environments and extensions for the environment

```ruby
theme :bleuclair, github: { repo: "farend/redmine_theme_farend_bleuclair" }
plugin :redmine_issues_panel, git: { url: "https://github.com/redmica/redmine_issues_panel" }

env :stable do
  theme :bleuclair, github: { repo: "farend/redmine_theme_farend_bleuclair", branch: "support-propshaft" }
  plugin :redmine_issues_panel, git: { url: "https://github.com/redmica/redmine_issues_panel", tag: "v1.0.2" }
end
```

In above example, the `bleuclair` theme and the `redmine_issues_panel` plugin are defined for the `default` environment. The `bleuclair` theme and the `redmine_issues_panel` plugin are defined for the `stable` environment.

If you want to install extensions for the `default` environment, run the following command.

```
rex install
or
rex install default
```

Similarly, if you want to install extensions for the `stable` environment, run the following command.

```
rex install stable
```

In addition, you can switch between environments.

```
rex switch stable
or
rex install stable
```

The above command uninstalls the extensions for the currently installed environment and installs the extensions for the `stable` environment.

### Defining hooks

You can define hooks for each extension.

```ruby
plugin :redmica_s3, github: { repo: "redmica/redmica_s3" } do
  installed do
    Pathname.new("config", "s3.yml").write <<~YAML
      access_key_id: ...
    YAML
  end

  uninstalled do
    Pathname.new("config", "s3.yml").delete
  end

  updated do
    puts "updated"
  end
end
```

## Developing

### Running tests

First, you need to build the docker image for the integration tests.

```
rake test:prepare_integration
```

Then, you can run all tests.

```
rake test
```

Or, you can only the integration tests as follows.

```
rake test:integration
```

### Formatting and Linting code

This project uses [Standard](https://github.com/standardrb/standard) for code formatting and linting. You can format and check the code by running the following commands.

```
rake standard
rake standard:fix
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hidakatsuya/rexer.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
