# Sidekiq::Killer

Kills Sidekiq processes when the RSS is too high.

It checks the memory usage of sidekiq after each job, and if the memory usage is
higher than specified, it will wait for the specified grace_time before quieting
the sidekiq process. After the shutdown_wait time it will forcibly kill sidekiq
using the signal specified in shutdown_signal.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'noxa-sidekiq-killer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install noxa-sidekiq-killer

## Usage

Add the following to your Sidekiq configuration:

```
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Killer::Memory, max_rss: 250, grace_time: 0, shutdown_wait: (15 * 60), shutdown_signal: 'SIGKILL'
  end
end
```

## Configuration options

| Setting         | Description                                                                                 |
| --------------- | ------------------------------------------------------------------------------------------- |
| max_rss         | Max RSS (in megabytes)                                                                      |
| grace_time      | Time to wait before quieting sidekiq (in seconds)                                           |
| shutdown_wait   | Time to wait after quieting to finish off jobs before forcibly killing sidekiq (in seconds) |
| shutdown_signal | Signal to use to shutdown sidekiq                                                           |

## Acknowledgements

This killer is based on the code from GitLab (https://gitlab.com/gitlab-org/gitlab-ce/).
