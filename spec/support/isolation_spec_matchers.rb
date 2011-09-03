# Used to test whether an exception was encountered and stored in RSpec metadata.
#
# Completely different from `x.should raise_error(err)`.
#
# Also accepts regular expressions.
#
# Examples:
#
#   # setup: run and then capture the example(s)
#   group.run
#   example = group.examples[0]
#
#   example.should_not have_encountered_exception
#   #=> "expected not to encounter an exception, but did"
#
#   example.should have_encountered_exception
#   #=> "expected to encounter an exception, but did not"
#
#   example.should_not have_encountered_exception("In same process")
#   #=> 'expected not to encounter exception "In same process", but did'
#
#   example.should have_encountered_exception("In same process")
#   #=> 'expected to encounter exception "In same process", but did not'
#   #=> 'expected to encounter exception "In same process", but encountered exception "expected: 2, got: 1"'
#
#   example.should have_encountered_exception(/process/)
#   #=> 'expected to encounter exception /process/, but encountered exception "expected: 2, got: 1"'
#
module RSpecIsolationSpecMatchers
  class EncounteredExceptionMatcher
    def initialize(message = nil)
      @message = message
    end
    
    def matches?(result)
      if RSPEC_VERSION < "2.6"
        exception = result.metadata[:execution_result]
        exception &&= exception[:exception_encountered] && exception[:exception_encountered].message
      else
        exception = result.execution_result[:exception]
        exception &&= exception.message.to_s
      end
      
      @exception = exception
      
      if @message.kind_of?(Regexp)
        exception && exception =~ @message
      else
        exception && exception == @message
      end
    end
    
    def basic_message
      if @message
        "expected to encounter exception #{@message.inspect}, but did not"
      else
        "expected to encounter an exception, but did not"
      end
    end
    
    def failure_message
      message = basic_message
      if @exception
        message['did not'] = "encountered exception #{@exception.inspect}"
      end
      message
    end
    
    def negative_failure_message
      result = basic_message
      result['to'] = 'not to'
      result['did not'] = 'did' if result['did not']
      result
    end
  end
  
  def have_encountered_exception(message = nil)
    EncounteredExceptionMatcher.new(message)
  end
end
