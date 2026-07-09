# Sidekiq operates in two modes : server, the process that executes jobs (e.g. sends emails), client, the process that adds jobs
# to the queue (e.g. from the Rails application).

# Sidekiq -  constant provided by the sidekiq gem.
# .configure_server - class method (called on Sidekiq module). It is defined by the sidekiq gem.
# do |config| - block, a piece of code that is executed in the context of the configure_server method.
# |config| – the block parameter. The configure_server method passes a config object to the block, which contains the Sidekiq
# configuration settings.
Sidekiq.configure_server do |config|
    # config – the object received in the block.
    # .redis - a setter method (assignment) on the config object. It is used to configure Redis.
    # { url: '...' } – he value is a string containing the Redis address.
    config.redis = { url: "redis://0.0.0.0:6379/0" }
end

# .configure_server – configures the Sidekiq server process (the one that executes jobs).
# .configure_client – configures the Rails application (the one that adds jobs to the queue).
# Both looks similar but are called in diffrent context.
Sidekiq.configure_client do |config|
    config.redis = { url: "redis://0.0.0.0:6379/0" }
end
