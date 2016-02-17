module Toolkits
  module EventLoggers
    module SharedExamples

      RSpec.shared_examples "EventLogger::Enqueue is included" do |logger_class, logger_name|
        describe "#initialize" do
          subject { new_logger }

          it "should set an @attrs hash" do
            expect(subject.instance_variable_get(:@attrs)).to eq(logger_attrs)
          end
        end

        describe "enqueuing" do
          before(:each) do
            ResqueSpec.reset!
          end

          describe "enqueue without schedule" do
            before(:each) { new_logger.enqueue }

            it "should find a job in the #{logger_name} queue" do
              resque_job = Resque.peek(:"#{logger_name}_event_logger")
              expect(resque_job).to be_present
            end

            it "should have a #{logger_name} logger event in the queue" do
              expect(logger_class).to have_queue_size_of(1)
            end
          end

          describe "enqueue with schedule" do
            describe"enqueue_in" do
              subject { new_logger.enqueue_in(2.hours) }

              it "should schedule a #{logger_name} event" do
                subject
                expect(logger_class).to have_scheduled(logger_name, logger_attrs).in(2.hours)
              end
            end

            describe "enqueue_at" do
              let!(:"#{logger_name}_event_logger") { new_logger.enqueue_at later }
              let(:later) { Time.parse "Feb 10 2052" }

              it "should enqueue the login logger to trigger :later" do
                expect(logger_class).to have_scheduled(logger_name, logger_attrs).at later
              end
            end
          end
        end
      end

      RSpec.shared_examples "an EventLogger subclass" do |logger_class, logger_name|

        describe "class-level instance variables" do
          describe "@queue" do
            it "uses the #{logger_name}_event_logger queue" do
              expect(logger_class.instance_variable_get(:@queue)).to eq(:"#{logger_name}_event_logger")
            end
          end

          describe "@event_name" do
            it "uses #{logger_name.capitalize} as an event name for messaging" do
              expect(logger_class.instance_variable_get(:@event_name)).to eq(logger_name.capitalize)
            end
          end
        end

        describe "#event_type" do
          it "provides '#{logger_name}' as an event type" do
            expect(new_logger.event_type).to eq(logger_name)
          end
        end

      end

    end
  end
end



