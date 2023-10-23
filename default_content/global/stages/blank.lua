function onCreate()
    makeLuaSprite("bg", "blank");
    screenCenter("bg");
    setProperty("bg.x", getProperty("bg.width") * 0.05);
    setScrollFactor(0.85, 0.85);
    addLuaSprite("bg")
end