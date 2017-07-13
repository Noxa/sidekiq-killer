module Sidekiq
  module Killer
    class Memory
      def initialize(options = {})
        @max_rss         = (options['max_rss']         || 0).to_s.to_i
        @grace_time      = (options['grace_time']      || 0).to_s.to_i
        @shutdown_wait   = (options['shutdown_wait']   || 15 * 60).to_s.to_i
        @shutdown_signal = (options['shutdown_signal'] || 'SIGKILL').to_s
      end

      # Create a mutex used to ensure there will be only one thread waiting to
      # shut Sidekiq down
      MUTEX = Mutex.new

      def call(worker, job, queue)
        yield
        current_rss = get_rss

        return unless @max_rss > 0 && current_rss > @max_rss

        Thread.new do
          # Return if another thread is already waiting to shut Sidekiq down
          return unless MUTEX.try_lock

          Sidekiq.logger.warn 'current RSS #{current_rss} exceeds maximum RSS '\
            '#{@max_rss}'
          Sidekiq.logger.warn 'this thread will shut down PID #{Process.pid} - Worker #{worker.class} - JID-#{job['jid']}'\
            'in #{@grace_time} seconds'
          sleep(@grace_time)

          Sidekiq.logger.warn 'sending SIGTERM to PID #{Process.pid} - Worker #{worker.class} - JID-#{job['jid']}'
          Process.kill('SIGTERM', Process.pid)

          Sidekiq.logger.warn 'waiting #{@shutdown_wait} seconds before sending '\
            '#{@shutdown_signal} to PID #{Process.pid} - Worker #{worker.class} - JID-#{job['jid']}'
          sleep(@shutdown_wait)

          Sidekiq.logger.warn 'sending #{@shutdown_signal} to PID #{Process.pid} - Worker #{worker.class} - JID-#{job['jid']}'
          Process.kill(@shutdown_signal, Process.pid)
        end
      end

      private
      def get_rss
        GetProcessMem.new.mb
      end
    end
  end
end
