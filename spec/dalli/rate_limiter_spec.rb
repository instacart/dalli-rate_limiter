require "spec_helper"

describe Dalli::RateLimiter do
  Then { !Dalli::RateLimiter::VERSION.nil? }

  Given(:lim) do
    Dalli::RateLimiter.new nil,
      :max_requests => 5, :period => 8, :key_prefix => RUBY_VERSION
  end

  context "with no previous attempts" do
    When(:result) { lim.exceeded? "test_key_1" }

    Then { !result }
  end

  context "with too many attempts" do
    When(:result) { 6.times { lim.exceeded? "test_key_2" } }

    Then { result && result > 0 }
  end

  context "with sleeping" do
    When { sleep 6.times { lim.exceeded? "test_key_3" } }

    When(:result) { lim.exceeded? "test_key_3" }

    Then { !result }
  end

  context "with almost too many requests" do
    When(:result) { lim.exceeded? "test_key_4", lim.max_requests }

    Then { !result }
  end

  context "with too many requests" do
    When(:result) { lim.exceeded? "test_key_5", lim.max_requests + 1 }

    Then { result && result < 0 }
  end

  context "with a block" do
    When(:result) do
      lim.without_exceeding("test_key_6") { 1 + 1 }
    end

    Then { result == 2 }
  end

  context "with would_exceed?" do
    context "with no previous attempts" do
      When(:result) { lim.would_exceed? "test_key_7" }

      Then { !result }
    end

    context "after too many attempts" do
      When(:result) {
        5.times { lim.exceeded? "test_key_8" }
        lim.would_exceed? "test_key_8"
      }

      Then { result && result > 0 }
    end

    context "with almost too many requests" do
      When(:result) { lim.would_exceed? "test_key_9", lim.max_requests }

      Then { !result }
    end

    context "with too many requests" do
      When(:result) { lim.would_exceed? "test_key_10", lim.max_requests + 1 }

      Then { result == -1 }
    end
  end
end
