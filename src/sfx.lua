local sfx = {
  boss = {
    spawn = {
      love.audio.newSource("assets/sfx/boss_1.ogg","static"),
      love.audio.newSource("assets/sfx/boss_2.ogg","static"),
      love.audio.newSource("assets/sfx/boss_3.ogg","static"),
      love.audio.newSource("assets/sfx/boss_4.ogg","static"),
      love.audio.newSource("assets/sfx/boss_5.ogg","static"),
    },
    hurt = {
      love.audio.newSource("assets/sfx/boss_hurt_1.ogg","static"),
      love.audio.newSource("assets/sfx/boss_hurt_2.ogg","static"),
      love.audio.newSource("assets/sfx/boss_hurt_3.ogg","static"),
    },
    kill = {
      love.audio.newSource("assets/sfx/boss_kill.ogg","static"),
    },
  },
  player = {
    spawn = {
      love.audio.newSource("assets/sfx/player_1.ogg","static"),
      love.audio.newSource("assets/sfx/player_2.ogg","static"),
      love.audio.newSource("assets/sfx/player_3.ogg","static"),
      love.audio.newSource("assets/sfx/player_4.ogg","static"),
      love.audio.newSource("assets/sfx/player_5.ogg","static"),
    },
    hurt = {
      love.audio.newSource("assets/sfx/player_hurt_1.ogg","static"),
      love.audio.newSource("assets/sfx/player_hurt_2.ogg","static"),
      love.audio.newSource("assets/sfx/player_hurt_3.ogg","static"),
    },
    kill = {
      love.audio.newSource("assets/sfx/player_kill.ogg","static"),
    },
  },
  weapon = {
    { love.audio.newSource("assets/sfx/weapon_1.ogg","static"), },
    { love.audio.newSource("assets/sfx/weapon_2.ogg","static"), },
  },
}

sfx.play = function(i)
  local index = math.random(#i)
  i[index]:stop()
  i[index]:play()
end

return sfx
