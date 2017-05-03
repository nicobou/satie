# Ambisonic Toolkit Kernels

A set of Finite Impulse Response (FIR) filter kernels for use by
convolution-based encoders and decoders.

### Features

*  Sample Rates: 44100, 48000, 88200, 96000, 176400, 192000
*  Full band: DC to Nyquist
*  Phase Referenced: W, linear phase
*  Constant delay: Predictable delay dependent on kernel size
*  Channel Order: Gerzon / Furse-Malham, aka, Classic first-order (FOA)
*  Normalization: MaxN, aka, Classic first-order (FOA)

The ATK's FIR filter kernels are designed to support a variety of useful
_encoding_ and _decoding_ strategies. Encoding means, converting from some other
signal format, e.g., _monophonic_ or _stereophonic_, to Ambisonic B-format.
Decoding means converting from Ambisonic B-format.

All kernels are constructed so that the zero order harmonic, W, is linear phase.
This gives all _encoder_ and _decoder_ designs a constant delay in samples of:

```
delay = (kernel_size - 1) / 2
```

The soundfield's pressure component is delayed by `delay`, and the phase
response of the higher order harmonics then referenced (offset) to preserve
the required relationships. The result is, all kernels of the same `kernel_size`
will produce a resulting signal delayed by the same number of samples.

#### Encoders
*   SuperStereo - Classic
    [Ambisonic Super Stereo](https://en.wikipedia.org/wiki/Ambisonic_UHJ_format#Super_stereo)
    encoding. Converts standard two channel _stereo_ to _pantophonic_
    (Horizontal-Only) B-format by wrapping the input across a wide frontal
    stage.

    __Note:__ We strongly advise using this encoder as the default _stereo_
    encoder.

*   UHJ - Classic
    [Ambisonic UHJ format](https://en.wikipedia.org/wiki/Ambisonic_UHJ_format)
    encoding. Converts _stereo_ compatible two channel Ambisonic UHJ format to
    _pantophonic_ (Horizontal-Only) B-format. Shelf filtering optimized for
    dual-band psycho-acoustic decoding is included for convenience.

*   Spectral Spreading - The frequency spreading technique encodes a
    _monophonic_ (single channel) input into B-format by smoothly rotating the
    signal across the soundfield sphere, by frequency. The spectrum is
    decomposed and then wrapped as planewaves.

*   Diffuse Field - Encodes a _monophonic_ (single channel) input into B-format
    through frequency dependent phase diffusion. Equivalent to applying the
    spatial characteristics of a
    [diffuse soundfield](http://www.acoustic-glossary.co.uk/sound-fields.htm#diffuse)
    to the input sound. In the natural world, diffuse soundfields are found as
    the very late, immersive part of reverberation.

#### Decoders
*   UHJ - Classic
    [Ambisonic UHJ format](https://en.wikipedia.org/wiki/Ambisonic_UHJ_format)
    decoding. Converts B-format to _stereo_ compatible two channel Ambisonic
    UHJ format.

    __Note:__ We strongly advise using this decoder as the default _stereo_
    decoder.

*   Binaural - [Binaural](https://en.wikipedia.org/wiki/Binaural_recording)
    decoding. Converts B-format to two channel binaural output. Three full-band
    diffuse field equalized models are implemented:
    *  Synthetic, [Duda spherical head model](http://interface.cipic.ucdavis.edu/pubs/Duda1993%28ModelingHRTFs%29.pdf)
    *  Measured, UC Davis [CIPIC HRTF database](http://interface.cipic.ucdavis.edu/sound/hrtf.html)
    *  Measured, IRCAM [Listen HRTF database](http://recherche.ircam.fr/equipes/salles/listen/)

    __Discussion:__ The Synthetic and Measured decoders are implemented as
    frequency dependent multi-band decoders, and can be regarded as spectrally
    optimized for hearing in different ranges.

    The _Synthetic_ decoder is 4-in-1:

    1.  DC - 700Hz: _strict soundfield_, aka _basic_. Retain phase.
    2.  700 - 2000Hz: _maximum energy_, aka _max rE_. Retain phase.
    3.  2000 - 7000Hz: _strict soundfield_, aka _basic_. Discard phase.
    4.  7000Hz - Nyquist: _virtual stereo microphones_ in cardioid pair.
    Look angles = +-100deg

    Synthetic spherical head models a sphere only, and is equivalent to placing
    a pair of spaced, sphere baffled microphones in the soundfield. With no
    pinnae and no body, this spherical head model is symmetric across elevation.
    As elevation cues are not present, there is no Z component. That is, this
    decoder is _pantophonic_ (Horizontal-Only).

    The _Measured_ decoders are 5-in-1:

    1.  DC - LF: omni-directional, W only.
    2.  LF - 700Hz: _strict soundfield_, aka _basic_. Retain phase.
    3.  700 - 2000Hz: _maximum energy_, aka _max rE_. Retain phase.
    4.  2000 - 18000Hz: _strict soundfield_, aka _basic_. Discard phase.
    5.  18000Hz - Nyquist: response patterns measured from 4., at 18000Hz.

    LF = 35Hz & 60Hz for CIPIC & Listen.

    Measured decoders are designed to compensate for the proximity (near-field
    effect) of the two HRTF measurement systems. Asymmetry, across all axes,
    found in the measured HRTFs is preserved.

    __Note:__ You should have received a license notice with these kernels.
    Please see the included _Third Party Notices_ for further details on the
    CIPIC and Listen databases.


---
## Using Kernels with Reaper

The kernels are already included as part of the [ATK for Reaper](http://ambisonictoolkit.github.io/download/reaper/) install, and there is no need to download and install the kernels seperately.



## Using Kernels with SuperCollider


Install [ATK for SuperCollider](http://ambisonictoolkit.github.io/download/supercollider/). Launch SuperCollider3, and run the following code:


```
ATK Kernel Installation
(
// Create ATK support directory
// Place unzipped kernels in the directory opened  

Atk.createUserSupportDir;
Atk.openUserSupportDir;
)
```

If ATK for SuperCollider has been correctly installed, the above code will open the ATK's user support directory. Place the downloaded kernels here.

If you use ATK for Reaper as well as ATK for SuperCollider on Mac OSX, the kernels are shared between the two programs, and they will reside in the same location. We do not expect this to cause any problems.

---

## Feedback and Bug Reports

Known issues are logged at [GitHub](https://github.com/ambisonictoolkit/atk-kernels/issues).

If you experience problems or have questions pertaining to the ATK Kernels,
please create an issue in the
[ATK-Kernels issue tracker](https://github.com/ambisonictoolkit/atk-kernels/issues).

If you use the kernels for an artistic project, please
[let us know](mailto:info[at]ambisonictoolkit.net). We [plan on](https://github.com/ambisonictoolkit/ambisonictoolkit.github.io/issues/9)
adding a gallery of example artistic and creative projects that make use of the
Ambisonic Toolkit.

If you wish to use the kernels as part of a technical or software project, we'd
[like to know](mailto:info[at]ambisonictoolkit.net) about that too. We're
[planning](https://github.com/ambisonictoolkit/ambisonictoolkit.github.io/issues/10)
to link to other projects making use of Ambisonic Toolkit assets.


### List of Changes

Version 1.2.1
*   Changes:
    *   Updates to README

*   Bug Fixes:
  *   NFC radius for CIPIC binaural decoders - [Issue #9](https://github.com/ambisonictoolkit/atk-kernels/issues/9)

Version 1.2.0
*   New Features:
  *   Measured binaural decoders in all supported SRs - [Issue #1](https://github.com/ambisonictoolkit/atk-kernels/issues/1)

*   Bug Fixes:
  *   FOA spherical decoder kernels are silent at 176.4 and 192kHz - [Issue #6](https://github.com/ambisonictoolkit/atk-kernels/issues/6)

Version 1.1.0
*   New Features:
  *   Adds kernel support for 176.4 Hz - [Issue #3](https://github.com/ambisonictoolkit/atk-kernels/issues/3)


Version 1.0.1
*   There are no changes to actual sound kernels content in this release.
*   Changes:
  *   Clarifying licensing
  *   Updates to README

Version 1.0.0
*   Initial release after transition to GitHub


## Credits

The filter kernels distributed with the Ambisonic Toolkit are licensed
under a Creative Commons Attribution-Share Alike 3.0 Unported [(CC BY-SA 3.0)](http://creativecommons.org/licenses/by-sa/3.0/) License and
are copyright the Ambisonic Toolkit Community and Joseph Anderson,
2011, 2016.

* J Anderson : [[e-mail]](mailto:j.anderson[at]ambisonictoolkit.net)
