local sfx = {
  boss = {
    spawn = {
      love.audio.newSource("assets/sfx/boss_1.wav","static"),
      love.audio.newSource("assets/sfx/boss_2.wav","static"),
      love.audio.newSource("assets/sfx/boss_3.wav","static"),
      love.audio.newSource("assets/sfx/boss_4.wav","static"),
      love.audio.newSource("assets/sfx/boss_5.wav","static"),
    },
    hurt = {
      love.audio.newSource("assets/sfx/boss_hurt_1.wav","static"),
      love.audio.newSource("assets/sfx/boss_hurt_2.wav","static"),
      love.audio.newSource("assets/sfx/boss_hurt_3.wav","static"),
    },
    kill = {
      love.audio.newSource("assets/sfx/boss_kill.wav","static"),
    },
  },
  player = {
    spawn = {
      love.audio.newSource("assets/sfx/player_1.wav","static"),
      love.audio.newSource("assets/sfx/player_2.wav","static"),
      love.audio.newSource("assets/sfx/player_3.wav","static"),
      love.audio.newSource("assets/sfx/player_4.wav","static"),
      love.audio.newSource("assets/sfx/player_5.wav","static"),
    },
    hurt = {
      love.audio.newSource("assets/sfx/player_hurt_1.wav","static"),
      love.audio.newSource("assets/sfx/player_hurt_2.wav","static"),
      love.audio.newSource("assets/sfx/player_hurt_3.wav","static"),
    },
    kill = {
      love.audio.newSource("assets/sfx/player_kill.wav","static"),
    },
  },
  weapon = {
    { love.audio.newSource("assets/sfx/weapon_1.wav","static"), },
    { love.audio.newSource("assets/sfx/weapon_2.wav","static"), },
  },
}

sfx.play = function(i)
  local index = math.random(#i)
  i[index]:stop()
  i[index]:play()
end

return sfx
