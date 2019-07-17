# Fujifilm Camera Profiles

This is a set of four camera profiles for use with raw images from digital cameras. They are made to match the film look profiles avalable in adobe camera raw / lightroom for fuji X-cameras.

The Film Stocks are:
* Provia
* Velvia
* Astia
* Classic Chrome

## How to Use

1. [Download the latest Archive at the Releases Page](https://github.com/lichtzeichner/FujifilmCameraProfiles/releases)
1. Extract the archive
1. Locate your Camera
1. Import the .dcp Files into Lightroom Classic and / or Lightroom CC.

----
## Technical Details


### Script to auto-generate profiles

The `generate-profiles.ps1` script reads the "Adobe Standard.dcp" profiles for all supported cameras from Adobe Lighroom Classic and automatically generates .dcp profiles matching that camera into the `dcpout` folder.

You may need to execute `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned` in a powershell with administrator permissions. (See also [Microsoft Documentation](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6)).

The script relies on [dcptool](http://dcptool.sourceforge.net/Introduction.html) to convert between dcp and xml. You need to provide a valid path to dcptool.exe using the `-dcptool` parameter

Example:

    .\generate-profiles.ps1 -dcptool "C:\path\to\dcptool\dcptool.exe 

### Profile Technology

The profiles use a LookTable and ToneCuve.
Dng profiles based on adobe standard are included as examples

Included for each film stock are:
* xml text file containing the LookTable and ToneCuve for dcp profiles
* xml and dcp profiles for the fuji xt-1 and panasonic gh3
* cube lut
* the cube lut and csv tables can be used with adobe's look profiles (xmp preset)

To manually make a profile for a different camera: 
* take an existing profile for that camera
* convert it to xml using dcptool
* replace the `<LookTable>` and `<ToneCuve>` xml tags with the ones from the film look text file
* `<DefaultBlackRender>` should be set to `1`
* `<ProfileLookTableEncoding>` should be set to `1`
* change `<ProfileName>`
* convert back to dcp

### Licencing

#### Script

Copyright (c) 2019, Jan Lorenz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

#### Profiles

These profiles are licenced as [cc-by-nc-sa 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
This means you may modify, make derivitives, or distribute them, eg; for another camera make and model. But you must attribute this source, share with same licence, and not sell them.

All Photographs produced with these profiles are entirely your own work, and not derivitives. The licence applies only to the profiles.

The Trademarks "Fujifilm", "Provia", "Velvia", "Astia", and "Adobe" are used for identification puposes only. No software from Fujifilm or Adobe are contained in this repository except for the included adobe standard camera profiles.
