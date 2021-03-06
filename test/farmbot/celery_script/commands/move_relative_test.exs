defmodule Farmbot.CeleryScript.Command.MoveRelativeTest do
  use ExUnit.Case, async: false
  # alias Farmbot.CeleryScript.Ast
  alias Farmbot.CeleryScript.Command

  setup_all do
    Farmbot.Serial.HandlerTest.wait_for_serial_available()
    :ok
  end

  test "makes sure we have serial" do
    assert Farmbot.Serial.Handler.available?() == true
  end

  test "moves to a location" do
    [oldx, oldy, oldz] = Farmbot.BotState.get_current_pos

    Command.move_relative(%{speed: 800, x: 100, y: 0, z: 0}, [])
    Process.sleep(100) # wait for serial to catch up
    [newx, newy, newz] = Farmbot.BotState.get_current_pos
    assert newx == oldx + 100
    assert newy == oldy
    assert newz == oldz
  end
end
