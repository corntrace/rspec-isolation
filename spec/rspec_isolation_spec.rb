require File.dirname(__FILE__) + '/spec_helper'

describe "#isolation" do
  context "in before each" do
    it "sets the example isolated" do
      group = RSpec::Core::ExampleGroup.describe do
        before(:each) {run_in_isolation}
        example('example') {}
      end
      group.run
      group.examples.first.run_in_isolation.should be_true
    end
  end
  context "in the example" do
    it "using iso_it sets the example isolated" do
      group = RSpec::Core::ExampleGroup.describe do
        iso_it {}
      end
      # group.run
      group.examples.first.run_in_isolation.should be_true
    end
  end
  context "failure and exception capture" do
    it "should capture failures" do
      group = RSpec::Core::ExampleGroup.describe
      example = group.iso_it('example') { 1.should == 2 }

      group.run
      example.should have_encountered_exception(/expected: 2,?\s+ got: 1 \(using ==\)/)
    end
    it "should capture exceptions" do
      group = RSpec::Core::ExampleGroup.describe
      example = group.iso_it('example') { raise "FOO" }

      group.run
      example.should have_encountered_exception("FOO")
    end
  end
  context "complicated conditions" do
    RSpec::Core::ExampleGroup.module_eval do
      def once_then_raise_error
        $test_counter ||= 0
        $test_counter += 1
        raise "In the same process" if $test_counter > 1
        return true
      end
    end
    it "should raise error if run in the same process" do
      group = RSpec::Core::ExampleGroup.describe "test" do
        $test_counter = 0
        it "test" do once_then_raise_error end
        it "test" do once_then_raise_error end
      end
      group.run
      group.examples[0].should_not have_encountered_exception
      group.examples[1].should     have_encountered_exception("In the same process")
    end
    it "should not raise if ran in isolation" do
      group = RSpec::Core::ExampleGroup.describe do
        $test_counter = 0
        iso_it {once_then_raise_error}
        iso_it {once_then_raise_error}
        example {once_then_raise_error}
      end
      group.run
      group.examples[0].should_not have_encountered_exception
      group.examples[1].should_not have_encountered_exception
    end
  end
end