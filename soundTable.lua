local soundTable = {
    shootSound = audio.loadSound( "sound/shoot.wav" ),
    hitSound = audio.loadSound( "sound/hit.wav" ),
    explodeSound = audio.loadSound( "sound/explode.wav" ),
    hurtSound = audio.loadSound("sound/hurt.wav"),
    backgroundSound = audio.loadStream("sound/background.wav"),
}

return soundTable;
