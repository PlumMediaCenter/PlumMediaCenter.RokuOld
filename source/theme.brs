'
' Sets the theme of the application
'
sub SetTheme()
    'these are the standard values used throughout the theme. Some of the different pages need to have the values re-set to override
    'the defaults, so rather than changing the values twise, set the once here and reference them by value
    overhangSliceHD =  "pkg:/images/overhang_hd.png"
    overhangSliceSD =  "pkg:/images/overhang_sd.png"
    greyBackgroundColor = "#363636"
    GridScreenOverhangHeightHD = "69"
    GridScreenOverhangHeightSD = "49"

    'dark color pattern
    charcoal = "#293647"
    lime = "#c2cc4f"
    lightGrey = "#d6d1e8"
    pink = "#b93976"
    purple = "#361f6d"
    teal = "#127aa1"


    'light color pattern
    lightBlue = "#dbf2fa"
    solidBlue = "#7ddcf0"
    lavender = "#95669c"
    deepPurple = "#553588"
    tanColor = "#f0bd7e"
    pink = "#fff3d9"

    'apply the theme
    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")
    theme.BackgroundColor = greyBackgroundColor
    'the unselected text color in the search screen
    theme.ButtonMenuNormalText  = "#CCCCCC"
    'can only use a greyscale for the gridscreen background color
    theme.GridScreenBackgroundColor = greyBackgroundColor
    theme.OverhangSliceHD = overhangSliceHD
    theme.OverhangSliceSD = overhangSliceSD
    theme.GridScreenOverhangSliceHD = overhangSliceHD
    theme.GridScreenOverhangSliceSD = overhangSliceSD
    theme.GridScreenOverhangHeightHD = GridScreenOverhangHeightHD
    theme.GridScreenOverhangHeightSD = GridScreenOverhangHeightSD
    app.SetTheme(theme)
end sub