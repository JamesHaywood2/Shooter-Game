local soundTable = {
    shootSound = audio.loadSound( "sound/shoot.wav" ),
    hitSound = audio.loadSound( "sound/hit.wav" ),
    explodeSound = audio.loadSound( "sound/explode.wav" ),
    hurtSound = audio.loadSound("sound/hurt.wav"),
    backgroundSound = audio.loadStream("sound/background.wav"),
    slashSound = audio.loadSound("sound/slash.wav"),
    threeShot = audio.loadSound("sound/3shot.wav"),
    bossDeath = audio.loadSound("sound/bossDeath.wav"),
    sharkAttack = audio.loadSound("sound/shark.wav"),
    fireBall = audio.loadSound("sound/fireball.wav"),
    bossHit = audio.loadSound("sound/bossHit.wav"),
}

return soundTable;
