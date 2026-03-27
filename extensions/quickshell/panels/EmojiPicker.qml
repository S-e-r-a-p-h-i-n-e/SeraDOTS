// panels/EmojiPicker.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.globals
import qs.components

Panel {
    id: emojiPanel

    panelId:         "emoji"
    panelWidth:      Style.panelWidth
    panelHeight:     Style.panelHeight
    animationPreset: "slide"
    keyboardFocus:   WlrKeyboardFocus.OnDemand

    // ── Category definitions (for tabs) ──────────────────────────────────
    readonly property var categories: [
        { name: "Smileys",    icon: "😀" },
        { name: "Gestures",   icon: "👋" },
        { name: "Animals",    icon: "🐶" },
        { name: "Food",       icon: "🍎" },
        { name: "Travel",     icon: "✈️" },
        { name: "Objects",    icon: "💡" },
        { name: "Symbols",    icon: "❤️" },
        { name: "Activities", icon: "⚽" }
    ]

    // ── Flat emoji list with names/keywords for search ────────────────────
    // Each entry: { e: "emoji", n: "name", k: "keyword1 keyword2 ...", c: categoryIndex }
    readonly property var allEmojis: [
        // Smileys (c:0)
        {e:"😀",n:"grinning",k:"happy smile face",c:0},
        {e:"😃",n:"smiley",k:"happy smile eyes open",c:0},
        {e:"😄",n:"grin",k:"happy smile laugh",c:0},
        {e:"😁",n:"beaming",k:"happy grin teeth",c:0},
        {e:"😆",n:"laughing",k:"happy haha lol",c:0},
        {e:"😅",n:"sweat smile",k:"nervous laugh relief",c:0},
        {e:"🤣",n:"rofl",k:"rolling floor laugh funny",c:0},
        {e:"😂",n:"joy",k:"tears laugh cry funny lol",c:0},
        {e:"🙂",n:"slightly smiling",k:"smile happy",c:0},
        {e:"🙃",n:"upside down",k:"silly sarcasm",c:0},
        {e:"🫠",n:"melting",k:"dissolve nervous awkward",c:0},
        {e:"😉",n:"winking",k:"wink flirt joke",c:0},
        {e:"😊",n:"blush",k:"happy smile warm",c:0},
        {e:"😇",n:"innocent",k:"halo angel good",c:0},
        {e:"🥰",n:"smiling hearts",k:"love adore affection",c:0},
        {e:"😍",n:"heart eyes",k:"love beautiful amazing",c:0},
        {e:"🤩",n:"star struck",k:"wow amazing celebrity",c:0},
        {e:"😘",n:"kissing heart",k:"kiss love mwah",c:0},
        {e:"😋",n:"yum",k:"delicious food tasty tongue",c:0},
        {e:"😛",n:"tongue",k:"playful silly",c:0},
        {e:"😜",n:"winking tongue",k:"playful joke silly",c:0},
        {e:"🤪",n:"zany",k:"crazy silly wild",c:0},
        {e:"🤑",n:"money mouth",k:"rich money greedy",c:0},
        {e:"🤗",n:"hugging",k:"hug warm love",c:0},
        {e:"🤔",n:"thinking",k:"hmm ponder wonder",c:0},
        {e:"🤫",n:"shushing",k:"quiet secret hush",c:0},
        {e:"😐",n:"neutral",k:"meh blank expressionless",c:0},
        {e:"😑",n:"expressionless",k:"blank deadpan",c:0},
        {e:"😶",n:"no mouth",k:"silent speechless",c:0},
        {e:"😏",n:"smirk",k:"smug flirt",c:0},
        {e:"😒",n:"unamused",k:"whatever bored",c:0},
        {e:"🙄",n:"eye roll",k:"whatever annoyed",c:0},
        {e:"😬",n:"grimacing",k:"awkward nervous oops",c:0},
        {e:"😔",n:"pensive",k:"sad down thoughtful",c:0},
        {e:"😪",n:"sleepy",k:"tired sleep",c:0},
        {e:"🤤",n:"drooling",k:"hungry want drool",c:0},
        {e:"😴",n:"sleeping",k:"sleep tired zzz",c:0},
        {e:"😷",n:"mask",k:"sick ill covid mask",c:0},
        {e:"🤒",n:"sick thermometer",k:"ill fever cold",c:0},
        {e:"🤢",n:"nauseated",k:"sick gross disgust",c:0},
        {e:"🤮",n:"vomiting",k:"sick gross puke",c:0},
        {e:"🥵",n:"hot face",k:"hot heat sweating",c:0},
        {e:"🥶",n:"cold face",k:"cold freezing ice",c:0},
        {e:"🥴",n:"woozy",k:"drunk dizzy confused",c:0},
        {e:"🤯",n:"exploding head",k:"mind blown shocked",c:0},
        {e:"🤠",n:"cowboy",k:"yeehaw western hat",c:0},
        {e:"🥳",n:"partying",k:"party celebrate birthday",c:0},
        {e:"😎",n:"sunglasses",k:"cool awesome chill",c:0},
        {e:"🤓",n:"nerd",k:"glasses smart geek",c:0},
        {e:"🥺",n:"pleading",k:"please puppy eyes beg",c:0},
        {e:"😢",n:"crying",k:"sad tear cry",c:0},
        {e:"😭",n:"loudly crying",k:"cry sob sad",c:0},
        {e:"😱",n:"screaming",k:"scream horror scared",c:0},
        {e:"😤",n:"steam nose",k:"angry frustrated",c:0},
        {e:"😡",n:"pouting",k:"angry mad rage",c:0},
        {e:"😠",n:"angry",k:"mad furious rage",c:0},
        {e:"🤬",n:"cursing",k:"swearing angry symbols",c:0},
        {e:"😈",n:"smiling devil",k:"evil mischief",c:0},
        {e:"👿",n:"angry devil",k:"evil angry demon",c:0},
        {e:"💀",n:"skull",k:"dead death skeleton",c:0},
        {e:"☠️",n:"skull crossbones",k:"dead pirate danger",c:0},
        {e:"💩",n:"poop",k:"poop shit funny",c:0},
        {e:"🤡",n:"clown",k:"clown funny scary",c:0},
        {e:"👹",n:"ogre",k:"monster demon japanese",c:0},
        {e:"👺",n:"goblin",k:"monster red japanese",c:0},
        {e:"👻",n:"ghost",k:"ghost spooky halloween",c:0},
        {e:"👽",n:"alien",k:"alien space ufo",c:0},
        {e:"👾",n:"alien monster",k:"game pixel alien",c:0},
        {e:"🤖",n:"robot",k:"robot ai machine",c:0},
        // Gestures (c:1)
        {e:"👋",n:"waving hand",k:"wave hello bye",c:1},
        {e:"🤚",n:"raised back hand",k:"stop hand",c:1},
        {e:"✋",n:"raised hand",k:"stop high five",c:1},
        {e:"🖖",n:"vulcan salute",k:"spock star trek",c:1},
        {e:"👌",n:"ok hand",k:"ok perfect good",c:1},
        {e:"✌️",n:"victory hand",k:"peace v sign",c:1},
        {e:"🤞",n:"crossed fingers",k:"luck hope wish",c:1},
        {e:"🤟",n:"love you gesture",k:"rock love ily",c:1},
        {e:"🤘",n:"sign of horns",k:"rock metal music",c:1},
        {e:"🤙",n:"call me hand",k:"shaka hang loose call",c:1},
        {e:"👈",n:"pointing left",k:"left point direction",c:1},
        {e:"👉",n:"pointing right",k:"right point direction",c:1},
        {e:"👆",n:"pointing up",k:"up above this",c:1},
        {e:"🖕",n:"middle finger",k:"fuck rude offensive",c:1},
        {e:"👇",n:"pointing down",k:"down below this",c:1},
        {e:"👍",n:"thumbs up",k:"like approve yes good",c:1},
        {e:"👎",n:"thumbs down",k:"dislike no bad",c:1},
        {e:"✊",n:"raised fist",k:"fist power solidarity",c:1},
        {e:"👊",n:"oncoming fist",k:"punch fist bump",c:1},
        {e:"👏",n:"clapping",k:"clap applause bravo",c:1},
        {e:"🙌",n:"raising hands",k:"celebrate hooray yes",c:1},
        {e:"🫶",n:"heart hands",k:"love heart hands",c:1},
        {e:"🤝",n:"handshake",k:"deal agree meeting",c:1},
        {e:"🙏",n:"folded hands",k:"pray please thank namaste",c:1},
        {e:"💪",n:"flexed bicep",k:"strong muscle gym",c:1},
        {e:"👀",n:"eyes",k:"look see watching",c:1},
        {e:"👅",n:"tongue",k:"tongue lick taste",c:1},
        {e:"👄",n:"mouth lips",k:"lips kiss speak",c:1},
        // Animals (c:2)
        {e:"🐶",n:"dog",k:"dog puppy pet",c:2},
        {e:"🐱",n:"cat",k:"cat kitten pet",c:2},
        {e:"🐭",n:"mouse",k:"mouse rat rodent",c:2},
        {e:"🐹",n:"hamster",k:"hamster cute pet",c:2},
        {e:"🐰",n:"rabbit",k:"bunny rabbit cute",c:2},
        {e:"🦊",n:"fox",k:"fox cunning sly",c:2},
        {e:"🐻",n:"bear",k:"bear brown",c:2},
        {e:"🐼",n:"panda",k:"panda bear china",c:2},
        {e:"🐨",n:"koala",k:"koala australia marsupial",c:2},
        {e:"🐯",n:"tiger",k:"tiger cat stripe",c:2},
        {e:"🦁",n:"lion",k:"lion king roar",c:2},
        {e:"🐮",n:"cow",k:"cow moo farm",c:2},
        {e:"🐷",n:"pig",k:"pig oink farm",c:2},
        {e:"🐸",n:"frog",k:"frog green ribbit",c:2},
        {e:"🐵",n:"monkey",k:"monkey ape banana",c:2},
        {e:"🙈",n:"see no evil",k:"monkey cover eyes",c:2},
        {e:"🙉",n:"hear no evil",k:"monkey cover ears",c:2},
        {e:"🙊",n:"speak no evil",k:"monkey cover mouth",c:2},
        {e:"🐔",n:"chicken",k:"chicken bird farm cluck",c:2},
        {e:"🐧",n:"penguin",k:"penguin arctic bird",c:2},
        {e:"🦆",n:"duck",k:"duck quack bird",c:2},
        {e:"🦅",n:"eagle",k:"eagle bird raptor",c:2},
        {e:"🦉",n:"owl",k:"owl wise night bird",c:2},
        {e:"🦋",n:"butterfly",k:"butterfly insect colorful",c:2},
        {e:"🐌",n:"snail",k:"snail slow",c:2},
        {e:"🐛",n:"bug",k:"caterpillar worm bug",c:2},
        {e:"🐞",n:"ladybug",k:"ladybug insect",c:2},
        {e:"🕷️",n:"spider",k:"spider web scary",c:2},
        {e:"🐢",n:"turtle",k:"turtle slow reptile",c:2},
        {e:"🐍",n:"snake",k:"snake reptile slither",c:2},
        {e:"🦎",n:"lizard",k:"lizard reptile gecko",c:2},
        {e:"🐙",n:"octopus",k:"octopus sea tentacle",c:2},
        {e:"🦑",n:"squid",k:"squid sea ink",c:2},
        {e:"🦀",n:"crab",k:"crab red sea",c:2},
        {e:"🐡",n:"blowfish",k:"fish puffer sea",c:2},
        {e:"🐠",n:"tropical fish",k:"fish colorful sea",c:2},
        {e:"🐟",n:"fish",k:"fish sea swim",c:2},
        {e:"🐬",n:"dolphin",k:"dolphin sea smart",c:2},
        {e:"🐳",n:"whale",k:"whale big sea",c:2},
        {e:"🦈",n:"shark",k:"shark danger sea",c:2},
        {e:"🐊",n:"crocodile",k:"crocodile alligator reptile",c:2},
        {e:"🦒",n:"giraffe",k:"giraffe tall neck",c:2},
        {e:"🐘",n:"elephant",k:"elephant big memory",c:2},
        {e:"🦛",n:"hippopotamus",k:"hippo big africa",c:2},
        {e:"🦏",n:"rhinoceros",k:"rhino horn africa",c:2},
        {e:"🐪",n:"camel",k:"camel desert hump",c:2},
        {e:"🦓",n:"zebra",k:"zebra stripe africa",c:2},
        {e:"🐕",n:"dog",k:"dog pet loyal",c:2},
        {e:"🐈",n:"cat",k:"cat pet meow",c:2},
        {e:"🐓",n:"rooster",k:"rooster cock morning",c:2},
        {e:"🦃",n:"turkey",k:"turkey thanksgiving bird",c:2},
        {e:"🦚",n:"peacock",k:"peacock colorful proud",c:2},
        {e:"🦜",n:"parrot",k:"parrot colorful talk bird",c:2},
        {e:"🦢",n:"swan",k:"swan white elegant bird",c:2},
        // Food (c:3)
        {e:"🍎",n:"apple",k:"apple red fruit",c:3},
        {e:"🍊",n:"tangerine",k:"orange citrus fruit",c:3},
        {e:"🍋",n:"lemon",k:"lemon sour citrus",c:3},
        {e:"🍌",n:"banana",k:"banana yellow fruit",c:3},
        {e:"🍉",n:"watermelon",k:"watermelon summer fruit",c:3},
        {e:"🍇",n:"grapes",k:"grapes purple fruit wine",c:3},
        {e:"🍓",n:"strawberry",k:"strawberry red fruit",c:3},
        {e:"🫐",n:"blueberries",k:"blueberry fruit",c:3},
        {e:"🍒",n:"cherries",k:"cherry red fruit",c:3},
        {e:"🍑",n:"peach",k:"peach fruit butt",c:3},
        {e:"🥭",n:"mango",k:"mango tropical fruit",c:3},
        {e:"🍍",n:"pineapple",k:"pineapple tropical fruit",c:3},
        {e:"🥥",n:"coconut",k:"coconut tropical",c:3},
        {e:"🥝",n:"kiwi",k:"kiwi green fruit",c:3},
        {e:"🍅",n:"tomato",k:"tomato red vegetable",c:3},
        {e:"🍆",n:"eggplant",k:"eggplant aubergine vegetable",c:3},
        {e:"🥑",n:"avocado",k:"avocado green healthy",c:3},
        {e:"🥦",n:"broccoli",k:"broccoli green vegetable",c:3},
        {e:"🌽",n:"corn",k:"corn maize vegetable",c:3},
        {e:"🌶️",n:"pepper",k:"chili hot spicy",c:3},
        {e:"🧄",n:"garlic",k:"garlic flavor cooking",c:3},
        {e:"🥕",n:"carrot",k:"carrot orange vegetable",c:3},
        {e:"🥔",n:"potato",k:"potato vegetable",c:3},
        {e:"🍞",n:"bread",k:"bread loaf bake",c:3},
        {e:"🥐",n:"croissant",k:"croissant french pastry",c:3},
        {e:"🥨",n:"pretzel",k:"pretzel salty snack",c:3},
        {e:"🧀",n:"cheese",k:"cheese dairy",c:3},
        {e:"🥚",n:"egg",k:"egg breakfast",c:3},
        {e:"🍳",n:"cooking",k:"fry pan egg breakfast",c:3},
        {e:"🥞",n:"pancakes",k:"pancake breakfast stack",c:3},
        {e:"🥓",n:"bacon",k:"bacon meat breakfast",c:3},
        {e:"🥩",n:"meat",k:"steak beef meat",c:3},
        {e:"🍗",n:"chicken leg",k:"chicken drumstick meat",c:3},
        {e:"🌮",n:"taco",k:"taco mexican food",c:3},
        {e:"🌯",n:"burrito",k:"burrito wrap mexican",c:3},
        {e:"🍕",n:"pizza",k:"pizza cheese italian",c:3},
        {e:"🍔",n:"burger",k:"burger hamburger fast food",c:3},
        {e:"🍟",n:"fries",k:"fries chips fast food",c:3},
        {e:"🌭",n:"hot dog",k:"hotdog sausage",c:3},
        {e:"🍜",n:"noodles",k:"ramen noodle soup",c:3},
        {e:"🍝",n:"spaghetti",k:"pasta italian noodle",c:3},
        {e:"🍣",n:"sushi",k:"sushi japanese fish",c:3},
        {e:"🍱",n:"bento",k:"bento box japanese",c:3},
        {e:"🍦",n:"ice cream",k:"icecream soft serve dessert",c:3},
        {e:"🍧",n:"shaved ice",k:"icecream dessert",c:3},
        {e:"🍨",n:"ice cream",k:"icecream dessert",c:3},
        {e:"🍩",n:"donut",k:"donut doughnut sweet",c:3},
        {e:"🍪",n:"cookie",k:"cookie biscuit sweet",c:3},
        {e:"🎂",n:"birthday cake",k:"cake birthday party",c:3},
        {e:"🍰",n:"cake",k:"cake slice dessert",c:3},
        {e:"🧁",n:"cupcake",k:"cupcake sweet dessert",c:3},
        {e:"🍫",n:"chocolate",k:"chocolate sweet candy",c:3},
        {e:"🍬",n:"candy",k:"candy sweet lolly",c:3},
        {e:"🍭",n:"lollipop",k:"lollipop candy sweet",c:3},
        {e:"🍿",n:"popcorn",k:"popcorn movie snack",c:3},
        {e:"☕",n:"coffee",k:"coffee hot drink cafe",c:3},
        {e:"🍵",n:"tea",k:"tea hot drink",c:3},
        {e:"🧃",n:"juice",k:"juice box drink",c:3},
        {e:"🥤",n:"cup straw",k:"soda drink juice",c:3},
        {e:"🧋",n:"bubble tea",k:"boba bubble tea drink",c:3},
        {e:"🍺",n:"beer",k:"beer drink alcohol cheers",c:3},
        {e:"🍻",n:"clinking beers",k:"beer cheers drink",c:3},
        {e:"🥂",n:"champagne",k:"champagne celebrate toast",c:3},
        {e:"🍷",n:"wine",k:"wine red drink alcohol",c:3},
        {e:"🍸",n:"cocktail",k:"cocktail martini drink",c:3},
        {e:"🍹",n:"tropical drink",k:"cocktail holiday drink",c:3},
        {e:"🥃",n:"whiskey",k:"whisky glass drink",c:3},
        // Travel (c:4)
        {e:"🚗",n:"car",k:"car drive vehicle",c:4},
        {e:"🚕",n:"taxi",k:"taxi cab yellow",c:4},
        {e:"🚌",n:"bus",k:"bus public transport",c:4},
        {e:"🚎",n:"trolleybus",k:"trolley bus",c:4},
        {e:"🏎️",n:"racing car",k:"race car formula speed",c:4},
        {e:"🚑",n:"ambulance",k:"ambulance emergency hospital",c:4},
        {e:"🚒",n:"fire engine",k:"fire truck emergency",c:4},
        {e:"🚲",n:"bicycle",k:"bike cycle pedal",c:4},
        {e:"🛴",n:"scooter",k:"scooter kick ride",c:4},
        {e:"🛹",n:"skateboard",k:"skate board ride",c:4},
        {e:"⛽",n:"fuel pump",k:"gas petrol fuel",c:4},
        {e:"⚓",n:"anchor",k:"anchor ship sea",c:4},
        {e:"⛵",n:"sailboat",k:"sail boat sea",c:4},
        {e:"🚤",n:"speedboat",k:"boat speed water",c:4},
        {e:"🚢",n:"ship",k:"ship cruise ocean",c:4},
        {e:"✈️",n:"airplane",k:"plane fly travel air",c:4},
        {e:"🚀",n:"rocket",k:"rocket space launch",c:4},
        {e:"🛸",n:"ufo",k:"ufo alien space flying saucer",c:4},
        {e:"🚁",n:"helicopter",k:"helicopter fly",c:4},
        {e:"🌍",n:"earth africa",k:"world globe earth",c:4},
        {e:"🌎",n:"earth americas",k:"world globe earth",c:4},
        {e:"🌏",n:"earth asia",k:"world globe earth",c:4},
        {e:"🗺️",n:"map",k:"map world travel",c:4},
        {e:"🧭",n:"compass",k:"compass direction navigate",c:4},
        {e:"🏔️",n:"mountain",k:"mountain peak snow",c:4},
        {e:"🌋",n:"volcano",k:"volcano eruption mountain",c:4},
        {e:"🏕️",n:"camping",k:"camp tent outdoor",c:4},
        {e:"🏖️",n:"beach",k:"beach sand summer",c:4},
        {e:"🏝️",n:"island",k:"island tropical beach",c:4},
        {e:"🏠",n:"house",k:"house home building",c:4},
        {e:"🏢",n:"office",k:"building office city",c:4},
        {e:"🏰",n:"castle",k:"castle palace medieval",c:4},
        {e:"🗼",n:"tokyo tower",k:"tokyo tower japan",c:4},
        {e:"🗽",n:"statue liberty",k:"new york usa statue",c:4},
        {e:"🎡",n:"ferris wheel",k:"ferris wheel amusement fair",c:4},
        {e:"🎢",n:"roller coaster",k:"roller coaster ride fun",c:4},
        // Objects (c:5)
        {e:"📱",n:"phone",k:"phone mobile iphone",c:5},
        {e:"💻",n:"laptop",k:"laptop computer macbook",c:5},
        {e:"🖥️",n:"desktop",k:"desktop computer screen",c:5},
        {e:"⌨️",n:"keyboard",k:"keyboard type computer",c:5},
        {e:"🖱️",n:"mouse",k:"mouse computer click",c:5},
        {e:"📷",n:"camera",k:"camera photo picture",c:5},
        {e:"📹",n:"video camera",k:"video camera film",c:5},
        {e:"📺",n:"tv",k:"television tv screen",c:5},
        {e:"📻",n:"radio",k:"radio music broadcast",c:5},
        {e:"⏰",n:"alarm clock",k:"alarm clock time",c:5},
        {e:"📡",n:"satellite",k:"satellite dish signal",c:5},
        {e:"🔋",n:"battery",k:"battery power charge",c:5},
        {e:"🔌",n:"plug",k:"plug power electric",c:5},
        {e:"💡",n:"bulb",k:"idea light bulb",c:5},
        {e:"🔦",n:"flashlight",k:"torch flashlight light",c:5},
        {e:"🕯️",n:"candle",k:"candle light romantic",c:5},
        {e:"🧱",n:"brick",k:"brick wall build",c:5},
        {e:"🔧",n:"wrench",k:"wrench tool fix",c:5},
        {e:"🔩",n:"bolt",k:"nut bolt screw",c:5},
        {e:"⚙️",n:"gear",k:"gear settings cog",c:5},
        {e:"🔨",n:"hammer",k:"hammer tool build",c:5},
        {e:"⚔️",n:"swords",k:"swords fight battle",c:5},
        {e:"🛡️",n:"shield",k:"shield protect defense",c:5},
        {e:"🔑",n:"key",k:"key lock open",c:5},
        {e:"🗝️",n:"old key",k:"key lock old",c:5},
        {e:"🔐",n:"locked key",k:"locked secure",c:5},
        {e:"🔒",n:"locked",k:"lock secure closed",c:5},
        {e:"🔓",n:"unlocked",k:"unlock open",c:5},
        {e:"🔮",n:"crystal ball",k:"magic predict future",c:5},
        {e:"🧸",n:"teddy bear",k:"bear toy stuffed",c:5},
        {e:"🪆",n:"nesting doll",k:"matryoshka doll russian",c:5},
        {e:"🖼️",n:"picture",k:"art picture frame painting",c:5},
        {e:"💎",n:"gem",k:"diamond gem jewel",c:5},
        {e:"💍",n:"ring",k:"ring wedding engagement",c:5},
        {e:"👑",n:"crown",k:"crown king queen royal",c:5},
        {e:"🎩",n:"top hat",k:"hat formal magic",c:5},
        {e:"👒",n:"hat",k:"hat sun brim",c:5},
        {e:"🎓",n:"graduation",k:"graduate school university diploma",c:5},
        {e:"🌂",n:"umbrella",k:"umbrella rain",c:5},
        {e:"🧲",n:"magnet",k:"magnet attract pull",c:5},
        {e:"🪞",n:"mirror",k:"mirror reflect vanity",c:5},
        {e:"🛋️",n:"couch",k:"sofa couch sit lounge",c:5},
        {e:"🚿",n:"shower",k:"shower wash clean",c:5},
        {e:"🛁",n:"bath",k:"bath tub relax",c:5},
        {e:"🪴",n:"plant",k:"plant pot indoor",c:5},
        {e:"📦",n:"box",k:"box package shipping",c:5},
        {e:"📫",n:"mailbox",k:"mail post letter",c:5},
        {e:"🗑️",n:"trash",k:"bin trash delete",c:5},
        {e:"💼",n:"briefcase",k:"work bag office business",c:5},
        {e:"🎒",n:"backpack",k:"bag school travel",c:5},
        // Symbols (c:6)
        {e:"❤️",n:"red heart",k:"love heart red",c:6},
        {e:"🧡",n:"orange heart",k:"love heart orange",c:6},
        {e:"💛",n:"yellow heart",k:"love heart yellow",c:6},
        {e:"💚",n:"green heart",k:"love heart green",c:6},
        {e:"💙",n:"blue heart",k:"love heart blue",c:6},
        {e:"💜",n:"purple heart",k:"love heart purple",c:6},
        {e:"🖤",n:"black heart",k:"love heart black dark",c:6},
        {e:"🤍",n:"white heart",k:"love heart white",c:6},
        {e:"💔",n:"broken heart",k:"heartbreak sad",c:6},
        {e:"❤️‍🔥",n:"heart fire",k:"love passion burning",c:6},
        {e:"💕",n:"two hearts",k:"love hearts",c:6},
        {e:"💯",n:"hundred",k:"100 perfect score",c:6},
        {e:"✅",n:"check mark",k:"tick check yes done",c:6},
        {e:"❌",n:"cross",k:"x no wrong cancel",c:6},
        {e:"⭕",n:"circle",k:"circle ring o",c:6},
        {e:"🔴",n:"red circle",k:"red dot circle",c:6},
        {e:"🟠",n:"orange circle",k:"orange dot circle",c:6},
        {e:"🟡",n:"yellow circle",k:"yellow dot circle",c:6},
        {e:"🟢",n:"green circle",k:"green dot circle",c:6},
        {e:"🔵",n:"blue circle",k:"blue dot circle",c:6},
        {e:"🟣",n:"purple circle",k:"purple dot circle",c:6},
        {e:"⚫",n:"black circle",k:"black dot circle",c:6},
        {e:"⚪",n:"white circle",k:"white dot circle",c:6},
        {e:"🔶",n:"orange diamond",k:"orange shape",c:6},
        {e:"🔷",n:"blue diamond",k:"blue shape",c:6},
        {e:"⭐",n:"star",k:"star yellow favourite",c:6},
        {e:"🌟",n:"glowing star",k:"star shine bright",c:6},
        {e:"💫",n:"dizzy",k:"star spin sparkle",c:6},
        {e:"✨",n:"sparkles",k:"sparkle magic shine",c:6},
        {e:"🎉",n:"party",k:"party celebrate confetti",c:6},
        {e:"🎊",n:"confetti",k:"confetti party celebrate",c:6},
        {e:"🎈",n:"balloon",k:"balloon party birthday",c:6},
        {e:"🔔",n:"bell",k:"bell notification ring",c:6},
        {e:"🔕",n:"bell off",k:"mute silent notification",c:6},
        {e:"🔇",n:"muted",k:"mute silent speaker",c:6},
        {e:"🔊",n:"loud",k:"speaker loud sound",c:6},
        {e:"📢",n:"megaphone",k:"announce loud broadcast",c:6},
        {e:"💬",n:"speech bubble",k:"chat message speech",c:6},
        {e:"💭",n:"thought bubble",k:"think thought",c:6},
        {e:"❓",n:"question",k:"question help what",c:6},
        {e:"❗",n:"exclamation",k:"exclaim important alert",c:6},
        {e:"⚠️",n:"warning",k:"warning caution alert",c:6},
        {e:"🚫",n:"prohibited",k:"no ban forbidden",c:6},
        {e:"♻️",n:"recycle",k:"recycle green environment",c:6},
        {e:"🆕",n:"new",k:"new badge label",c:6},
        {e:"🔝",n:"top",k:"top up arrow",c:6},
        {e:"🔜",n:"soon",k:"soon arrow",c:6},
        {e:"🔛",n:"on",k:"on button",c:6},
        {e:"🔚",n:"end",k:"end back arrow",c:6},
        {e:"▶️",n:"play",k:"play button start",c:6},
        {e:"⏸️",n:"pause",k:"pause stop button",c:6},
        {e:"⏹️",n:"stop",k:"stop square button",c:6},
        {e:"⏭️",n:"skip",k:"skip next fast forward",c:6},
        {e:"🔀",n:"shuffle",k:"shuffle random music",c:6},
        {e:"🔁",n:"repeat",k:"repeat loop",c:6},
        // Activities (c:7)
        {e:"⚽",n:"soccer",k:"football soccer sport",c:7},
        {e:"🏀",n:"basketball",k:"basketball sport",c:7},
        {e:"🏈",n:"football",k:"american football sport",c:7},
        {e:"⚾",n:"baseball",k:"baseball sport",c:7},
        {e:"🎾",n:"tennis",k:"tennis sport racket",c:7},
        {e:"🏐",n:"volleyball",k:"volleyball sport",c:7},
        {e:"🏉",n:"rugby",k:"rugby sport ball",c:7},
        {e:"🎱",n:"billiards",k:"pool billiard ball 8ball",c:7},
        {e:"🏓",n:"ping pong",k:"table tennis ping pong sport",c:7},
        {e:"🏸",n:"badminton",k:"badminton sport shuttlecock",c:7},
        {e:"🥊",n:"boxing glove",k:"boxing fight glove",c:7},
        {e:"🥋",n:"martial arts",k:"karate judo martial arts",c:7},
        {e:"⛳",n:"golf",k:"golf flag sport",c:7},
        {e:"🎯",n:"dart",k:"dart bullseye target",c:7},
        {e:"🎮",n:"game controller",k:"game controller play",c:7},
        {e:"🕹️",n:"joystick",k:"joystick arcade game",c:7},
        {e:"🎲",n:"dice",k:"dice game random",c:7},
        {e:"🧩",n:"puzzle",k:"puzzle piece jigsaw",c:7},
        {e:"🃏",n:"joker",k:"card joker game",c:7},
        {e:"♟️",n:"chess",k:"chess pawn game",c:7},
        {e:"🎭",n:"theater",k:"theater drama mask",c:7},
        {e:"🎨",n:"art",k:"art painting palette",c:7},
        {e:"🎬",n:"clapper",k:"film movie clapper action",c:7},
        {e:"🎤",n:"microphone",k:"mic sing karaoke",c:7},
        {e:"🎧",n:"headphones",k:"headphones music listen",c:7},
        {e:"🎼",n:"music score",k:"music notes sheet",c:7},
        {e:"🎹",n:"piano",k:"piano keys music instrument",c:7},
        {e:"🥁",n:"drum",k:"drum beat music percussion",c:7},
        {e:"🎷",n:"saxophone",k:"sax jazz music",c:7},
        {e:"🎺",n:"trumpet",k:"trumpet brass music",c:7},
        {e:"🎸",n:"guitar",k:"guitar rock music",c:7},
        {e:"🎻",n:"violin",k:"violin classical music",c:7},
        {e:"🎙️",n:"studio mic",k:"podcast studio record",c:7},
        {e:"📺",n:"television",k:"tv watch show",c:7},
        {e:"🏆",n:"trophy",k:"trophy win champion",c:7},
        {e:"🥇",n:"gold medal",k:"first gold winner",c:7},
        {e:"🥈",n:"silver medal",k:"second silver",c:7},
        {e:"🥉",n:"bronze medal",k:"third bronze",c:7},
        {e:"🏅",n:"medal",k:"medal award sport",c:7},
        {e:"🎖️",n:"military medal",k:"medal honor award",c:7},
        {e:"🎗️",n:"ribbon",k:"ribbon awareness cause",c:7},
        {e:"🎫",n:"ticket",k:"ticket event pass",c:7},
        {e:"🎪",n:"circus",k:"circus tent fun",c:7},
        {e:"🤹",n:"juggling",k:"juggle circus perform",c:7},
        {e:"🎠",n:"carousel",k:"carousel horse fun fair",c:7},
        {e:"🎡",n:"ferris wheel",k:"ferris wheel fair",c:7},
        {e:"🎢",n:"roller coaster",k:"roller coaster ride",c:7},
        {e:"🎰",n:"slot machine",k:"casino slot gamble",c:7},
        {e:"🚴",n:"cycling",k:"bike cycle sport",c:7},
        {e:"🏊",n:"swimming",k:"swim pool sport",c:7},
        {e:"🏋️",n:"weightlifting",k:"gym weights lift sport",c:7},
        {e:"🤸",n:"gymnastics",k:"cartwheel gymnastics sport",c:7},
        {e:"🧘",n:"yoga",k:"yoga meditate relax",c:7},
        {e:"🏄",n:"surfing",k:"surf wave sport",c:7},
        {e:"🧗",n:"climbing",k:"climb rock sport",c:7},
        {e:"🤾",n:"handball",k:"handball throw sport",c:7},
        {e:"🏇",n:"horse racing",k:"horse race jockey sport",c:7},
        {e:"⛷️",n:"skiing",k:"ski snow sport",c:7},
        {e:"🏂",n:"snowboarding",k:"snowboard snow sport",c:7}
    ]

    // ── Panel content ─────────────────────────────────────────────────────
    Item {
        id: pickerRoot
        anchors.fill: parent

        property string searchQuery:   ""
        property int    activeCategory: 0

        // Reset state when panel opens/closes
        Connections {
            target: emojiPanel
            function onShowPanelChanged() {
                if (emojiPanel.showPanel) {
                    searchInput.text          = ""
                    pickerRoot.searchQuery    = ""
                    pickerRoot.activeCategory = 0
                    focusTimer.restart()
                } else {
                    searchInput.focus = false
                }
            }
        }

        Timer {
            id: focusTimer
            interval: 15
            onTriggered: searchInput.forceActiveFocus()
        }

        // Active emoji list — keyword-filtered or current category
        property var activeEmojis: {
            let q = searchQuery.trim().toLowerCase()
            if (q) {
                return emojiPanel.allEmojis.filter(entry => {
                    return entry.n.includes(q) || entry.k.includes(q)
                }).map(entry => entry.e)
            }
            return emojiPanel.allEmojis
                .filter(entry => entry.c === activeCategory)
                .map(entry => entry.e)
        }

        function copyEmoji(emoji) {
            Quickshell.execDetached({ command: ["sh", "-c",
                "printf '%s' '" + emoji + "' | wl-copy && notify-send -u low -h string:x-canonical-private-synchronous:emoji 'Emoji' 'Copied " + emoji + " to clipboard'"]
            })
            EventBus.togglePanel("emoji", null)
        }

        Column {
            anchors.fill: parent
            spacing:      10

            // ── Search bar ────────────────────────────────────────────────
            Rectangle {
                width:  parent.width
                height: 36
                color:  Colors.color0
                border.color: Colors.color8
                border.width: 1
                radius: 5

                Row {
                    anchors.fill:    parent
                    anchors.margins: 8
                    spacing:         6

                    Text {
                        text:                  "󰍉"
                        font.family:           Style.barFont
                        font.pixelSize:        16
                        color:                 Colors.color8
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextInput {
                        id:     searchInput
                        width:  parent.width - 28
                        height: parent.height
                        verticalAlignment: TextInput.AlignVCenter
                        color:       Colors.foreground
                        font.family: Style.barFont
                        font.pixelSize: 14
                        focus: true

                        onTextEdited: pickerRoot.searchQuery = text

                        Text {
                            text:    "Search emoji…"
                            color:   Colors.color8
                            visible: !parent.text
                            font.family:    Style.barFont
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Keys.onEscapePressed: EventBus.togglePanel("emoji", null)
                    }
                }
            }

            // ── Category tabs (hidden during search) ──────────────────────
            Item {
                width:   parent.width
                height:  pickerRoot.searchQuery.trim() ? 0 : 36
                clip:    true
                visible: !pickerRoot.searchQuery.trim()

                Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                ListView {
                    id:            categoryTabs
                    anchors.fill:  parent
                    orientation:   ListView.Horizontal
                    spacing:       4
                    clip:          true
                    model:         emojiPanel.categories

                    delegate: Rectangle {
                        required property var   modelData
                        required property int   index
                        property bool isActive: index === pickerRoot.activeCategory

                        width:  36
                        height: 36
                        radius: 5
                        color:  isActive ? Colors.color5 : (tabMouse.containsMouse ? Colors.color0 : "transparent")

                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text:             modelData.icon
                            font.pixelSize:   20
                        }

                        MouseArea {
                            id:           tabMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    pickerRoot.activeCategory = index
                        }
                    }
                }
            }

            // Category label
            Text {
                visible:        !pickerRoot.searchQuery.trim()
                text:           emojiPanel.categories[pickerRoot.activeCategory].name
                color:          Colors.color8
                font.family:    Style.barFont
                font.pixelSize: 11

                leftPadding:    2
            }

            // ── Emoji grid ────────────────────────────────────────────────
            GridView {
                id:        emojiGrid
                width:     parent.width
                height:    parent.height - (pickerRoot.searchQuery.trim() ? 36 + 10 : 36 + 36 + 10 + 18 + 10 + 10)
                clip:      true
                cellWidth:  Math.floor(width / cols)
                cellHeight: cellWidth
                model:      pickerRoot.activeEmojis

                // Number of columns — fit as many as look good
                readonly property int cols: Math.floor(width / 38)

                // Smooth scroll
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                // Reset scroll on category change
                onModelChanged: positionViewAtBeginning()

                delegate: Item {
                    required property var modelData
                    required property int index

                    width:  emojiGrid.cellWidth
                    height: emojiGrid.cellHeight

                    Rectangle {
                        anchors.centerIn: parent
                        width:  emojiGrid.cellWidth - 4
                        height: emojiGrid.cellHeight - 4
                        radius: 5
                        color:  emojiMouse.containsMouse ? Colors.color5 : "transparent"

                        Behavior on color { ColorAnimation { duration: 80 } }

                        Text {
                            anchors.centerIn: parent
                            text:             modelData
                            font.pixelSize:   emojiGrid.cellWidth * 0.55
                        }

                        MouseArea {
                            id:          emojiMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    pickerRoot.copyEmoji(modelData)
                        }
                    }
                }
            }
        }
    }
}
