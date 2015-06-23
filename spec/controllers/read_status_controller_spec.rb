require 'spec_helper'

describe FBPi::ReadStatusController do
  let(:bot) do
    bot = FakeBot.new
    bot.commands = FakeOutgoingHandler.new
    bot
  end
  let(:mesh) { FakeMesh.new }
  let(:message) do
    FBPi::MeshMessage.new(from:   '1234567890',
                          method: 'read_status')
  end
  let(:controller) { FBPi::ReadStatusController.new(message, bot, mesh) }

  it 'provides axis info' do
    expect(controller.axis_info).to eq(x: 0, y: 0, z: 0)
  end

  it 'returns status of each pin via pin_info' do
    expected_values = [*0..13].map{ |s| "pin#{s}".to_sym }
    actual_values = controller.pin_info.keys

    expected_values.each do |expectation|
      expect(actual_values).to include(expectation)
    end

    bot.status.set_pin(1, 0)
    bot.status.set_pin(2, 1)

    expect(controller.pin_info[:pin1]).to be(:off)
    expect(controller.pin_info[:pin2]).to be(:on)
    expect(controller.pin_info[:pin3]).to be(:unknown)
  end

  it 'shows the bot info()' do
    info = controller.info
    expect(info[:busy]).to eq(1)
    expect(info[:x]).to eq(0)
    expect(info[:y]).to eq(0)
    expect(info[:z]).to eq(0)
    expect(info[:current_command]).to eq("none")
  end

  it 'handles a call' do
    #       _______
    #     /` _____ `\;,
    #    /__(^===^)__\';,
    #      /  :::  \   ,;
    #     |   :::   | ,;'
    # jgs  '._______.'`

    controller.call
    msg = mesh.last.params
    expect(msg[:result][:type]).to eq("read_status")
    keys = msg[:result]
    [:busy, :current_command, :x, :y, :z].each do |key|
      expect(keys).to include(key)
    end
  end
end
