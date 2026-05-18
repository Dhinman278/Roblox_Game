local ClanData = {}
ClanData.data = {}
ClanData.rarity = {
		["Common"] = 70,
    ["Uncommon"] = 15,
    ["Rare"] = 9,
    ["Epic"] = 4,
    ["Legendary"] = 1.5,
    ["Mythical"] = 0.5,
    }

    -- Replace StatMult with a Stats table for explicit starting stats per clan.
    -- Example stat keys: Health, Attack, Defense, Speed, Stamina
      -- COMMON (examples)
    ClanData.clans = {
    {Name = "Forest Dweller", Rarity = "Common", Stats = {Health = 100, Defense = 6, Stamina = 2}},
    {Name = "Plain Runner", Rarity = "Common", Stats = {Health = 95, Defense = 5, Stamina = 1}},
      -- ... add other commons with their own Stats ...

      -- UNCOMMON
    {Name = "Ironclad", Rarity = "Uncommon", Stats = {Health = 130, Defense = 12,Stamina = 2}},
    {Name = "Swiftwind", Rarity = "Uncommon", Stats = {Health = 110  Defense = 7, Stamina = 3}},

      -- RARE
    {Name = "Sunforged", Rarity = "Rare", Stats = {Health = 150, Defense = 14,Stamina = 5}},
    {Name = "Shadowcloak", Rarity = "Rare", Stats = {Health = 140, Defense = 10, Stamina = 6}},

    -- EPIC
    {Name = "Abyssal", Rarity = "Epic", Stats = {Health = 180, Defense = 18, Stamina = 12}},
    {Name = "Iida", Rarity = "Epic", Stats = {Health = 175, Defense = 16, Stamina = 14}},

    -- LEGENDARY
    {Name = "Takami", Rarity = "Legendary", Stats = {Health = 220, Defense = 24, Stamina = 18}},
    {Name = "Kirishima", Rarity = "Mythical", Stats = {Health = 300, Defense = 30, Stamina = 30}},

    -- MYTHICAL
    {Name = "Midoriya", Rarity = "Mythical", Stats = {Health = 300, Defense = 30, Stamina = 30}},
    {Name = "Todoroki", Rarity = "Mythical", Stats = {Health = 300, Defense = 30, Stamina = 30}},
    {Name = "Bakugo", Rarity = "Mythical", Stats = {Health = 300, Defense = 30, Stamina = 30}},
    }

    -- Utility: lookup clan by name
    function ClanData:GetClanByName(name)
    for _, clan in ipairs(self.clans) do
    if clan.Name == name then
  return clan
  end
  end
  return nil
  end
return ClanData