local weaponName="Typhoon-TWeapon"
local weaponDef={
    name="Tactic Missle",
    weaponType=[[MissileLauncher]],

    Accuracy=2000,

    --Physic/flight path
    trajectoryHeight = 1.2, --баллистическая траектория
    range=800,
    reloadtime=3.25,
    weaponVelocity=400,
    startVelocity=150,
    weaponAcceleration=200,
    flightTime=8,
    BurnBlow=0,
    FixedLauncher=true,
    dance=0,
    wobble=0,
    tolerance=32000,
    tracks=true,
    Turnrate=32000,
    collideFriendly=true,
    burst = 2,
    burstRate = 0.25,
    paralyzeTime = 2.5,
    paralyzer = true,
    soundStart = [[Weapons/LightMissle_missile_fire]],
    soundHit = [[Weapons/StunMissle_Hit]],
    soundStartVolume = 4,

    ----APPEARANCE
    smokeTrail=false,
    model="Rocket.s3o",
    cegTag = [[SmallStunRocket_trail]],
    explosionGenerator = [[custom:stunburststunmissleflash]],

    ----TARGETING
    turret=true,
    CylinderTargetting=true,
    avoidFeature=false,
    avoidFriendly=true,


    --commandfire=true,

    ----DAMAGE
    damage={
        default=80,
        heavyarmor=1,
    },

    targetable = 1, --чтобы работал перехват
    customParams = {
        --cruise_missile = 1,
       -- intercepttype = "missile", -- указываем что снаряда перехватываемый
    },

    areaOfEffect=3,
    craterMult=0,

    --?FIXME***
    lineOfSight=true,
}

return lowerkeys ({[weaponName]=weaponDef})
