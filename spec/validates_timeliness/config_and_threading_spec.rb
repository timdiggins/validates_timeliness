# frozen_string_literal: true

RSpec.describe 'Validates Timeliness threadsafety' do
  before(:each) do
    ValidatesTimeliness.setup do |config|
      config.parser.remove_us_formats
    end
  end

  let(:us_date) { '06/30/2016' }
  let(:eu_date) { '30/06/2016' }

  # (fails with Timeliness >= 0.4 but should be fixed with ValidatesTimeliness?)
  it "doesn't need re-configuration per thread" do
    expect(Timeliness.parse(eu_date)).not_to be_nil
    expect(Timeliness.parse(us_date)).to be_nil
    threads = []
    threads << Thread.new { expect(Timeliness.parse(eu_date)).not_to be_nil }
    threads << Thread.new { expect(Timeliness.parse(us_date)).to be_nil }
    threads.each(&:join)
  end

  # (fails with Timeliness < 0.4, fixed with Timeliness >= 0.4)
  it 'is thread_safe' do
    threads = []
    threads << Thread.new do
      Timeliness.use_euro_formats
      10_000.times { expect(Timeliness.parse(eu_date)).not_to be_nil }
    end
    threads << Thread.new do
      Timeliness.use_us_formats
      10_000.times { expect(Timeliness.parse(us_date)).not_to be_nil }
    end
    threads.each do |t|
      t.report_on_exception = false
      t.join
    end
  end
end
