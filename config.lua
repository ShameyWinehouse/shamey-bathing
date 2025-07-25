
Config = {}

Config.Debug = false
Config.DebugPrint = false
Config.DebugCommands = false
Config.DebugOptions = {
}
Config.DebugVisual = false

Config.FliesThreshold = 25

Config.DbUpdateIntervalInSeconds = 60

Config.CleanlinessUpdateIntervalInSeconds = 5
Config.CleanlinessDecrementAmount = 1

Config.ItemNameSoap = "soap"

-- adds 5 extra soap items
Config.ItemNameSoaps = {
    "soap",
    -- Extra Soaps
    "LavenderSoap",
    "CitrusSoap",
    "AleSoap",
    "TobaccoSoap",
    "WildwoodSoap",
}

Config.Keys = {
    Wash = `INPUT_FRONTEND_RB`, -- E
    LeftArm = "INPUT_FRONTEND_LEFT",
    RightArm = "INPUT_FRONTEND_RIGHT",
    Head = "INPUT_FRONTEND_UP",
    Stop = "INPUT_FRONTEND_CANCEL",

    TakeABath = `INPUT_INTERACT_OPTION1`, -- G
    RequestDeluxe = "INPUT_CONTEXT_X", -- R
}

Config.WashKeyMashAmount = 4
Config.WashIncreaseAmount = 2

Config.Animations = {
    -- Tub = {
    --     {label = "Bath", dict = "mini_games@bathing@regular@arthur", name = "bathing_idle_02"},
    --     {label = "Bath: Scrub left arm", dict = "mini_games@bathing@regular@arthur", name = "head_scrub_fast_loop"},

    --     {label = "Bath: Scrub left arm", dict = "mini_games@bathing@regular@arthur", name = "left_arm_scrub_medium"},
    --     {label = "Bath: Scrub right arm", dict = "mini_games@bathing@regular@arthur", name = "right_arm_scrub_medium"},
    --     {label = "Bath: Scrub left leg", dict = "mini_games@bathing@regular@arthur", name = "left_leg_scrub_medium"},
    --     {label = "Bath: Scrub right leg", dict = "mini_games@bathing@regular@arthur", name = "right_leg_scrub_medium"},
    -- },
    Outdoors = {
        ["IDLE"] = {dict = "mini_games@bathing@regular@arthur", name = "scrub_idle"},
        ["HEAD"] = {dict = "mini_games@bathing@regular@arthur", name = "head_scrub_fast_loop"},
        ["LEFT_ARM"] = {dict = "mini_games@bathing@regular@arthur", name = "left_arm_scrub_medium"},
        ["RIGHT_ARM"] = {dict = "mini_games@bathing@regular@arthur", name = "right_arm_scrub_medium"},
    },
}


-- TUBS

Config.NormalTubPrice = 12
Config.DeluxeTubPrice = 7

Config.BathingZones = {
    ["SaintDenis"] = {
        dict = "script@mini_game@bathing@BATHING_INTRO_OUTRO_ST_DENIS",
        rag = vector4(2629.4, -1223.33, 58.57, -92.66),
        consumer = vector3(2632.6, -1223.79, 59.59),
        lady = `CS_BATHINGLADIES_01`,
        guy = `CS_LeviSimon`,
        door = 779421929
    },
    ["Valentine"] = {
        dict = "script@mini_game@bathing@BATHING_INTRO_OUTRO_VALENTINE",
        rag = vector4(-317.37, 761.8, 116.44, 10.365),
        consumer = vector3(-320.56, 762.41, 117.44),
        lady = `CS_BATHINGLADIES_01`,
        guy = `CS_LeviSimon`,
        door = 142240370
    },
    ["Annesburg"] = {
        dict = "script@mini_game@bathing@BATHING_INTRO_OUTRO_ANNESBURG",
        rag = vector4(2952.65, 1334.7, 43.44, -291.27),
        consumer = vector3(2950.42, 1332.15, 44.44),
        lady = `CS_BATHINGLADIES_01`,
        guy = `CS_LeviSimon`,
        door = -201071322
    },
    ["Strawberry"] = {
        dict = "script@mini_game@bathing@BATHING_INTRO_OUTRO_STRAWBERRY",
        rag = vector4(-1812.83, -373.23, 165.5, 1.206),
        consumer = vector3(-1816.45, -372.44, 166.50),
        lady = `CS_BATHINGLADIES_01`,
        guy = `CS_LeviSimon`,
        door = 1256786197
    },
    ["Blackwater"] = {
        dict = "script@mini_game@bathing@BATHING_INTRO_OUTRO_BLACKWATER",
        rag = vector4(-823.86, -1318.84, 42.68, -0.459),
        consumer = vector3(-822.82, -1315.72, 43.58),
        lady = `CS_BATHINGLADIES_01`,
        guy = `CS_LeviSimon`,
        door = 1523300673
    },
    ["Vanhorn"] = {
        dict = "script@mini_game@bathing@BATHING_INTRO_OUTRO_VANHORN",
        rag = vector4(2987.62, 573.21, 46.86, 83.841),
        consumer = vector3(2986.31, 568.27, 47.85),
        lady = `CS_BATHINGLADIES_01`,
        guy = `CS_LeviSimon`,
        door = 1102743282
    },
    ["Rhodes"] = {
        dict = "script@mini_game@bathing@BATHING_INTRO_OUTRO_RHODES",
        rag = vector4(1336.85, -1378.04, 83.2897, 166.469),
        consumer = vector3(1340.11, -1379.6, 84.28),
        lady = `CS_BATHINGLADIES_01`,
        guy = `CS_LeviSimon`,
        door = -1847993131
    },
    -- ["Tumbleweed"] = {
    --     dict = "script@mini_game@bathing@BATHING_INTRO_OUTRO_TUMBLEWEED",
    --     rag = vector4(-5513.76, -2972.3, -1.78, 15.0),
    --     consumer = vector3(-5517.83, -2973.23, -0.78),
    --     lady = `CS_BATHINGLADIES_01`,
    --     guy = `CS_LeviSimon`,
    --     door = 1682160693
    -- },
}

Config.BathingModes = {
    {
        transition = "Scrub_Head",
        scrub_freq = 0.75
    },
    {
        transition = "Scrub_Left_Arm",
        scrub_freq = 0.7,
        deluxe = true
    },
    {
        transition = "Scrub_Right_Arm",
        scrub_freq = 0.5,
        deluxe = true
    },
    {
        transition = "Scrub_Right_Leg",
        scrub_freq = 0.6,
        deluxe = true
    },
    {
        transition = "Scrub_Left_Leg",
        scrub_freq = 0.7,
        deluxe = true
    }
}

Config.Prompts = {
    {
        label = ("Take a Bath  |  ~o~$%0.2f"):format(Config.NormalTubPrice),
        id = "START_BATHING",
    },
	{
        label = "Scrub",
        id = "SCRUB",
        control = `INPUT_CONTEXT_X`,
        time = 2000
    },
    {
        label = ("Request Deluxe Assistance  |  ~o~$%0.2f"):format(Config.DeluxeTubPrice),
        id = "REQUEST_DELUXE_BATHING"
    },
	{
        label = "Exit",
        id = "STOP_BATHING",
        control = `INPUT_INTERACT_NEG`
    },
    {
        label = "Camera",
        id = "CAMERA",
        control = `INPUT_FRONTEND_RIGHT`,
        time = 1
    }
}

Config.TubHotties = {
    -- MASC
    ["Clifford"] = { -- Twink
        name = "Clifford",
        ped = "CS_FRANCIS_SINCLAIR",
    },
    ["Lucian"] = { -- Rich
        name = "Lucian",
        ped = "CS_LUCANAPOLI"
    },
    ["Chester"] = { -- Deputy
        name = "Officer Chester",
        ped = "CS_ASBDEPUTY_01"
    },

    -- FEM
    ["Maude"] = { -- Older mommy
        name = "Maude",
        ped = "CS_AberdeenSister",
        outfit = 1,
    },
    ["Nora"] = { -- Freckles bust
        name = "Nora",
        ped = "CS_ValProstitute_02"
    },
    ["Doris"] = { -- Daenerys
        name = "Doris",
        ped = "CS_MP_allison"
    },
    ["Myrtle"] = { -- Molly in a camp outfit
        name = "Myrtle the Acrobat",
        ped = "CS_Acrobat"
    },
}

Config.CreatedEntries = {}


-- Config.Webhook = "https://discord.com/api/webhooks/..."