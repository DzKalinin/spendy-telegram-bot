require 'spec_helper'

describe MessageProcessor do
  let!(:from) { OpenStruct.new(first_name: 'Harry', username: 'lightning') }
  let!(:bot) { OpenStruct.new(chat: OpenStruct.new(id: 1)) }

  it 'should return main menu' do
    expect(MenuBuilder).to receive(:main_menu).with('Harry')
    described_class.process(OpenStruct.new(text: '/start', from: from))
  end

  it 'should log expense' do
    allow(ExpenseLogger).to receive(:push_to_spendy_events_processor).and_return(OpenStruct.new(body: { message: 'Saved!'}.to_json))
    expect(described_class.process(OpenStruct.new(text: '15;GEL;taxi;bolt', from: from))).to eq('Saved!')
  end

  it 'should log expense without place' do
    allow(ExpenseLogger).to receive(:push_to_spendy_events_processor).and_return(OpenStruct.new(body: { message: 'Saved!'}.to_json))
    expect(described_class.process(OpenStruct.new(text: '15;GEL;taxi', from: from))).to eq('Saved!')
  end

  context('process reports') do
    it 'should return category report' do
      allow(ReportBuilder).to receive(:_agg_spend_for).and_return(
        OpenStruct.new(body: {spends: [{ agg_field_value: 'total usd', currency: 'usd', amount: 64.2 },
                                       { agg_field_value: 'total byn', currency: 'byn', amount: 153.5 },
                                       { agg_field_value: 'food', currency: 'byn', amount: 153.5 },
                                       { agg_field_value: 'food', currency: 'usd', amount: 46.5 },
                                       { agg_field_value: 'taxi', currency: 'usd', amount: 17.7 }] }.to_json)
      )
      expect(described_class.process(OpenStruct.new(text: '/category_report', from: from))).to eq("total usd: 64.2 usd\ntotal byn: 153.5 byn\nfood: 153.5 byn\nfood: 46.5 usd\ntaxi: 17.7 usd")
    end

    it 'should return no expense for category report in no data' do
      allow(ReportBuilder).to receive(:_agg_spend_for).and_return(OpenStruct.new(body: { spends: [] }.to_json))
      expect(described_class.process(OpenStruct.new(text: '/category_report', from: from))).to eq('No expenses in this month!')
    end

    it 'should return daily report' do
      allow(ReportBuilder).to receive(:_agg_spend_for).and_return(
        OpenStruct.new(body: {spends: [{ agg_field_value: 'total usd', currency: 'usd', amount: 64.2 },
                                       { agg_field_value: 'total byn', currency: 'byn', amount: 153.5 },
                                       { agg_field_value: '01 Jul 2022', currency: 'byn', amount: 153.5 },
                                       { agg_field_value: '01 Jul 2022', currency: 'usd', amount: 17.7 },
                                       { agg_field_value: '02 Jul 2022', currency: 'usd', amount: 46.5 }] }.to_json)
      )
      expect(described_class.process(OpenStruct.new(text: '/daily_report', from: from))).to eq("total usd: 64.2 usd\ntotal byn: 153.5 byn\n01 Jul 2022: 153.5 byn\n01 Jul 2022: 17.7 usd\n02 Jul 2022: 46.5 usd")
    end

    it 'should return no expense for daily report in no data' do
      allow(ReportBuilder).to receive(:_agg_spend_for).and_return(OpenStruct.new(body: { spends: [] }.to_json))
      expect(described_class.process(OpenStruct.new(text: '/daily_report', from: from))).to eq('No expenses in this month!')
    end
  end


  context('process wrong format') do
    it 'should return wrong format msg' do
      expect(MenuBuilder).to receive(:wrong_format).with(no_args)
      described_class.process(OpenStruct.new(text: '15;GEL', from: from))
    end

    it 'should return wrong format msg' do
      expect(MenuBuilder).to receive(:wrong_format).with(no_args)
      described_class.process(OpenStruct.new(text: '15,GEL,taxi,bolt', from: from))
    end

    it 'should return wrong format msg' do
      expect(MenuBuilder).to receive(:wrong_format).with(no_args)
      described_class.process(OpenStruct.new(text: ' ', from: from))
    end
  end
end
