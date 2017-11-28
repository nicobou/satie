// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


// note: this post processor is intended to operate on an 18-channel input vector (Satie Global Outputs)  structured in the following way
// INPUT:  input vector corresponds to the 16-channel 3rd order ambisonics signal, containing the SATIE's accumulated sound source outputs
// OUTPUT: stereo output of the binaural decoder

~name = \ambi3BinauralDecoder;
~description = "third order ambisonic to binaural decoder";



//outputs named auxBus on named outputChannel
~function = { | in=0, fq = 500, q = 1.0, boostCut = 18 |
	var ambiVec = in;
	var outsig;

	outsig =  BinAmbi3O.ar(ambiVec);   // decodes for HRTF

	outsig = BLowShelf.ar(
		outsig,
		fq,   // freq
		q, // q
		boostCut ); // cut/boost

	// stereo output will be written to Satie's outputs
}