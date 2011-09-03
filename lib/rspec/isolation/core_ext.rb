RSpec::Core::ExampleGroup.send :include, RSpec::Isolation
RSpec::Core::ExampleGroup.alias_example_to :run_in_isolation, :run_in_isolation => true
RSpec::Core::ExampleGroup.alias_example_to :iso_it, :run_in_isolation => true

RSpec::Core::Example.class_eval do
  
  delegate_to_metadata :run_in_isolation
  
  def isolated?
    !!run_in_isolation
  end
  
  def isolated_or_normal
    if isolated?
      read, write = IO.pipe
      pid = fork do
        read.close
        begin
          rest = yield
          write.puts [Marshal.dump(rest)].pack("m")
        rescue Exception => e
          write.puts [Marshal.dump(e)].pack("m")
        end
        exit!
      end
      write.close
      result = Marshal.load(read.read.unpack("m").first)
      Process.wait2(pid)

      raise result if result.class < Exception
      return result
    else
      yield
    end
  end
  
  # Redefine the run method
  if defined?(RSpec::Core::Version::STRING) && RSpec::Core::Version::STRING >= "2.6"
    def run(example_group_instance, reporter)
      @example_group_instance = example_group_instance
      @example_group_instance.example = self
    
      start(reporter)
    
      begin
        unless pending
          with_around_hooks do
            isolated_or_normal do
              begin
                run_before_each
                @example_group_instance.instance_eval(&@example_block)
              rescue RSpec::Core::Pending::PendingDeclaredInExample => e
                @pending_declared_in_example = e.message
              rescue Exception => e
                set_exception(e)
              ensure
                run_after_each
              end
            end
          end
        end
      rescue Exception => e
        set_exception(e)
      ensure
        @example_group_instance.instance_variables.each do |ivar|
          @example_group_instance.instance_variable_set(ivar, nil)
        end
        @example_group_instance = nil
    
        begin
          assign_auto_description
        rescue Exception => e
          set_exception(e)
        end
      end
    
      finish(reporter)
    end
  else
    def run(example_group_instance, reporter)
      return if RSpec.wants_to_quit
      @example_group_instance = example_group_instance
      @example_group_instance.example = self
  
      start(reporter)
  
      begin
        unless pending
          with_pending_capture do
            with_around_hooks do
              begin
                run_before_each
                @in_block = true
                isolated_or_normal { @example_group_instance.instance_eval(&@example_block) }
              rescue Exception => e
                set_exception(e)
              ensure
                @in_block = false
                run_after_each
              end
            end
          end
        end
      rescue Exception => e
        set_exception(e)
      ensure
        @example_group_instance.example = nil
        assign_auto_description
      end
  
      finish(reporter)
    end
  end
end